/*
==============================================================================================================
Quality Checks
==============================================================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, and accuracy of the Gold layer.

    The checks cover:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validity of relationships within the Star Schema for analytical use.

Usage Notes:
    - Run these checks after creating or refreshing the Gold layer.
    - Investigate and resolve any unexpected results before using the data for reporting or analysis.
==============================================================================================================
*/


-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================

-- Customer surrogate keys should uniquely identify each dimension record.
-- Expectation: No Results
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;



-- ====================================================================
-- Checking 'gold.dim_products'
-- ====================================================================

-- Product surrogate keys should uniquely identify each dimension record.
-- Expectation: No Results
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;



-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================

-- Each fact record should successfully map to an existing customer and product dimension record.
-- Expectation: No Results
SELECT 
    *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL 
   OR c.customer_key IS NULL;
