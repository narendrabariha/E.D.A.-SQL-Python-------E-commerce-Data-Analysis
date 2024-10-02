-- E-commerce Sales Analysis


Create database ecommerce;



-- BASIC Queries
-- 1. Find the number of unique states and their names from the database.
SELECT DISTINCT customer_state 
FROM customers;

SELECT COUNT(DISTINCT customer_state) AS state_count 
FROM customers;


-- 2. Find the number of unique cities and their names from the database.
SELECT DISTINCT customer_city 
FROM customers;

SELECT COUNT(DISTINCT customer_city) AS city_count 
FROM customers;



-- 3. List all unique cities where customers are located.
SELECT DISTINCT customer_city 
FROM customers;



-- 4. Count the number of orders placed in 2017.?
SELECT COUNT(order_id) 
FROM orders 
WHERE YEAR(order_purchase_timestamp) = 2017;



-- 5. Find the total sales per category.?
SELECT UPPER(products.product_category) AS category, 
       ROUND(SUM(payments.payment_value), 2) AS sales
FROM products 
JOIN order_items ON products.product_id = order_items.product_id
JOIN payments ON payments.order_id = order_items.order_id
GROUP BY category;



-- 6. Calculate the percentage of orders that were paid in installments.?
SELECT ((SUM(CASE WHEN payment_installments >= 1 THEN 1 ELSE 0 END) / COUNT(*)) * 100) AS percentage
FROM payments;



-- 7. Count the number of customers from each state.?
SELECT customer_state, COUNT(customer_id) AS Customer_Count
FROM customers
GROUP BY customer_state
ORDER BY Customer_Count DESC;

 
 
 -- 8. Count customers by city and state.
SELECT customer_city, customer_state, COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers
GROUP BY customer_city, customer_state
ORDER BY unique_customers DESC;



-- 9. What is the total number of orders placed in each month?
SELECT 
    MONTH(order_purchase_timestamp) AS month,
    COUNT(order_id) AS total_orders
FROM 
    orders
GROUP BY 
    MONTH(order_purchase_timestamp)
ORDER BY month ;



-- 10. Identify the order with the highest total value.
SELECT 
    orders.order_id,
    SUM(payments.payment_value) AS total_value
FROM 
    orders 
JOIN 
    payments ON orders.order_id = payments.order_id
GROUP BY 
    orders.order_id
ORDER BY 
    total_value DESC
LIMIT 1;



-- 11. How many orders were placed by each customer?
SELECT 
    customer_id,
    COUNT(order_id) AS total_orders
FROM 
    orders
GROUP BY 
    customer_id
ORDER BY total_orders;



-- 12. What percentage of orders use each payment type?
DESCRIBE payments;

SELECT payment_type, 
       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM payments) AS percentage
FROM payments
GROUP BY payment_type;



-- 13.What is the average order value for each payment type?
SELECT payment_type, 
       AVG(payments.payment_value) AS avg_order_value
FROM payments
JOIN orders ON payments.order_id = orders.order_id
GROUP BY payment_type;



-- 14. Which payment type contributes the most to the total revenue
SELECT payment_type, 
       SUM(payments.payment_value) AS total_revenue
FROM payments
GROUP BY payment_type
ORDER BY total_revenue DESC;



-- 15. How does the frequency of each payment type change over time (monthly/yearly)?
SELECT YEAR(orders.order_purchase_timestamp) AS year, 
       payment_type, 
       COUNT(*) AS order_count
FROM payments
JOIN orders ON payments.order_id = orders.order_id
GROUP BY year, payment_type
ORDER BY year, payment_type;



-- 16. What percentage of orders are made using undefined payment methods (not_defined)?
SELECT COUNT(*) * 100.0 / (SELECT COUNT(*) FROM payments) AS undefined_percentage
FROM payments
WHERE payment_type = 'not_defined';



-- 17. which city and state customers use specific payment methods such as credit_card, UPI, voucher, debit_card, and not_defined to purchase products
SELECT 
    customers.customer_city AS city, 
    customers.customer_state AS state,
    payments.payment_type, 
    COUNT(*) AS order_count
FROM customers
JOIN orders 
    ON customers.customer_id = orders.customer_id
JOIN payments 
    ON orders.order_id = payments.order_id
WHERE payments.payment_type IN ('credit_card', 'UPI', 'voucher', 'debit_card', 'not_defined')
GROUP BY customers.customer_city, customers.customer_state, payments.payment_type
ORDER BY order_count DESC;



--  18. which state customers use each payment method (like credit_card, UPI, voucher, debit_card, and not_defined)
SELECT 
    customers.customer_state AS state, 
    payments.payment_type, 
    COUNT(*) AS order_count
FROM customers
JOIN orders 
    ON customers.customer_id = orders.customer_id
JOIN payments 
    ON orders.order_id = payments.order_id
