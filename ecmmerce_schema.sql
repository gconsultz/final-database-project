-- E-commerce database schema

SET FOREIGN_KEY_CHECKS = 0;

DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_db;

SET FOREIGN_KEY_CHECKS = 1;

-- Users table
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Categories
CREATE TABLE categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT
) ENGINE=InnoDB;

-- Products
CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Many-to-many: products <-> categories
CREATE TABLE product_categories (
  product_id INT NOT NULL,
  category_id INT NOT NULL,
  PRIMARY KEY (product_id, category_id),
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Addresses for users (one-to-many)
CREATE TABLE addresses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  line1 VARCHAR(255) NOT NULL,
  line2 VARCHAR(255),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100),
  country VARCHAR(100) NOT NULL,
  postal_code VARCHAR(50),
  is_default BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Orders (one order per row)
CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  address_id INT, -- shipping address (nullable)
  status ENUM('pending','paid','processing','shipped','completed','cancelled') NOT NULL DEFAULT 'pending',
  total DECIMAL(12,2) NOT NULL DEFAULT 0.00 CHECK (total >= 0),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (address_id) REFERENCES addresses(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Order items (many-to-many with additional fields)
CREATE TABLE order_items (
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
  PRIMARY KEY (order_id, product_id),
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Payments (one-to-one-ish: an order can have a payment record)
CREATE TABLE payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL UNIQUE,
  amount DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
  method ENUM('card','bank_transfer','paypal','cash_on_delivery') NOT NULL,
  status ENUM('pending','failed','successful','refunded') NOT NULL DEFAULT 'pending',
  paid_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Reviews: a user can review a product once
CREATE TABLE reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_user_product (user_id, product_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Useful indexes
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_orders_userid ON orders(user_id);
CREATE INDEX idx_payments_status ON payments(status);

-- Sample data inserts (small dataset)
INSERT INTO users (username, email, password_hash, first_name, last_name)
VALUES
('alice','alice@example.com','hash1','Alice','Adams'),
('bob','bob@example.com','hash2','Bob','Brown');

INSERT INTO categories (name, description) VALUES
('Electronics','Phones, laptops and accessories'),
('Books','All kinds of books'),
('Home','Home & Living');

INSERT INTO products (name, description, price, stock) VALUES
('USB-C Charger','Fast charger 25W', 19.99, 150),
('Wireless Mouse','Ergonomic mouse', 29.50, 80),
('Intro to SQL (paperback)','Beginner SQL book', 12.00, 200);

-- Link products and categories
INSERT INTO product_categories (product_id, category_id) VALUES
(1,1), -- charger -> Electronics
(2,1), -- mouse -> Electronics
(3,2); -- book -> Books

-- Address for user 1
INSERT INTO addresses (user_id, line1, city, state, country, postal_code, is_default)
VALUES (1, '12 Main St', 'Lagos', 'Lagos', 'Nigeria', '100001', TRUE);

-- Create an order for Alice (user_id = 1)
INSERT INTO orders (user_id, address_id, status, total) VALUES (1, 1, 'paid', 49.49);

-- Suppose the inserted order got id = 1, add order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 19.99),
(1, 2, 1, 29.50);

-- Record payment for the order
INSERT INTO payments (order_id, amount, method, status, paid_at) VALUES
(1, 49.49, 'card', 'successful', NOW());

-- Alice leaves a review for the mouse (product_id = 2)
INSERT INTO reviews (user_id, product_id, rating, comment) VALUES
(1, 2, 5, 'Very comfortable to use.');
