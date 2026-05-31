/*
================================================
Quality Checks
================================================
This script performs various quality checks for
data consistency, accuracy, and standardization
across the 'silver' schemas. It includes checks
for:
    - Null or duplicate primary keys
    - Unwanted spaces in string fields
    - Data standardization and consistency
    - Invalid date ranges and orders
    - Data consistency between related fields

Notes:
    - Run these checks after loading Silver layer
    - Investigate and resolve any discrepancies
      found during the checks
================================================
*/

-- ================================================
-- Checking silver.crm_cust_info
-- ================================================
-- Check for nulls and duplicates in primary key
-- Expect: No results
SELECT
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check unwanted spaces
-- Expect no results
SELECT cst_key 
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Data Standardization & Consistency
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;


-- ================================================
-- Checking silver.crm_prd_info
-- ================================================
-- Check for nulls and duplicates in primary key
-- Expect: No results
SELECT
  prd_id,
  COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check unwanted spaces
-- Expect no results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for null or negative values in cost
SELECT prd_cost FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check for Invalid Date Orders
SELECT * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- ================================================
-- Checking silver.crm_sales_details
-- ================================================
-- Check invalid dates
SELECT sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
   OR LENGTH(CAST(sls_due_dt AS VARCHAR)) != 8
   OR sls_due_dt > 20500101;

-- Check invalid date orders
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
  OR sls_order_dt > sls_due_dt;

-- Check calculations: sales = quantity * price
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


-- ================================================
-- Checking silver.erp_cust_az12
-- ================================================
-- Identify out-of-range dates
-- Expect: Date between 1924 - now
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
  OR bdate > CURRENT_TIMESTAMP;

-- Data Standardization & Consistency
SELECT DISTINCT gen
FROM silver.erp_cust_az12;


-- ================================================
-- Checking silver.erp_loc_a101
-- ================================================
-- Data Standardization & Consistency
SELECT DISTINCT cntry
FROM silver.erp_loc_a101;


-- ================================================
-- Checking silver.erp_px_cat_g1v2
-- ================================================
-- Check for unwanted spaces
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

-- Data Standardization and Consistency
SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2;

