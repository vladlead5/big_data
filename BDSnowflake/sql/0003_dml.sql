TRUNCATE TABLE
  dw.fact_sales,
  dw.dim_supplier,
  dw.dim_store,
  dw.dim_product,
  dw.dim_seller,
  dw.dim_customer,
  dw.dim_pet_category,
  dw.dim_pet_type,
  dw.dim_geo,
  dw.dim_date
RESTART IDENTITY CASCADE;

CREATE TEMP TABLE tmp_src AS
SELECT
  src.*,
  MD5(CONCAT_WS('|', COALESCE(src.customer_country, ''), '', '', COALESCE(src.customer_postal_code, ''), '', '')) AS customer_geo_hash,
  MD5(CONCAT_WS('|', COALESCE(src.seller_country, ''), '', '', COALESCE(src.seller_postal_code, ''), '', '')) AS seller_geo_hash,
  MD5(CONCAT_WS('|', COALESCE(src.store_country, ''), COALESCE(src.store_state, ''), COALESCE(src.store_city, ''), '', '', COALESCE(src.store_location, ''))) AS store_geo_hash,
  MD5(CONCAT_WS('|', COALESCE(src.supplier_country, ''), '', COALESCE(src.supplier_city, ''), '', COALESCE(src.supplier_address, ''), '')) AS supplier_geo_hash,

  MD5(CONCAT_WS('|',
    COALESCE(src.customer_email, ''),
    COALESCE(src.customer_first_name, ''),
    COALESCE(src.customer_last_name, ''),
    COALESCE(src.customer_country, ''),
    COALESCE(src.customer_postal_code, ''),
    COALESCE(src.customer_pet_type, ''),
    COALESCE(src.customer_pet_name, ''),
    COALESCE(src.customer_pet_breed, '')
  )) AS customer_hash,

  MD5(CONCAT_WS('|',
    COALESCE(src.seller_email, ''),
    COALESCE(src.seller_first_name, ''),
    COALESCE(src.seller_last_name, ''),
    COALESCE(src.seller_country, ''),
    COALESCE(src.seller_postal_code, '')
  )) AS seller_hash,

  MD5(CONCAT_WS('|',
    COALESCE(src.product_name, ''),
    COALESCE(src.product_category, ''),
    COALESCE(src.pet_category, ''),
    COALESCE(src.product_brand, ''),
    COALESCE(src.product_material, ''),
    COALESCE(src.product_color, ''),
    COALESCE(src.product_size, ''),
    COALESCE(src.product_weight::TEXT, ''),
    COALESCE(src.product_price::TEXT, ''),
    COALESCE(src.product_rating::TEXT, ''),
    COALESCE(src.product_reviews::TEXT, ''),
    COALESCE(src.product_release_date::TEXT, ''),
    COALESCE(src.product_expiry_date::TEXT, ''),
    COALESCE(src.product_description, '')
  )) AS product_hash,

  MD5(CONCAT_WS('|',
    COALESCE(src.store_name, ''),
    COALESCE(src.store_location, ''),
    COALESCE(src.store_city, ''),
    COALESCE(src.store_state, ''),
    COALESCE(src.store_country, ''),
    COALESCE(src.store_phone, ''),
    COALESCE(src.store_email, '')
  )) AS store_hash,

  MD5(CONCAT_WS('|',
    COALESCE(src.supplier_name, ''),
    COALESCE(src.supplier_contact, ''),
    COALESCE(src.supplier_email, ''),
    COALESCE(src.supplier_phone, ''),
    COALESCE(src.supplier_address, ''),
    COALESCE(src.supplier_city, ''),
    COALESCE(src.supplier_country, '')
  )) AS supplier_hash