WHERE payments.payment_type IN ('credit_card', 'UPI', 'voucher', 'debit_card', 'not_defined')
GROUP BY customers.customer_state, payments.payment_type
ORDER BY order_count DESC;



-- 19. Which cities have the highest number of orders?
SELECT customers.customer_city, COUNT(orders.order_id) AS total_orders
FROM orders
JOIN customers ON orders.customer_id = customers.customer_id
GROUP BY customers.customer_city
ORDER BY total_orders DESC
LIMIT 10;



-- 20. What is the Average Payment Amount per Transaction?
SELECT AVG(payment_value) AS average_payment 
FROM payments;



-- 21. List the Top 5 Products Based on Total Sales Revenue
SELECT product_id, SUM(payment_value) AS total_sales 
FROM order_items 
JOIN payments ON order_items.order_id = payments.order_id 
GROUP BY product_id 
ORDER BY total_sales DESC 
LIMIT 5;



-- 22. How Many Different Categories of Products Are Available?
DESCRIBE products;

SELECT COUNT(DISTINCT product_category) AS total_categories 
FROM products;



-- 23. Who are the Top 3 Sellers Based on Total Revenue Generated?
SELECT seller_id, SUM(payment_value) AS total_revenue
FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
JOIN payments ON orders.order_id = payments.order_id
GROUP BY seller_id
ORDER BY total_revenue DESC
LIMIT 3;



-- 24. How many products does each seller offer?
DESCRIBE sellers;
DESCRIBE sellers;

SELECT 
    sellers.seller_id, 
    sellers.seller_city, 
    COUNT(products.product_id) AS product_count 
FROM 
    sellers 
JOIN 
    order_items ON sellers.seller_id = order_items.seller_id 
JOIN 
    products ON order_items.product_id = products.product_id 
GROUP BY 
    sellers.seller_id, sellers.seller_city 
LIMIT 0, 500;



-- INTERMEDIATE Queries
-- 25. Calculate the number of orders per month in 2018.?
SELECT MONTHNAME(order_purchase_timestamp) AS months, 
       COUNT(order_id) AS order_count
FROM orders
WHERE YEAR(order_purchase_timestamp) = 2018
GROUP BY months;



-- 26. Find the average number of products per order, grouped by customer city.?
SELECT * FROM ecommerce.orders;
SELECT * FROM ecommerce.order_items;

WITH count_per_order AS (
    SELECT orders.order_id, orders.customer_id, COUNT(order_items.order_id) AS oc
    FROM orders 
    JOIN order_items 
    ON orders.order_id = order_items.order_id
    GROUP BY orders.order_id, orders.customer_id )
    
SELECT customers.customer_city, ROUND(AVG(count_per_order.oc), 2) AS average_orders
FROM customers 
JOIN count_per_order
ON customers.customer_id = count_per_order.customer_id
GROUP BY customers.customer_city 
ORDER BY average_orders DESC;



-- 27. Calculate the percentage of total revenue contributed by each product category.?
SELECT 
    UPPER(products.product_category) AS category, 
    ROUND((SUM(payments.payment_value) / (SELECT SUM(payment_value) FROM payments)) * 100,2) AS sales_percentage
FROM products 
JOIN order_items 
ON products.product_id = order_items.product_id
JOIN payments 
ON payments.order_id = order_items.order_id
GROUP BY category 
ORDER BY sales_percentage DESC;



-- 28. Identify the correlation between product price and the number of times a product has been purchased.?
SELECT * FROM ecommerce.payments;
SELECT * FROM ecommerce.orders;
SELECT * FROM ecommerce.order_items;

SELECT 
    products.product_category, 
    COUNT(order_items.product_id) AS product_count,
    ROUND(AVG(order_items.price), 2) AS avg_price
FROM products
JOIN order_items 
ON products.product_id = order_items.product_id
GROUP BY products.product_category;


WITH category_data AS (
    SELECT 
        products.product_category, 
        COUNT(order_items.product_id) AS order_count,
        ROUND(AVG(order_items.price), 2) AS avg_price
    FROM products
    JOIN order_items 
    ON products.product_id = order_items.product_id
    GROUP BY products.product_category ),
correlation_data AS (
    SELECT 
        COUNT(*) AS n,
        SUM(order_count) AS sum_order_count,
        SUM(avg_price) AS sum_avg_price,
        SUM(order_count * avg_price) AS sum_product,
        SUM(order_count * order_count) AS sum_order_count_sq,
        SUM(avg_price * avg_price) AS sum_avg_price_sq
    FROM category_data )

SELECT 
    (n * sum_product - sum_order_count * sum_avg_price) /
    (SQRT(n * sum_order_count_sq - sum_order_count * sum_order_count) * SQRT(n * sum_avg_price_sq - sum_avg_price * sum_avg_price)) AS correlation
FROM 
    correlation_data;



-- 29. Calculate the total revenue generated by each seller, and rank them by revenue ?
SELECT * FROM ecommerce.sellers;
SELECT * FROM ecommerce.order_items; 
SELECT * FROM ecommerce.payments;

