-- COMMENT: This SQL script creates a database named 'DB_Lecture_Project' if it does not already exist, and then sets it as the current database for subsequent operations.
CREATE DATABASE IF NOT EXISTS DB_Lecture_Project;
USE DB_Lecture_Project;

-- 1st table creations
-- COMMENT: This SQL statement creates a table named 'aisles' with two columns: 'aisle_ID' and 'aisle'. The 'aisle_ID' column is defined as an integer that auto-increments and serves as the primary key, while the 'aisle' column is defined as a variable character string with a maximum length of 100 characters and cannot be null.
CREATE TABLE IF NOT EXISTS aisles (
    aisle_ID INT unsigned not null AUTO_INCREMENT,
    aisle VARCHAR(50) NOT NULL,
    constraint PK_aisles primary key (aisle_ID)
);

-- 2nd table creations
-- COMMENT: This SQL statement creates a table named 'departments' with two columns: 'department_ID' and 'department'. The 'department_ID' column is defined as an integer that auto-increments and serves as the primary key, while the 'department' column is defined as a variable character string with a maximum length of 20 characters and cannot be null.
CREATE TABLE IF NOT EXISTS departments (
    department_ID INT unsigned not null AUTO_INCREMENT,
    department VARCHAR(20) NOT NULL,
    constraint PK_departments primary key (department_ID)
);

-- 3rd table creations
-- COMMENT: This SQL statement creates a table named 'customer' with various columns to store customer information, including
CREATE TABLE IF NOT EXISTS customer (
    customer_ID INT unsigned not null AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other', 'Preferred not to say') NOT NULL,
    registration_date DATETIME NOT NULL,
    last_login_date DATETIME,
    nationality VARCHAR(50) NOT NULL, -- ???
    constraint PK_customers primary key (customer_ID),
    constraint UQ_customer_email UNIQUE (email)
);

-- 4th table creations
-- COMMENT: This SQL statement creates a table named 'loyalty_membership' with various columns to store loyalty membership information, including a foreign key reference to the 'customer' table.
CREATE TABLE IF NOT EXISTS loyalty_membership (
    membership_ID INT unsigned not null AUTO_INCREMENT,
    customer_ID INT unsigned not null,
    tier_level ENUM('Bronze', 'Silver', 'Gold') NOT NULL,
    points_balance INT unsigned NOT NULL,
    enrollment_date DATETIME NOT NULL default CURRENT_TIMESTAMP,
    expiration_date DATETIME,
    status ENUM('Active', 'Expired') NOT NULL,
    primary key (membership_ID, customer_ID),
    CONSTRAINT FK_loyalty_membership_customer FOREIGN KEY (customer_ID) REFERENCES customer(customer_ID)
);

-- 5th table creations
-- COMMENT: This SQL statement creates a table named 'bronze' with a foreign key reference to the 'loyalty_membership' table.
CREATE TABLE IF NOT EXISTS bronze (
    membership_ID INT unsigned not null,
    birthday_point INT unsigned not null,
    constraint PK_bronze primary key (membership_ID),
    CONSTRAINT FK_bronze_loyalty_membership FOREIGN KEY (membership_ID) REFERENCES loyalty_membership(membership_ID)
);

-- 6th table creations
-- COMMENT: This SQL statement creates a table named 'silver' with a foreign key reference to the 'bronze' table.
CREATE table if not exists silver (
    membership_ID INT unsigned not null,
    discount_percent INT unsigned not null,
    constraint PK_silver primary key (membership_ID),
    CONSTRAINT FK_silver_bronze FOREIGN KEY (membership_ID) REFERENCES bronze(membership_ID)
);

-- 7th table creations
-- COMMENT: This SQL statement creates a table named 'gold' with a foreign key reference to the 'silver' table.
CREATE TABLE IF NOT EXISTS gold (
    membership_ID INT unsigned not null,
    surprise_gift ENUM('Airplane Ticket', 'Gift Card', 'Promotion Code') NOT NULL,
    constraint PK_gold primary key (membership_ID),
    CONSTRAINT FK_gold_silver FOREIGN KEY (membership_ID) REFERENCES silver(membership_ID)
);

