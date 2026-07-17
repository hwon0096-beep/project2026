BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE order_reviews CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE order_payments CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE order_items CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE orders CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE products CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE category_translation CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE sellers CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE customers CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE geolocation CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

CREATE TABLE category_translation (
    product_category_name VARCHAR2(100) PRIMARY KEY,
    product_category_name_english VARCHAR2(100)
);

CREATE TABLE customers (
    customer_id VARCHAR2(32) PRIMARY KEY,
    customer_unique_id VARCHAR2(32) NOT NULL,
    customer_zip_code_prefix NUMBER(10),
    customer_city VARCHAR2(100),
    customer_state CHAR(2)
);

CREATE TABLE sellers (
    seller_id VARCHAR2(32) PRIMARY KEY,
    seller_zip_code_prefix NUMBER(10),
    seller_city VARCHAR2(100),
    seller_state CHAR(2)
);

CREATE TABLE products (
    product_id VARCHAR2(32) PRIMARY KEY,
    product_category_name VARCHAR2(100),
    product_name_length NUMBER(10),
    product_description_length NUMBER(10,2),
    product_photos_qty NUMBER(10,2),
    product_weight_g NUMBER(10,2),
    product_length_cm NUMBER(10,2),
    product_height_cm NUMBER(10,2),
    product_width_cm NUMBER(10,2)  
);

CREATE TABLE orders (
    order_id VARCHAR2(32) PRIMARY KEY,
    customer_id VARCHAR2(32) NOT NULL,
    order_status VARCHAR2(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date DATE,
    delivery_days NUMBER,
    approval_hours NUMBER,
    delivery_delay_days NUMBER
);

CREATE TABLE order_items (
    order_id VARCHAR2(32) NOT NULL,
    order_item_id NUMBER(10) NOT NULL,
    product_id VARCHAR2(32),
    seller_id VARCHAR2(32),
    shipping_limit_date DATE,
    price NUMBER(12,2),
    freight_value NUMBER(12,2),
    total_item_value NUMBER(12,2),
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE order_payments (
    order_id VARCHAR2(32) NOT NULL,
    payment_sequential NUMBER(10) NOT NULL,
    payment_type VARCHAR2(30),
    payment_installments NUMBER(10),
    payment_value NUMBER(12,2),
    installment_group VARCHAR2(30),
    PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE order_reviews (
    review_id VARCHAR2(32) PRIMARY KEY,
    order_id VARCHAR2(32) NOT NULL,
    review_score NUMBER(2),
    review_comment_title VARCHAR2(500),
    review_comment_message VARCHAR2(1000),
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    has_title VARCHAR2(10),
    has_comment VARCHAR2(10)
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix NUMBER(10),
    geolocation_lat NUMBER(18,14),
    geolocation_lng NUMBER(18,14),
    geolocation_city VARCHAR2(100),
    geolocation_state CHAR(2)
);