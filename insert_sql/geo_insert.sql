CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT NOT NULL,
    geolocation_lat DECIMAL(10, 8) NOT NULL,
    geolocation_lng DECIMAL(11, 8) NOT NULL,
    geolocation_city VARCHAR(50) NOT NULL,
    geolocation_state CHAR(2) NOT NULL
);

SHOW VARIABLES LIKE 'secure_file_priv';

-- 1. Turn off indexing temporarily to maximize import speed
ALTER TABLE geolocation DISABLE KEYS;

-- 2. Execute the bulk load
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/geolocation.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'  -- Use '\r\n' if saved on a Windows machine
IGNORE 1 LINES;

-- 3. Re-enable indexes now that the data is loaded
ALTER TABLE geolocation ENABLE KEYS;

SELECT COUNT(*) FROM geolocation;

SELECT * FROM geolocation LIMIT 5;