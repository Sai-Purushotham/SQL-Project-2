-- ============================================================================
-- SMART INVENTORY & SALES MANAGEMENT SYSTEM
-- File 8: Sample Data - Customers, Sales & Sales Items
-- ============================================================================

INSERT INTO customers (name, email, phone, city, country) VALUES
('John Doe', 'john@example.com', '2123456789', 'New York', 'USA'),
('Jane Smith', 'jane@example.com', '2129876543', 'Los Angeles', 'USA'),
('Robert Johnson', 'robert@example.com', '3125551234', 'Chicago', 'USA'),
('Mary Williams', 'mary@example.com', '7135559876', 'Houston', 'USA'),
('Michael Brown', 'michael@example.com', '6025552345', 'Phoenix', 'USA'),
('Sarah Davis', 'sarah@example.com', '2023456789', 'Washington', 'USA'),
('David Martinez', 'david@example.com', '2155559999', 'Philadelphia', 'USA'),
('Emily Wilson', 'emily@example.com', '7025551111', 'Las Vegas', 'USA');

INSERT INTO sales (customer_id, sale_date, payment_status) VALUES
(1, '2025-11-20', 'Completed'),
(2, '2025-11-19', 'Completed'),
(3, '2025-11-18', 'Completed'),
(4, '2025-11-17', 'Completed'),
(5, '2025-11-16', 'Completed'),
(6, '2025-11-15', 'Pending'),
(7, '2025-11-14', 'Completed'),
(1, '2025-11-20', 'Completed');

INSERT INTO sales_items (sale_id, product_id, quantity, unit_price, line_total) VALUES
(1, 1, 1, 1299.99, 1299.99),
(1, 2, 2, 29.99, 59.98),
(2, 3, 5, 12.99, 64.95),
(2, 4, 1, 89.99, 89.99),
(3, 5, 2, 49.99, 99.98),
(3, 6, 3, 19.99, 59.97),
(4, 7, 10, 9.99, 99.90),
(4, 8, 1, 59.99, 59.99),
(5, 9, 2, 79.99, 159.98),
(5, 10, 1, 39.99, 39.99),
(6, 1, 1, 1299.99, 1299.99),
(6, 2, 1, 29.99, 29.99),
(7, 3, 2, 12.99, 25.98),
(8, 4, 3, 89.99, 269.97);