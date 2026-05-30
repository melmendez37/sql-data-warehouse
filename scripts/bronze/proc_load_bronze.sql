/*
=========================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=========================================================
This stored procedure loads data into the 'bronze' schema
from external CSV files. This performs the following 
actions:
  - Truncates the bronze tables before loading data
  - Uses COPY command to load data from csv files to
    bronze tables. (Use filepath in your computer.)
  - For this project, \copy was used to successfully
    import the files locally. Run psql in terminal
    to import locally.

No parameters needed.

Run this to verify if procedure works.
CALL bronze.load_bronze();
=========================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;

BEGIN
    batch_start_time := clock_timestamp();
    RAISE NOTICE '==================================';
    RAISE NOTICE 'Loading Bronze Layer...';
    RAISE NOTICE '==================================';

    RAISE NOTICE '----------------------------------';
    RAISE NOTICE 'Loading CRM Tables...';
    RAISE NOTICE '----------------------------------';

    start_time := clock_timestamp();
    RAISE NOTICE '>>> Truncating table: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;

    RAISE NOTICE '>>> Inserting Data Into: bronze.crm_cust_info';
    -- Run this command using \copy after running psql on your terminal.
    COPY bronze.crm_cust_info(cst_id, cst_key, cst_firstname, cst_lastname, cst_material_status, cst_gender, cst_create_date)
        FROM '~/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
        WITH(
            FORMAT csv,
            HEADER true,
            DELIMITER ','
        );

    end_time := clock_timestamp();
    RAISE NOTICE '>> Duration: %', end_time - start_time, ' seconds';
    RAISE NOTICE '>> --------------';

    start_time := clock_timestamp();
    RAISE NOTICE '>>> Truncating table: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;

    RAISE NOTICE '>>> Inserting Data Into: bronze.crm_prd_info';
    COPY bronze.crm_prd_info(prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
        FROM '~/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
        WITH(
            FORMAT csv,
            HEADER true,
            DELIMITER ','
        );

    end_time := clock_timestamp();
    RAISE NOTICE '>> Duration: %', end_time - start_time, ' seconds';
    RAISE NOTICE '>> --------------';

    start_time := clock_timestamp();
    RAISE NOTICE '>>> Truncating table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;

    RAISE NOTICE '>>> Inserting Data Into: bronze.crm_sales_details';
    COPY bronze.crm_sales_details(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
        FROM '~/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
        WITH (
            FORMAT csv,
            HEADER true,
            DELIMITER ','
        );

    end_time := clock_timestamp();
    RAISE NOTICE '>> Duration: %', end_time - start_time, ' seconds';
    RAISE NOTICE '>> --------------';

    start_time := clock_timestamp();
    RAISE NOTICE '>>> Truncating table: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;

    RAISE NOTICE '>>> Inserting Data Into: bronze.erp_cust_az12';
    COPY bronze.erp_cust_az12(cid, bdate, gen)
        FROM '~/sql-data-warehouse-project/datasets/source_erp/CUST_AZ12.csv'
        WITH (
            FORMAT csv,
            HEADER true,
            DELIMITER ','
        );

    end_time := clock_timestamp();
    RAISE NOTICE '>> Duration: %', end_time - start_time, ' seconds';
    RAISE NOTICE '>> --------------';

    start_time := clock_timestamp();
    RAISE NOTICE '>>> Truncating table: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;

    RAISE NOTICE '>>> Inserting Data Into: bronze.erp_loc_a101';
    COPY bronze.erp_loc_a101(cid, cntry)
        FROM '~/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'
        WITH (
            FORMAT csv,
            HEADER true,
            DELIMITER ','
        );

    end_time := clock_timestamp();
    RAISE NOTICE '>> Duration: %', end_time - start_time, ' seconds';
    RAISE NOTICE '>> --------------';

    start_time := clock_timestamp();
    RAISE NOTICE '>>> Truncating table: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    RAISE NOTICE '>>> Inserting Data Into: bronze.erp_px_cat_g1v2';
    COPY bronze.erp_px_cat_g1v2(id, cat, subcat, maintenance)
        FROM '~/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
        WITH (
            FORMAT csv,
            HEADER true,
            DELIMITER ','
        );

    end_time := clock_timestamp();
    RAISE NOTICE '>> Duration: %', end_time - start_time, ' seconds';
    RAISE NOTICE '>> --------------';

    batch_end_time := clock_timestamp();
    RAISE NOTICE '==================================';
    RAISE NOTICE 'Loading Bronze Layer Completed.';
    RAISE NOTICE 'Duration: %', batch_end_time - batch_start_time, ' seconds';
    RAISE NOTICE '==================================';

    EXCEPTION
        WHEN others THEN
            RAISE NOTICE '==================================';
            RAISE NOTICE 'Error occurred during loading Bronze Layer';
            RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
            RAISE NOTICE 'ERROR: %', SQLERRM;
            RAISE NOTICE '==================================';
END;
$$;

