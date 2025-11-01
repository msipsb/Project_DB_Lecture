-- Location of file -> 'D:/SIIT/Project_DB_Lecture/data_sampled/orders_sampled_filtered.csv'
-- insert orders_sampled_filtered.csv data into orders table
LOAD DATA LOCAL INFILE 'D:/SIIT/Project_DB_Lecture/data_sampled_2/orders_sampled_filtered_mapped.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_ID, customer_ID, eval_set, order_number, order_dow, order_hour_of_day, @days)
SET days_since_prior_order = NULLIF(TRIM(@days), '');



-- Location of file -> 'D:/SIIT/Project_DB_Lecture/data_sampled/products_with_retailer.csv'
-- insert products_with_retailer.csv data into products table
LOAD DATA LOCAL INFILE 'D:/SIIT/Project_DB_Lecture/data_sampled_2/products_filtered_plus500_mapped_with_retailer.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Location of file -> 'D:/SIIT/Project_DB_Lecture/data_sampled/order_products_combined_filtered.csv'
-- insert order_products_combined_filtered.csv data into order_products table
LOAD DATA LOCAL INFILE 'D:/SIIT/Project_DB_Lecture/data_sampled_2/order_products_with_review_mapped_final.csv'
INTO TABLE order_products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


LOAD DATA LOCAL INFILE 'D:/SIIT/Project_DB_Lecture/data_random/inventory_record.csv'
INTO TABLE inventory_record
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;