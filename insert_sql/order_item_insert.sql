CREATE TABLE order_items (
    order_id CHAR(32) NOT NULL,
    order_item_id INT NOT NULL,
    product_id CHAR(32) NOT NULL,
    seller_id CHAR(32) NOT NULL,
    shipping_limit_date DATETIME NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    freight_value DECIMAL(10, 2) NOT NULL,
    total_item_value DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, order_item_id)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'   -- Bypasses hidden Windows line endings
IGNORE 1 LINES;

SELECT COUNT(*) FROM order_items;

SELECT * FROM order_items LIMIT 5;