FROM (
  SELECT
    NULLIF(TRIM(s.id), '')::INTEGER AS source_row_id,
    TO_DATE(NULLIF(TRIM(s.sale_date), ''), 'MM/DD/YYYY') AS sale_date,
    TO_CHAR(TO_DATE(NULLIF(TRIM(s.sale_date), ''), 'MM/DD/YYYY'), 'YYYYMMDD')::INTEGER AS sale_date_key,

    TRIM(s.customer_first_name) AS customer_first_name,
    TRIM(s.customer_last_name) AS customer_last_name,
    NULLIF(TRIM(s.customer_age), '')::INTEGER AS customer_age,
    TRIM(s.customer_email) AS customer_email,
    TRIM(s.customer_country) AS customer_country,
    TRIM(s.customer_postal_code) AS customer_postal_code,
    TRIM(s.customer_pet_type) AS customer_pet_type,
    TRIM(s.customer_pet_name) AS customer_pet_name,
    TRIM(s.customer_pet_breed) AS customer_pet_breed,

    TRIM(s.seller_first_name) AS seller_first_name,
    TRIM(s.seller_last_name) AS seller_last_name,
    TRIM(s.seller_email) AS seller_email,
    TRIM(s.seller_country) AS seller_country,
    TRIM(s.seller_postal_code) AS seller_postal_code,

    TRIM(s.product_name) AS product_name,
    TRIM(s.product_category) AS product_category,
    NULLIF(TRIM(s.product_price), '')::NUMERIC(12,2) AS product_price,
    NULLIF(TRIM(s.product_quantity), '')::INTEGER AS product_quantity,

    NULLIF(TRIM(s.sale_quantity), '')::INTEGER AS sale_quantity,
    NULLIF(TRIM(s.sale_total_price), '')::NUMERIC(12,2) AS sale_total_price,
    NULLIF(TRIM(s.sale_customer_id), '')::INTEGER AS sale_customer_id,
    NULLIF(TRIM(s.sale_seller_id), '')::INTEGER AS sale_seller_id,
    NULLIF(TRIM(s.sale_product_id), '')::INTEGER AS sale_product_id,

    TRIM(s.store_name) AS store_name,
    TRIM(s.store_location) AS store_location,
    TRIM(s.store_city) AS store_city,
    TRIM(s.store_state) AS store_state,
    TRIM(s.store_country) AS store_country,
    TRIM(s.store_phone) AS store_phone,
    TRIM(s.store_email) AS store_email,

    TRIM(s.pet_category) AS pet_category,
    NULLIF(TRIM(s.product_weight), '')::NUMERIC(10,2) AS product_weight,
    TRIM(s.product_color) AS product_color,
    TRIM(s.product_size) AS product_size,
    TRIM(s.product_brand) AS product_brand,
    TRIM(s.product_material) AS product_material,
    TRIM(s.product_description) AS product_description,
    NULLIF(TRIM(s.product_rating), '')::NUMERIC(3,1) AS product_rating,
    NULLIF(TRIM(s.product_reviews), '')::INTEGER AS product_reviews,
    TO_DATE(NULLIF(TRIM(s.product_release_date), ''), 'MM/DD/YYYY') AS product_release_date,
    TO_DATE(NULLIF(TRIM(s.product_expiry_date), ''), 'MM/DD/YYYY') AS product_expiry_date,

    TRIM(s.supplier_name) AS supplier_name,
    TRIM(s.supplier_contact) AS supplier_contact,
    TRIM(s.supplier_email) AS supplier_email,
    TRIM(s.supplier_phone) AS supplier_phone,
    TRIM(s.supplier_address) AS supplier_address,
    TRIM(s.supplier_city) AS supplier_city,
    TRIM(s.supplier_country) AS supplier_country
  FROM raw.mock_data_staging s
) src;

INSERT INTO dw.dim_date (
  date_key,
  full_date,
  day_of_month,
  month_number,
  month_name,
  quarter_number,
  year_number,
  week_of_year,
  day_of_week
)
SELECT DISTINCT
  sale_date_key,
  sale_date,
  EXTRACT(DAY FROM sale_date)::SMALLINT,
  EXTRACT(MONTH FROM sale_date)::SMALLINT,
  TRIM(TO_CHAR(sale_date, 'Month')),
  EXTRACT(QUARTER FROM sale_date)::SMALLINT,
  EXTRACT(YEAR FROM sale_date)::INTEGER,
  EXTRACT(WEEK FROM sale_date)::SMALLINT,
  EXTRACT(ISODOW FROM sale_date)::SMALLINT
FROM tmp_src
WHERE sale_date IS NOT NULL;

INSERT INTO dw.dim_geo (
  geo_bk_hash,
  country,
  state,
  city,
  postal_code,
  address,
  location
)
SELECT DISTINCT
  src.geo_bk_hash,
  src.country,
  src.state,
  src.city,
  src.postal_code,
  src.address,
  src.location
FROM (
  SELECT customer_geo_hash AS geo_bk_hash, customer_country AS country, NULL::TEXT AS state, NULL::TEXT AS city, customer_postal_code AS postal_code, NULL::TEXT AS address, NULL::TEXT AS location FROM tmp_src
  UNION
  SELECT seller_geo_hash, seller_country, NULL::TEXT, NULL::TEXT, seller_postal_code, NULL::TEXT, NULL::TEXT FROM tmp_src
  UNION
  SELECT store_geo_hash, store_country, store_state, store_city, NULL::TEXT, NULL::TEXT, store_location FROM tmp_src
  UNION
  SELECT supplier_geo_hash, supplier_country, NULL::TEXT, supplier_city, NULL::TEXT, supplier_address, NULL::TEXT FROM tmp_src
) src;

INSERT INTO dw.dim_pet_type (pet_type_name)
SELECT DISTINCT customer_pet_type
FROM tmp_src
WHERE customer_pet_type IS NOT NULL;

INSERT INTO dw.dim_pet_category (pet_category_name)
SELECT DISTINCT pet_category
FROM tmp_src
WHERE pet_category IS NOT NULL;

