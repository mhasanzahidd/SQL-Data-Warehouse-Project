/*
==============================================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
==============================================================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to populate the 'silver' schema
    from the 'bronze' schema.

Actions Performed:
    - Truncates Silver tables before loading.
    - Cleanses, standardizes, and transforms raw Bronze data.
    - Removes duplicate customer records by retaining the most recent record.
    - Converts and validates source date values.
    - Derives and standardizes product and customer attributes.
    - Tracks individual table load durations and the overall batch execution time.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver;
==============================================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, 
			@batch_start_time DATETIME, @batch_end_time DATETIME;

	BEGIN TRY
		SET @batch_start_time = GETDATE();
		
		PRINT '=====================================================';
		PRINT 'Loading Silver Layer';
		PRINT '=====================================================';

		PRINT '-----------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '-----------------------------------------------------';
		
		-- Customer data is deduplicated and standardized before being loaded into the Silver layer.
		SET @start_time = GETDATE();
		PRINT 'Truncate Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;

		PRINT 'Inserting Data Into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id, 
			cst_key, 
			cst_firstname, 
			cst_lastname, 
			cst_marital_status, 
			cst_gndr,
			cst_create_date
		)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				ELSE 'n/a'
			END AS cst_marital_status,
			CASE
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'n/a'
			END AS cst_gndr,
			cst_create_date
		FROM (
			SELECT *, 
				ROW_NUMBER() OVER(
					PARTITION BY cst_id 
					ORDER BY cst_create_date DESC
				) AS Flag
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		)t
		WHERE Flag = 1; -- Retain the most recent record when multiple records exist for the same customer.

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ----------';


		-- Product keys are split into category and product components for easier integration with other datasets.
		SET @start_time = GETDATE();
		PRINT 'Truncate Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;

		PRINT 'Inserting Data Into: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Derive the category identifier from the source product key.
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key, -- Remove the category prefix to retain the product identifier.
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost,
			CASE
				WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
				WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
				WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
				WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line,
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(
				DATEADD(
					DAY, 
					-1, 
					LEAD(prd_start_dt) OVER(
						PARTITION BY prd_key 
						ORDER BY prd_start_dt
					)
				) AS DATE
			) AS prd_end_dt
		FROM bronze.crm_prd_info;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ----------';


		-- Sales dates and financial measures are validated and converted into consistent formats.
		SET @start_time = GETDATE();
		PRINT 'Truncate Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;

		PRINT 'Inserting Data Into: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,

			-- Invalid or incomplete YYYYMMDD values are converted to NULL.
			CASE
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) <> 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,

			CASE
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) <> 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,

			CASE
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) <> 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,

			-- Recalculate sales when the source value is missing, invalid, or inconsistent with quantity and price.
			CASE 
				WHEN sls_sales IS NULL 
					OR sls_sales <= 0 
					OR sls_sales != sls_quantity * ABS(sls_price)
					THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales,

			sls_quantity,

			-- Derive price from sales and quantity when the source price is missing or invalid.
			CASE
				WHEN sls_price IS NULL OR sls_price <= 0
					THEN ISNULL(sls_sales / NULLIF(sls_quantity, 0), 0)
				ELSE sls_price
			END AS sls_price

		FROM bronze.crm_sales_details;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ----------';


		PRINT '-----------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '-----------------------------------------------------';

		-- ERP customer attributes are standardized to align with the CRM customer structure.
		SET @start_time = GETDATE();
		PRINT 'Truncate Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;

		PRINT 'Inserting Data Into: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT 
			-- Remove the NAS prefix so customer identifiers can be matched across source systems.
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				ELSE cid
			END AS cid,

			-- Future birth dates are considered invalid and replaced with NULL.
			CASE
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate,

			-- Standardize gender values from different source representations.
			CASE
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				ELSE 'n/a'
			END AS gen

		FROM bronze.erp_cust_az12;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ----------';


		-- Location identifiers and country codes are standardized for cross-source integration.
		SET @start_time = GETDATE();
		PRINT 'Truncate Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;

		PRINT 'Inserting Data Into: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101 (
			cid,
			cntry
		)
		SELECT 
			REPLACE(cid, '-', '') AS cid,

			CASE
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END AS cntry

		FROM bronze.erp_loc_a101;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ----------';


		-- Product category attributes are transferred to Silver without additional transformation.
		SET @start_time = GETDATE();
		PRINT 'Truncate Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;

		PRINT 'Inserting Data Into: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT 
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ----------';


		-- Report the total execution time after completing all Silver layer loads.
		SET @batch_end_time = GETDATE();

		PRINT '=====================================================';
		PRINT 'Loading Silver Layer Is Completed';
		PRINT ' - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=====================================================';

	END TRY

	BEGIN CATCH
		-- Capture relevant error details to support troubleshooting of failed ETL executions.
		PRINT '=====================================================';
		PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=====================================================';
	END CATCH
END;
