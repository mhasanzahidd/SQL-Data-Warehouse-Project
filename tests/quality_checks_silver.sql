/*
==============================================================================================================
Quality Checks
==============================================================================================================
Script Purpose:
    This script performs data quality checks to validate consistency, accuracy, and standardization
    across the 'silver' layer.

    The checks cover:
    - Null or duplicate business keys.
    - Unwanted whitespace in string attributes.
    - Standardization of categorical values.
    - Invalid date ranges and chronological relationships.
    - Invalid numeric values and financial calculations.
    - Consistency between related fields.

Usage Notes:
    - Run these checks after loading the Silver layer.
    - Any unexpected results should be investigated before the data is consumed by the Gold layer.
==============================================================================================================
*/


-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================

-- Customer IDs should uniquely identify a customer and must not be NULL.
-- Expectation: No Results
SELECT 
    cst_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- Customer keys should not contain leading or trailing whitespace.
-- Expectation: No Results
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);


-- Verify that marital status values follow the expected standardized format.
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;



-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================

-- Product IDs should uniquely identify a product and must not be NULL.
-- Expectation: No Results
SELECT 
    prd_id,
    COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


-- Product names should not contain leading or trailing whitespace.
-- Expectation: No Results
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- Product cost should contain valid non-negative values.
-- Expectation: No Results
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;


-- Verify that product line values have been standardized to the expected categories.
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;


-- Product end dates should never occur before their corresponding start dates.
-- Expectation: No Results
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;



-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================

-- Validate source date values before they are converted from YYYYMMDD integers into DATE values.
-- Expectation: No Invalid Dates
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_due_dt) != 8 
    OR sls_due_dt > 20500101 
    OR sls_due_dt < 19000101;


-- Sales dates should follow the expected chronological order:
-- Order Date <= Shipping Date and Order Date <= Due Date.
-- Expectation: No Results
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;


-- Validate the relationship between sales, quantity, and price.
-- Expectation: No Results
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;



-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================

-- Birthdates should fall within the expected business range and cannot be future dates.
-- Expectation: No Results
SELECT DISTINCT 
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();


-- Verify that gender values have been standardized to the expected categories.
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;



-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================

-- Review standardized country values to identify unexpected or inconsistent representations.
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;



-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================

-- Category attributes should not contain leading or trailing whitespace.
-- Expectation: No Results
SELECT 
    * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);


-- Verify that maintenance values follow the expected standardized categories.
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;
