DROP SCHEMA IF EXISTS raw CASCADE;

CREATE SCHEMA raw;

CREATE TABLE raw.mock_data_staging (
  id TEXT,
  customer_first_name TEXT,
  customer_last_name TEXT,
  customer_age TEXT,
  customer_email TEXT,
  customer_country TEXT,
  customer_postal_code TEXT,
  customer_pet_type TEXT,
  customer_pet_name TEXT,
  customer_pet_breed TEXT,
  seller_first_name TEXT,
  seller_last_name TEXT,
  seller_email TEXT,
  seller_country TEXT,
  seller_postal_code TEXT,
  product_name TEXT,
  product_category TEXT,
  product_price TEXT,
  product_quantity TEXT,
  sale_date TEXT,
  sale_customer_id TEXT,
  sale_seller_id TEXT,
  sale_product_id TEXT,
  sale_quantity TEXT,
  sale_total_price TEXT,
  store_name TEXT,
  store_location TEXT,
  store_city TEXT,
  store_state TEXT,
  store_country TEXT,
  store_phone TEXT,
  store_email TEXT,
  pet_category TEXT,
  product_weight TEXT,
  product_color TEXT,
  product_size TEXT,
  product_brand TEXT,
  product_material TEXT,
  product_description TEXT,
  product_rating TEXT,
  product_reviews TEXT,
  product_release_date TEXT,
  product_expiry_date TEXT,
  supplier_name TEXT,
  supplier_contact TEXT,
  supplier_email TEXT,
  supplier_phone TEXT,
  supplier_address TEXT,
  supplier_city TEXT,
  supplier_country TEXT
);

DO $$
DECLARE
  file_name TEXT;
  files TEXT[] := ARRAY[
    '/data/csv/MOCK_DATA.csv',
    '/data/csv/MOCK_DATA (1).csv',
    '/data/csv/MOCK_DATA (2).csv',
    '/data/csv/MOCK_DATA (3).csv',
    '/data/csv/MOCK_DATA (4).csv',
    '/data/csv/MOCK_DATA (5).csv',
    '/data/csv/MOCK_DATA (6).csv',
    '/data/csv/MOCK_DATA (7).csv',
    '/data/csv/MOCK_DATA (8).csv',
    '/data/csv/MOCK_DATA (9).csv'
  ];
BEGIN
  FOREACH file_name IN ARRAY files LOOP
    EXECUTE FORMAT(
      'COPY raw.mock_data_staging FROM %L WITH (FORMAT CSV, HEADER TRUE, DELIMITER '','', QUOTE ''"'', ESCAPE ''"'')',
      file_name
    );
  END LOOP;
END $$;

CREATE OR REPLACE VIEW public.mock_data AS
SELECT *
FROM raw.mock_data_staging;

SELECT COUNT(*) AS staging_rows
FROM raw.mock_data_staging;