SELECT *, 
       DENSE_RANK() OVER (ORDER BY revenue DESC) AS ranks
FROM (
    SELECT order_items.seller_id, 
           SUM(payments.payment_value) AS revenue 
    FROM order_items 
    JOIN payments 
    ON order_items.order_id = payments.order_id 
    GROUP BY order_items.seller_id
) AS a;



-- ADVANCED Queries
-- 30. Calculate the moving average of order values for each customer over their order history.?
SELECT * FROM ecommerce.orders;

SELECT customer_id, order_purchase_timestamp, payment,
AVG(payment) OVER(PARTITION BY customer_id ORDER BY order_purchase_timestamp
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS mov_avg
FROM (
    SELECT orders.customer_id, orders.order_purchase_timestamp, 
    payments.payment_value AS payment
    FROM payments 
    JOIN orders 
    ON payments.order_id = orders.order_id) AS a
    ORDER BY mov_avg DESC;



-- 31. Calculate the cumulative sales per month for each year.?
SELECT * FROM ecommerce.orders;

SELECT 
    years, months, payment, SUM(payment) OVER (ORDER BY years, months) AS cumulative_sales 
FROM (
    SELECT 
        YEAR(orders.order_purchase_timestamp) AS years,
        MONTH(orders.order_purchase_timestamp) AS months,
        ROUND(SUM(payments.payment_value), 2) AS payment 
    FROM orders 
    JOIN payments 
    ON orders.order_id = payments.order_id 
    GROUP BY years, months 
    ORDER BY years, months ) AS a;



-- 32. Calculate the year-over-year growth rate of total sales.?
WITH a AS (
    SELECT 
        YEAR(orders.order_purchase_timestamp) AS years, 
        ROUND(SUM(payments.payment_value), 2) AS payment 
    FROM 
        orders 
    JOIN 
        payments ON orders.order_id = payments.order_id
    GROUP BY 
        years 
    ORDER BY 
        years
)
SELECT 
    years, 
    payment AS sales,
    LAG(payment, 1) OVER (ORDER BY years) AS previous_year 
FROM 
    a;


WITH a AS (
    SELECT 
        YEAR(orders.order_purchase_timestamp) AS years,
        ROUND(SUM(payments.payment_value), 2) AS payment 
    FROM orders 
    JOIN payments 
    ON orders.order_id = payments.order_id 
    GROUP BY years 
    ORDER BY years )

SELECT 
    years, 
    ((payment - LAG(payment, 1) OVER(ORDER BY years)) / 
     LAG(payment, 1) OVER(ORDER BY years)) * 100 AS "yoy % growth" 
FROM a;



-- 33. Calculate the retention rate of customers, defined as the percentage of customers who make another purchase within 6 months of their first purchase.?
SELECT * FROM ecommerce.orders;

SELECT 
    customers.customer_id, 
    MIN(orders.order_purchase_timestamp) 
FROM 
    customers 
JOIN 
    orders 
ON 
    customers.customer_id = orders.customer_id 
GROUP BY 
    customers.customer_id;
    
    
    WITH a AS (
    SELECT 
        customers.customer_id,
        MIN(orders.order_purchase_timestamp) AS first_order
    FROM customers 
    JOIN orders 
    ON customers.customer_id = orders.customer_id
    GROUP BY customers.customer_id  ),

b AS (
    SELECT 
        a.customer_id, 
        COUNT(DISTINCT orders.order_purchase_timestamp) AS next_order
    FROM a 
    JOIN orders 
    ON orders.customer_id = a.customer_id
    AND orders.order_purchase_timestamp > first_order
    AND orders.order_purchase_timestamp < DATE_ADD(first_order, INTERVAL 6 MONTH)
    GROUP BY a.customer_id )

SELECT  100 * (COUNT(DISTINCT a.customer_id) / COUNT(DISTINCT b.customer_id))  AS Retention_Rate_Of_customer 
FROM a 
LEFT JOIN b 
ON a.customer_id = b.customer_id;



-- 34. Identify the top 3 customers who spent the most money in each year.?
SELECT * FROM ecommerce.payments;
SELECT * FROM ecommerce.orders;
select count(order_id) from payments;
select count(distinct order_id) from payments;


SELECT years, customer_id, payment, d_rank
FROM
    (SELECT 
        YEAR(orders.order_purchase_timestamp) AS years,
        orders.customer_id,
        SUM(payments.payment_value) AS payment,
        DENSE_RANK() OVER (PARTITION BY YEAR(orders.order_purchase_timestamp)
                           ORDER BY SUM(payments.payment_value) DESC) AS d_rank
     FROM orders 
     JOIN payments 
     ON payments.order_id = orders.order_id
     GROUP BY YEAR (orders.order_purchase_timestamp), orders.customer_id ) AS a
WHERE  d_rank <= 3;





-- --------------------------------------------------------------------------------------------------------------------------