-- 8th table creations
-- COMMENT: This SQL statement creates a table named 'retailer' with various columns to store retailer information, including a foreign key reference to the 'customer' table.
CREATE TABLE IF NOT EXISTS retailer (
    retailer_ID INT unsigned not null,
    status ENUM('Active', 'Inactive') NOT NULL,
    account_number VARCHAR(20) NOT NULL,
    account_name VARCHAR(100) NOT NULL,
    constraint PK_retailer primary key (retailer_ID),
    CONSTRAINT FK_retailer_customer FOREIGN KEY (retailer_ID) REFERENCES customer(customer_ID)
);

-- 9th table creations
-- COMMENT: This SQL statement creates a table named 'review' with various columns to store review information, including a constraint to ensure the rating is within a valid range.
CREATE TABLE IF NOT EXISTS review (
    review_ID INT unsigned not null AUTO_INCREMENT,
    rating INT NOT NULL,
    review_text VARCHAR(255),
    review_date DATETIME NOT NULL default CURRENT_TIMESTAMP,
    constraint PK_reviews primary key (review_ID),
    CONSTRAINT chk_rating_range CHECK (rating BETWEEN 1 AND 5)
);

-- 10th table creations
-- COMMENT: This SQL statement creates a table named 'orders' with various columns to store order information, including constraints to ensure valid ranges for certain fields.
CREATE TABLE IF NOT EXISTS orders (
    order_ID INT unsigned not null AUTO_INCREMENT,
    customer_ID INT unsigned not null,
    eval_set ENUM('train','prior','test') NOT NULL,
    order_number INT unsigned NOT NULL,
    order_dow INT NOT NULL,
    order_hour_of_day INT NOT NULL,
    days_since_prior_order Float,
    constraint PK_orders primary key (order_ID),
    CONSTRAINT FK_orders_customer FOREIGN KEY (customer_ID) REFERENCES customer(customer_ID),
    CONSTRAINT chk_order_dow_range CHECK (order_dow BETWEEN 0 AND 6),
    CONSTRAINT chk_order_hour_of_day_range CHECK (order_hour_of_day BETWEEN 0 AND 23)
);

-- 11th table creations
-- COMMENT: This SQL statement creates a table named 'products' with various columns to store product information, including foreign key references to the 'aisles', 'departments', and 'retailer' tables.
CREATE TABLE IF NOT EXISTS products (
    product_ID INT unsigned not null AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    aisle_ID INT unsigned NOT NULL,
    department_ID INT unsigned NOT NULL,
    retailer_ID INT unsigned NOT NULL,
    constraint PK_products primary key (product_ID),
    CONSTRAINT FK_products_aisles FOREIGN KEY (aisle_ID) REFERENCES aisles(aisle_ID),
    CONSTRAINT FK_products_departments FOREIGN KEY (department_ID) REFERENCES departments(department_ID),
    CONSTRAINT FK_products_retailer FOREIGN KEY (retailer_ID) REFERENCES retailer(retailer_ID)
);

-- 12th table creations
-- COMMENT: This SQL statement creates a table named 'order_products' to establish a many-to-many relationship between orders and products, including additional details about the order.
CREATE TABLE IF NOT EXISTS order_products (
    order_ID INT unsigned not null,
    product_ID INT unsigned not null,
    review_ID INT unsigned not null,
    add_to_cart_order INT unsigned NOT NULL,
    reordered INT NOT NULL,
    primary key (order_ID, product_ID, review_ID),
    constraint FK_order_products_review FOREIGN KEY (review_ID) REFERENCES review(review_ID),
    CONSTRAINT FK_order_products_orders FOREIGN KEY (order_ID) REFERENCES orders(order_ID),
    CONSTRAINT FK_order_products_products FOREIGN KEY (product_ID) REFERENCES products(product_ID)
);

-- 13th table creations
-- COMMENT: This SQL statement creates a table named 'inventory_record' with various columns to store inventory information, including a foreign key reference to the 'products' table.
CREATE TABLE IF NOT EXISTS inventory_record (
    inventory_ID INT unsigned not null AUTO_INCREMENT,
    product_ID INT unsigned not null,
    quantity_on_hand INT unsigned NOT NULL,
    quantity_reserved INT unsigned NOT NULL,
    quantity_available INT unsigned NOT NULL,
    reorder_level INT unsigned NOT NULL,
    reorder_quantity INT unsigned NOT NULL,
    last_restock_date DATETIME,
    inventory_status ENUM('In Stock', 'Out of Stock', 'backordered') NOT NULL,
    lot_number VARCHAR(50),
    storage_conditions VARCHAR(100),
    constraint PK_inventory_records primary key (inventory_ID),
    CONSTRAINT FK_inventory_records_products FOREIGN KEY (product_ID) REFERENCES products(product_ID)
);

