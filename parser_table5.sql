LOAD DATA LOCAL INFILE 'D:/SIIT/Project_DB_Lecture/data_random/payment_transaction.csv'
INTO TABLE payment_transaction
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(payment_ID, order_ID, customer_ID, payment_method, amount, currency, payment_date, @status)
SET status = TRIM(@status);


LOAD DATA LOCAL INFILE 'D:/SIIT/Project_DB_Lecture/data_random/invoice.csv'
INTO TABLE invoice
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(invoice_ID,order_ID,customer_ID,invoice_date,due_date,total_amount,tax_amount,discount_amount,status,created_at,@updated_at,note)
SET
  note = NULLIF(note, ''),
  updated_at = NULLIF(@updated_at, '');


LOAD DATA LOCAL INFILE 'D:/SIIT/Project_DB_Lecture/data_random/delivery.csv'
INTO TABLE delivery
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(delivery_ID,order_ID,scheduled_date,@actual_delivery_date,@status)
SET
  actual_delivery_date = NULLIF(@actual_delivery_date, ''),
  status = TRIM(@status);
