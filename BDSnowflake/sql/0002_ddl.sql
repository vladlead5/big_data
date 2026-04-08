CREATE SCHEMA IF NOT EXISTS dw;

DROP TABLE IF EXISTS dw.fact_sales CASCADE;
DROP TABLE IF EXISTS dw.dim_supplier CASCADE;
DROP TABLE IF EXISTS dw.dim_store CASCADE;
DROP TABLE IF EXISTS dw.dim_product CASCADE;
DROP TABLE IF EXISTS dw.dim_seller CASCADE;
DROP TABLE IF EXISTS dw.dim_customer CASCADE;
DROP TABLE IF EXISTS dw.dim_date CASCADE;
DROP TABLE IF EXISTS dw.dim_geo CASCADE;
DROP TABLE IF EXISTS dw.dim_pet_type CASCADE;
DROP TABLE IF EXISTS dw.dim_pet_category CASCADE;

CREATE TABLE dw.dim_date (
  date_key INTEGER PRIMARY KEY,
  full_date DATE NOT NULL UNIQUE,
  day_of_month SMALLINT NOT NULL,
  month_number SMALLINT NOT NULL,
  month_name TEXT NOT NULL,
  quarter_number SMALLINT NOT NULL,
  year_number INTEGER NOT NULL,
  week_of_year SMALLINT NOT NULL,
  day_of_week SMALLINT NOT NULL
);

CREATE TABLE dw.dim_geo (
  geo_key BIGSERIAL PRIMARY KEY,
  geo_bk_hash TEXT NOT NULL UNIQUE,
  country TEXT,
  state TEXT,
  city TEXT,
  postal_code TEXT,
  address TEXT,
  location TEXT
);

CREATE TABLE dw.dim_pet_type (
  pet_type_key BIGSERIAL PRIMARY KEY,
  pet_type_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dw.dim_pet_category (
  pet_category_key BIGSERIAL PRIMARY KEY,
  pet_category_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dw.dim_customer (
  customer_key BIGSERIAL PRIMARY KEY,
  customer_bk_hash TEXT NOT NULL UNIQUE,
  source_id INTEGER,
  geo_key BIGINT REFERENCES dw.dim_geo(geo_key),
  pet_type_key BIGINT REFERENCES dw.dim_pet_type(pet_type_key),
  customer_email TEXT,
  first_name TEXT,
  last_name TEXT,
  age INTEGER,
  pet_name TEXT,
  pet_breed TEXT
);

CREATE TABLE dw.dim_seller (
  seller_key BIGSERIAL PRIMARY KEY,
  seller_bk_hash TEXT NOT NULL UNIQUE,
  source_id INTEGER,
  geo_key BIGINT REFERENCES dw.dim_geo(geo_key),
  seller_email TEXT,
  first_name TEXT,
  last_name TEXT
);

CREATE TABLE dw.dim_product (
  product_key BIGSERIAL PRIMARY KEY,
  product_bk_hash TEXT NOT NULL UNIQUE,
  source_id INTEGER,
  pet_category_key BIGINT REFERENCES dw.dim_pet_category(pet_category_key),
  product_name TEXT,
  product_category TEXT,
  product_brand TEXT,
  product_material TEXT,
  product_color TEXT,
  product_size TEXT,
  product_weight NUMERIC(10,2),
  product_price NUMERIC(12,2),
  product_rating NUMERIC(3,1),
  product_reviews INTEGER,
  product_release_date DATE,
  product_expiry_date DATE,
  product_description TEXT
);

CREATE TABLE dw.dim_store (
  store_key BIGSERIAL PRIMARY KEY,
  store_bk_hash TEXT NOT NULL UNIQUE,
  geo_key BIGINT REFERENCES dw.dim_geo(geo_key),
  store_name TEXT,
  store_phone TEXT,
  store_email TEXT
);

CREATE TABLE dw.dim_supplier (
  supplier_key BIGSERIAL PRIMARY KEY,
  supplier_bk_hash TEXT NOT NULL UNIQUE,
  geo_key BIGINT REFERENCES dw.dim_geo(geo_key),
  supplier_name TEXT,
  supplier_contact TEXT,
  supplier_email TEXT,
  supplier_phone TEXT
);

CREATE TABLE dw.fact_sales (
  sales_key BIGSERIAL PRIMARY KEY,
  source_row_id INTEGER,
  date_key INTEGER NOT NULL REFERENCES dw.dim_date(date_key),
  customer_key BIGINT NOT NULL REFERENCES dw.dim_customer(customer_key),
  seller_key BIGINT NOT NULL REFERENCES dw.dim_seller(seller_key),
  product_key BIGINT NOT NULL REFERENCES dw.dim_product(product_key),
  store_key BIGINT NOT NULL REFERENCES dw.dim_store(store_key),
  supplier_key BIGINT NOT NULL REFERENCES dw.dim_supplier(supplier_key),
  sale_quantity INTEGER,
  sale_total_price NUMERIC(12,2),
  listed_product_price NUMERIC(12,2),
  listed_product_quantity INTEGER,
  created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_fact_sales_date_key ON dw.fact_sales(date_key);
CREATE INDEX idx_fact_sales_product_key ON dw.fact_sales(product_key);
CREATE INDEX idx_fact_sales_customer_key ON dw.fact_sales(customer_key);
CREATE INDEX idx_dim_customer_source_id ON dw.dim_customer(source_id);
CREATE INDEX idx_dim_seller_source_id ON dw.dim_seller(source_id);
CREATE INDEX idx_dim_product_source_id ON dw.dim_product(source_id);
