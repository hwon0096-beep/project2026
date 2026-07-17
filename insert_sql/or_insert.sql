CREATE TABLE orders (
    order_id CHAR(32) NOT NULL,
    customer_id CHAR(32) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    order_purchase_timestamp DATETIME NOT NULL,
    order_approved_at DATETIME NULL,
    order_delivered_carrier_date DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATE NOT NULL,
    delivery_days FLOAT NULL,
    approval_hours FLOAT NULL,
    delivery_delay_days FLOAT NULL,
    PRIMARY KEY (order_id)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
-- Read the nullable columns into temporary variables
(order_id, customer_id, order_status, order_purchase_timestamp, @v_approved, @v_carrier, @v_delivered, order_estimated_delivery_date, @v_deliv_days, @v_appr_hrs, @v_delay_days)
SET 
    -- 1. Handle missing DATETIME fields
    order_approved_at = IF(@v_approved = '', NULL, @v_approved),
    order_delivered_carrier_date = IF(@v_carrier = '', NULL, @v_carrier),
    order_delivered_customer_date = IF(@v_delivered = '', NULL, @v_delivered),
    
    -- 2. Handle missing FLOAT fields
    delivery_days = IF(@v_deliv_days = '', NULL, @v_deliv_days),
    approval_hours = IF(@v_appr_hrs = '', NULL, @v_appr_hrs),
    delivery_delay_days = IF(@v_delay_days = '', NULL, @v_delay_days);
    
SELECT COUNT(*) FROM orders;
-- Result should be: 99441

SELECT * FROM orders LIMIT 5;