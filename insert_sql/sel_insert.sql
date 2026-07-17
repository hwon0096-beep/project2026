CREATE TABLE sellers (
    seller_id CHAR(32) NOT NULL,
    seller_zip_code_prefix INT NOT NULL,
    seller_city VARCHAR(50) NOT NULL,
    seller_state CHAR(2) NOT NULL,
    PRIMARY KEY (seller_id)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sellers.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'   -- Prevents hidden Windows line ending errors
IGNORE 1 LINES;

SELECT COUNT(*) FROM sellers;
-- Output should be exactly: 3095

SELECT * FROM sellers LIMIT 5;