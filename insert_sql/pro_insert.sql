CREATE TABLE products (
    product_id CHAR(32) NOT NULL,
    product_category_name VARCHAR(50) NOT NULL,
    product_name_length INT NOT NULL,
    product_description_length INT NULL,       -- Set to NULL to handle empty values
    product_photos_qty INT NULL,               -- Set to NULL to handle empty values
    product_weight_g FLOAT NULL,
    product_length_cm FLOAT NULL,
    product_height_cm FLOAT NULL,
    product_width_cm FLOAT NULL,
    PRIMARY KEY (product_id)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'   -- Bypasses hidden Windows formatting artifacts
IGNORE 1 LINES
-- Read potentially empty rows into temporary variable buckets
(product_id, product_category_name, product_name_length, @v_desc_len, @v_photos_qty, @v_weight, @v_length, @v_height, @v_width)
-- Apply transformation rules: if the field is empty, set it to NULL, otherwise keep the value
SET 
    product_description_length = IF(@v_desc_len = '', NULL, @v_desc_len),
    product_photos_qty = IF(@v_photos_qty = '', NULL, @v_photos_qty),
    product_weight_g = IF(@v_weight = '', NULL, @v_weight),
    product_length_cm = IF(@v_length = '', NULL, @v_length),
    product_height_cm = IF(@v_height = '', NULL, @v_height),
    product_width_cm = IF(@v_width = '', NULL, @v_width);
    
SELECT COUNT(*) FROM products;

SELECT * FROM products LIMIT 5;