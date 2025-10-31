-- Location of file -> 'D:/SIIT/Project_DB_Lecture/data_sampled/aisles.csv'
-- insert aisles.csv data into aisles table
LOAD DATA LOCAL INFILE 'data_sampled_2/aisles.csv'
INTO TABLE aisles
CHARACTER SET 'utf8mb4'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Location of file -> 'D:/SIIT/Project_DB_Lecture/data_sampled/departments.csv'
-- insert departments.csv data into departments table
LOAD DATA LOCAL INFILE 'D:/SIIT/Project_DB_Lecture/data_sampled/departments.csv'
INTO TABLE departments
CHARACTER SET 'utf8mb4'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Location of file -> 'D:/SIIT/Project_DB_Lecture/data_sampled/orders_sampled_filtered.csv'
-- insert orders_sampled_filtered.csv data into orders table
LOAD DATA LOCAL INFILE 'D:/SIIT/Project_DB_Lecture/data_sampled/orders_sampled_filtered.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, eval_set, order_number, order_dow, order_hour_of_day, days_since_prior_order)
SET
  days_since_prior_order = NULLIF(days_since_prior_order, '');

-- Location of file -> 'D:/SIIT/Project_DB_Lecture/data_sampled/products_with_retailer.csv'
-- insert products_with_retailer.csv data into products table
LOAD DATA LOCAL INFILE 'D:/SIIT/Project_DB_Lecture/data_sampled/products_with_retailer.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Location of file -> 'D:/SIIT/Project_DB_Lecture/data_sampled/order_products_combined_filtered.csv'
-- insert order_products_combined_filtered.csv data into order_products table
LOAD DATA LOCAL INFILE 'D:/SIIT/Project_DB_Lecture/data_sampled/order_products_combined_filtered.csv'
INTO TABLE order_products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;