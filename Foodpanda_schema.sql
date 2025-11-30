-- RAW TABLE

CREATE TABLE raw_foodpanda (
    customer_id        TEXT,
    gender             VARCHAR(20),
    age                VARCHAR(20),
    city               VARCHAR(100),
    signup_date        DATE,
    order_id           TEXT,
    order_date         DATE,
    restaurant_name    VARCHAR(200),
    dish_name          VARCHAR(200),
    category           VARCHAR(100),
    quantity           INT,
    price              DECIMAL(10,2),
    payment_method     VARCHAR(50),
    order_frequency    INT,
    last_order_date    DATE,
    loyalty_points     INT,
    churned            VARCHAR(20),
    rating             INT,
    rating_date        DATE,
    delivery_status    VARCHAR(50)
);

-- Import csv dataset into the raw table

select * from raw_foodpanda;

-- 5 Normalized Relational Tables

-- Table 1: CUSTOMERS
CREATE TABLE customers (
    customer_id     TEXT PRIMARY KEY,
    gender          VARCHAR(20),
    age_group       VARCHAR(20),
    city            VARCHAR(100),
    signup_date     DATE,
    order_frequency INT,
    last_order_date DATE,
    loyalty_points  INT,
    churned         VARCHAR(20)
);

-- Table 2: RESTAURANTS
CREATE TABLE restaurants (
    restaurant_id      SERIAL PRIMARY KEY,
    restaurant_name    VARCHAR(200) UNIQUE
);

-- Table 3: DISHES
CREATE TABLE dishes (
    dish_id      SERIAL PRIMARY KEY,
    dish_name    VARCHAR(200),
    category     VARCHAR(100),
    restaurant_id INT,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

-- Table 4: ORDERS
CREATE TABLE orders (
    order_id        TEXT PRIMARY KEY,
    customer_id     TEXT,
    restaurant_id   INT,
    order_date      DATE,
    quantity        INT,
    price           DECIMAL(10,2),
    payment_method  VARCHAR(50),
    delivery_status VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

-- Table 5: RATINGS
CREATE TABLE ratings (
    rating_id     SERIAL PRIMARY KEY,
    order_id      TEXT,
    rating        INT,
    rating_date   DATE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Insert data into the normalized tables from raw_foodpanda.

-- Insert into CUSTOMERS
INSERT INTO customers (customer_id, gender, age_group, city, signup_date,
                       order_frequency, last_order_date, loyalty_points, churned)
SELECT DISTINCT
    customer_id, gender, age, city, signup_date,
    order_frequency, last_order_date, loyalty_points, churned
FROM raw_foodpanda;

select * from customers;

-- Insert into RESTAURANTS
INSERT INTO restaurants (restaurant_name)
SELECT DISTINCT restaurant_name
FROM raw_foodpanda;

select * from restaurants;

-- Insert into DISHES
INSERT INTO dishes (dish_name, category, restaurant_id)
SELECT DISTINCT
    rfp.dish_name,
    rfp.category,
    r.restaurant_id
FROM raw_foodpanda rfp
JOIN restaurants r
    ON r.restaurant_name = rfp.restaurant_name;

select * from dishes;

-- Insert into ORDERS
INSERT INTO orders (order_id, customer_id, restaurant_id, order_date, 
                    quantity, price, payment_method, delivery_status)
SELECT DISTINCT
    rfp.order_id,
    rfp.customer_id,
    r.restaurant_id,
    rfp.order_date,
    rfp.quantity,
    rfp.price,
    rfp.payment_method,
    rfp.delivery_status
FROM raw_foodpanda rfp
JOIN restaurants r
    ON r.restaurant_name = rfp.restaurant_name;

select * from orders;

-- Insert into RATINGS
INSERT INTO ratings (order_id, rating, rating_date)
SELECT DISTINCT
    order_id,
    rating,
    rating_date
FROM raw_foodpanda
WHERE rating IS NOT NULL;

select * from ratings;