INSERT INTO dw.dim_customer (
  customer_bk_hash,
  source_id,
  geo_key,
  pet_type_key,
  customer_email,
  first_name,
  last_name,
  age,
  pet_name,
  pet_breed
)
SELECT DISTINCT ON (src.sale_customer_id)
  src.customer_hash,
  src.sale_customer_id,
  geo.geo_key,
  pet_type.pet_type_key,
  src.customer_email,
  src.customer_first_name,
  src.customer_last_name,
  src.customer_age,
  src.customer_pet_name,
  src.customer_pet_breed
FROM tmp_src src
LEFT JOIN dw.dim_geo geo
  ON geo.geo_bk_hash = src.customer_geo_hash
LEFT JOIN dw.dim_pet_type pet_type
  ON pet_type.pet_type_name = src.customer_pet_type
WHERE src.sale_customer_id IS NOT NULL
ORDER BY src.sale_customer_id, src.source_row_id;

INSERT INTO dw.dim_seller (
  seller_bk_hash,
  source_id,
  geo_key,
  seller_email,
  first_name,
  last_name
)
SELECT DISTINCT ON (src.sale_seller_id)
  src.seller_hash,
  src.sale_seller_id,
  geo.geo_key,
  src.seller_email,
  src.seller_first_name,
  src.seller_last_name
FROM tmp_src src
LEFT JOIN dw.dim_geo geo
  ON geo.geo_bk_hash = src.seller_geo_hash
WHERE src.sale_seller_id IS NOT NULL
ORDER BY src.sale_seller_id, src.source_row_id;

INSERT INTO dw.dim_product (
  product_bk_hash,
  source_id,
  pet_category_key,
  product_name,
  product_category,
  product_brand,
  product_material,
  product_color,
  product_size,
  product_weight,
  product_price,
  product_rating,
  product_reviews,
  product_release_date,
  product_expiry_date,
  product_description
)
SELECT DISTINCT ON (src.sale_product_id)
  src.product_hash,
  src.sale_product_id,
  pet_category.pet_category_key,
  src.product_name,
  src.product_category,
  src.product_brand,
  src.product_material,
  src.product_color,
  src.product_size,
  src.product_weight,
  src.product_price,
  src.product_rating,
  src.product_reviews,
  src.product_release_date,
  src.product_expiry_date,
  src.product_description
FROM tmp_src src
LEFT JOIN dw.dim_pet_category pet_category
  ON pet_category.pet_category_name = src.pet_category
WHERE src.sale_product_id IS NOT NULL
ORDER BY src.sale_product_id, src.source_row_id;

INSERT INTO dw.dim_store (
  store_bk_hash,
  geo_key,
  store_name,
  store_phone,
  store_email
)
SELECT DISTINCT
  src.store_hash,
  geo.geo_key,
  src.store_name,
  src.store_phone,
  src.store_email
FROM tmp_src src
LEFT JOIN dw.dim_geo geo
  ON geo.geo_bk_hash = src.store_geo_hash;

INSERT INTO dw.dim_supplier (
  supplier_bk_hash,
  geo_key,
  supplier_name,
  supplier_contact,
  supplier_email,
  supplier_phone
)
SELECT DISTINCT
  src.supplier_hash,
  geo.geo_key,
  src.supplier_name,
  src.supplier_contact,
  src.supplier_email,
  src.supplier_phone
FROM tmp_src src
LEFT JOIN dw.dim_geo geo
  ON geo.geo_bk_hash = src.supplier_geo_hash;

INSERT INTO dw.fact_sales (
  source_row_id,
  date_key,
  customer_key,
  seller_key,
  product_key,
  store_key,
  supplier_key,
  sale_quantity,
  sale_total_price,
  listed_product_price,
  listed_product_quantity
)
SELECT
  src.source_row_id,
  date_dim.date_key,
  customer_dim.customer_key,
  seller_dim.seller_key,
  product_dim.product_key,
  store_dim.store_key,
  supplier_dim.supplier_key,
  src.sale_quantity,
  src.sale_total_price,
  src.product_price,
  src.product_quantity
FROM tmp_src src
JOIN dw.dim_date date_dim
  ON date_dim.full_date = src.sale_date
JOIN dw.dim_customer customer_dim
  ON customer_dim.source_id = src.sale_customer_id
JOIN dw.dim_seller seller_dim
  ON seller_dim.source_id = src.sale_seller_id
JOIN dw.dim_product product_dim
  ON product_dim.source_id = src.sale_product_id
JOIN dw.dim_store store_dim
  ON store_dim.store_bk_hash = src.store_hash
JOIN dw.dim_supplier supplier_dim
  ON supplier_dim.supplier_bk_hash = src.supplier_hash;

SELECT 'raw.mock_data_staging' AS table_name, COUNT(*) AS rows FROM raw.mock_data_staging
UNION ALL
SELECT 'dw.fact_sales' AS table_name, COUNT(*) AS rows FROM dw.fact_sales
ORDER BY table_name;
