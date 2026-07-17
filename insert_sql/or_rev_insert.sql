DROP TABLE IF EXISTS order_reviews;

CREATE TABLE order_reviews (
    review_id CHAR(32) NOT NULL,
    order_id CHAR(32) NOT NULL,
    review_score INT NOT NULL,
    review_comment_title VARCHAR(100) NULL,
    review_comment_message TEXT NULL,
    review_creation_date DATETIME NOT NULL,
    review_answer_timestamp DATETIME NOT NULL,
    has_title BOOLEAN NOT NULL,
    has_comment BOOLEAN NOT NULL,
    PRIMARY KEY (review_id, order_id) -- Combined composite key
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_reviews.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(review_id, order_id, review_score, @v_title, @v_message, review_creation_date, review_answer_timestamp, @v_has_title, @v_has_comment)
SET 
    review_comment_title = IF(@v_title = '', NULL, @v_title),
    review_comment_message = IF(@v_message = '', NULL, @v_message),
    has_title = IF(@v_has_title = 'True', 1, 0),
    has_comment = IF(@v_has_comment = 'True', 1, 0);
    
SELECT COUNT(*) FROM order_reviews;

SELECT * FROM order_reviews LIMIT 5;