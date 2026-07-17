CREATE TABLE order_payments (
    order_id CHAR(32) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(20) NOT NULL,
    payment_installments INT NOT NULL,
    payment_value DECIMAL(10, 2) NOT NULL,
    installment_group VARCHAR(10) NOT NULL,
    PRIMARY KEY (order_id, payment_sequential)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_payments.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'   -- Bypasses hidden Windows line endings safely
IGNORE 1 LINES;

SELECT COUNT(*) FROM order_payments;
-- Result should be exactly: 103886

SELECT * FROM order_payments LIMIT 5;