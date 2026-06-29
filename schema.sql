CREATE TABLE category (
    product_category_name VARCHAR(50) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);

COMMENT ON COLUMN category.product_category_name IS 'Product Category Name';
COMMENT ON COLUMN category.product_category_name_english IS 'Product Category Name English';

ALTER TABLE category ADD CONSTRAINT category_pk PRIMARY KEY (product_category_name);

CREATE TABLE customers (
    customer_id VARCHAR(32) NOT NULL,
    customer_unique_id VARCHAR(32) NOT NULL,
    customer_zip_code_prefix NUMBER(5),
    customer_city CHAR(30),
    customer_state CHAR(2)
);

COMMENT ON COLUMN category.customer_id IS 'Customer identifier';
COMMENT