--
-- TEST QUERIES FOR E-COMMERCE DATABASE PROJECT
-- Author: Tijani Ridwan Oluwaseun
-- Date: September 2025
--

-- Switch to the database
USE ecommerce_db;

-- 1. Show all tables in the database
SHOW TABLES;

-- 2. Display all users
SELECT * FROM users;

-- 3. Display all products
SELECT * FROM products;

-- 4. Show all orders with related user details
SELECT o.id AS order_id, u.username, o.order_date, o.total_amount
FROM orders o
JOIN users u ON o.user_id = u.id;

-- 5. Show order items with product details
SELECT oi.order_id, p.name AS product_name, oi.quantity, oi.unit_price
FROM order_items oi
JOIN products p ON oi.product_id = p.id;

-- 6. Show payments and their corresponding orders
SELECT p.id AS payment_id, o.id AS order_id, p.amount, p.payment_date, p.payment_method
FROM payments p
JOIN orders o ON p.order_id = o.id;

-- 7. List all product reviews with user info
SELECT u.username, pr.rating, pr.comment, p.name AS product
FROM reviews pr
JOIN users u ON pr.user_id = u.id
JOIN products p ON pr.product_id = p.id;

-- 8. Show products grouped by categories
SELECT c.name AS category, COUNT(pc.product_id) AS total_products
FROM categories c
JOIN product_categories pc ON c.id = pc.category_id
GROUP BY c.name;

-- 9. Test constraint: try inserting invalid rating (should fail if constraint is active)
-- Uncomment to test
-- INSERT INTO reviews (user_id, product_id, rating, comment)
-- VALUES (1, 1, 10, 'Invalid rating test');

-- 10. Test constraint: price cannot be negative (should fail if constraint is active)
-- Uncomment to test
-- INSERT INTO products (name, description, price, stock_quantity)
-- VALUES ('Test Product', 'Should fail', -50, 10);
