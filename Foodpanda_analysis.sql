-- EASY LEVEL (8 QUERIES) --

-- 1) Total number of customers

SELECT COUNT(*) AS total_customers
FROM customers;

-- 2) Total number of restaurants

SELECT COUNT(*) AS total_restaurants
FROM restaurants;

-- 3) Total orders placed

SELECT COUNT(*) AS total_orders
FROM orders;

-- 4) Most common payment method

SELECT payment_method, COUNT(*)
FROM orders
GROUP BY payment_method;

-- 5) Count orders by delivery status

SELECT delivery_status, COUNT(*)
FROM orders
GROUP BY delivery_status;

-- 6) Customers by city

SELECT city, COUNT(*) AS total_customers
FROM customers
GROUP BY city;

-- 7) Average rating (overall)

SELECT ROUND (AVG(rating),3) AS avg_rating
FROM ratings;

-- 8) Count churned vs active customers

SELECT churned, COUNT(*) AS count_customers
FROM customers
GROUP BY churned;

-- INTERMEDIATE LEVEL (8 QUERIES) --

-- 9) Top 5 customers by spending

SELECT c.customer_id, SUM(o.price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 5;

-- 10) Top 5 restaurants by total revenue

SELECT r.restaurant_name, SUM(o.price) AS total_revenue
FROM orders o
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_revenue DESC
LIMIT 5;

-- 11) Top selling dishes

SELECT d.dish_name, SUM(o.quantity) AS total_sold
FROM dishes d
JOIN orders o ON d.restaurant_id = o.restaurant_id
GROUP BY d.dish_name
ORDER BY total_sold DESC;

-- 12) Average rating per restaurant

SELECT r.restaurant_name, AVG(rt.rating) AS avg_rating
FROM restaurants r
JOIN orders o ON o.restaurant_id = r.restaurant_id
JOIN ratings rt ON rt.order_id = o.order_id
GROUP BY r.restaurant_name
ORDER BY avg_rating DESC;

-- 13) City-wise total revenue

SELECT c.city, SUM(o.price) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY revenue DESC;

-- 14) Number of orders per category

SELECT d.category, SUM(o.quantity) AS items_ordered
FROM dishes d
JOIN orders o ON d.restaurant_id = o.restaurant_id
GROUP BY d.category;

-- 15) Monthly order count

SELECT TO_CHAR(order_date, 'YYYY-MM') AS month, COUNT(*) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;

-- 16) Payment method usage percentage

SELECT payment_method,
       (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders)) AS percentage
FROM orders
GROUP BY payment_method;

-- ADVANCED LEVEL (4 QUERIES) --

-- 17) Running total of monthly revenue

SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS month,
    SUM(price) AS monthly_revenue,
    SUM(SUM(price)) OVER (ORDER BY TO_CHAR(order_date, 'YYYY-MM')) AS running_total
FROM orders
GROUP BY month
ORDER BY month;

-- 18) Top 3 spending customers per city

SELECT *
FROM (
    SELECT c.customer_id, c.city, SUM(o.price) AS total_spent,
           ROW_NUMBER() OVER (PARTITION BY c.city ORDER BY SUM(o.price) DESC) AS rn
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.city
) ranked
WHERE rn <= 3;

-- 19) Identify customers who gave rating below average

SELECT c.customer_id, r.rating
FROM ratings r
JOIN orders o ON r.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE r.rating < (SELECT AVG(rating) FROM ratings);

-- 20) Find customers likely to churn

WITH order_counts AS (
    SELECT customer_id, COUNT(*) AS total_orders,
           MAX(order_date) AS last_order
    FROM orders
    GROUP BY customer_id
)
SELECT c.customer_id, c.city, c.churned, oc.total_orders, oc.last_order
FROM customers c
LEFT JOIN order_counts oc ON c.customer_id = oc.customer_id
WHERE c.churned = 'Active'
  AND (oc.total_orders < 3 OR oc.last_order < NOW() - INTERVAL '3 months')
ORDER BY oc.total_orders ASC;