-- 14th table creations
-- COMMENT: This SQL statement creates a table named 'promotion' with various columns to store promotion information, including a foreign key reference to the 'products' table.
CREATE TABLE IF NOT EXISTS promotion (
    code VARCHAR(20) not null,
    product_ID INT unsigned not null,
    remaining INT unsigned,
    description VARCHAR(255),
    discount_type ENUM('Percentage', 'Fixed Amount') NOT NULL,
    discount_value Float NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    constraint PK_promotion primary key (code),
    CONSTRAINT FK_promotion_products FOREIGN KEY (product_ID) REFERENCES products(product_ID)
);

-- 15th table creations
-- COMMENT: This SQL statement creates a table named 'payment_transaction' with various columns to store payment transaction information, including foreign key references to the 'orders' and 'customer' tables.
CREATE TABLE IF NOT EXISTS payment_transaction (
    payment_ID INT unsigned not null AUTO_INCREMENT,
    order_ID INT unsigned not null,
    customer_ID INT unsigned not null,
    amount Float NOT NULL,
    payment_date DATETIME NOT NULL,
    status ENUM('Successful', 'Failed', 'Pending') NOT NULL,
    constraint PK_payment_transaction primary key (payment_ID),
    CONSTRAINT FK_payment_transaction_orders FOREIGN KEY (order_ID) REFERENCES orders(order_ID),
    CONSTRAINT FK_payment_transaction_retailer FOREIGN KEY (customer_ID) REFERENCES retailer(retailer_ID)
);

-- 16th table creations
-- COMMENT: This SQL statement creates a table named 'invoice' with various columns to store invoice information, including foreign key references to the 'orders' and 'customer' tables.
CREATE TABLE IF NOT EXISTS invoice (
    invoice_ID INT unsigned not null AUTO_INCREMENT,
    order_ID INT unsigned not null,
    customer_ID INT unsigned not null,
    invoice_date DATETIME NOT NULL default CURRENT_TIMESTAMP,
    due_date DATETIME NOT NULL,
    total_amount Float NOT NULL,
    tax_amount Float NOT NULL,
    discount_amount Float,
    status ENUM('Paid', 'Unpaid', 'Overdue') NOT NULL,
    created_at DATETIME NOT NULL default CURRENT_TIMESTAMP,
    updated_at DATETIME,
    note VARCHAR(255),
    primary key (invoice_ID, order_ID, customer_ID),
    CONSTRAINT FK_invoice_orders FOREIGN KEY (order_ID) REFERENCES orders(order_ID),
    CONSTRAINT FK_invoice_customer FOREIGN KEY (customer_ID) REFERENCES customer(customer_ID)
);

-- 17th table creations
-- COMMENT: This SQL statement creates a table named 'delivery' with various columns to store delivery information, including a foreign key reference to the 'orders' table.
CREATE TABLE IF NOT EXISTS delivery (
    delivery_ID INT unsigned not null AUTO_INCREMENT,
    order_ID INT unsigned not null,
    scheduled_date DATETIME NOT NULL,
    actual_delivery_date DATETIME,
    status ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled') NOT NULL,
    constraint PK_delivery primary key (delivery_ID),
    CONSTRAINT FK_delivery_orders FOREIGN KEY (order_ID) REFERENCES orders(order_ID)
);

-- 18th table creations
-- COMMENT: This SQL statement creates a table named 'address' with various columns to store address
CREATE TABLE IF NOT EXISTS address (
    address_ID INT unsigned not null AUTO_INCREMENT,
    customer_ID INT unsigned not null,
    house_number VARCHAR(20) NOT NULL,
    street VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    province VARCHAR(50) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    country VARCHAR(50) NOT NULL,
    primary key (address_ID, customer_ID, house_number, street, city, province, postal_code, country),
    CONSTRAINT FK_address_customer FOREIGN KEY (customer_ID) REFERENCES customer(customer_ID)
);