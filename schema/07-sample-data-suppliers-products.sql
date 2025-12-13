-- ============================================================================
-- SMART INVENTORY & SALES MANAGEMENT SYSTEM
-- File 7: Sample Data - Suppliers & Products
-- ============================================================================

INSERT INTO suppliers (name, phone, email, city) VALUES
('TechSupply Inc', '1234567890', 'contact@techsupply.com', 'New York'),
('Global Traders', '0987654321', 'info@globaltraders.com', 'Los Angeles'),
('Premium Goods Co', '5555555555', 'sales@premiumgoods.com', 'Chicago'),
('FastShip Logistics', '4444444444', 'support@fastship.com', 'Houston'),
('Quality Products Ltd', '3333333333', 'hello@qualityproducts.com', 'Phoenix');

INSERT INTO products (name, price, stock, supplier_id, category, description) VALUES
('Laptop Pro 15', 1299.99, 45, 1, 'Electronics', 'High-performance laptop with 15-inch display'),
('Wireless Mouse', 29.99, 150, 1, 'Electronics', 'Ergonomic wireless mouse with USB receiver'),
('USB-C Cable', 12.99, 300, 2, 'Accessories', 'Durable 2-meter USB-C charging cable'),
('Mechanical Keyboard', 89.99, 80, 1, 'Electronics', 'RGB mechanical gaming keyboard'),
('Monitor Stand', 49.99, 120, 3, 'Accessories', 'Adjustable monitor stand for 24-32 inch screens'),
('Phone Case', 19.99, 200, 4, 'Accessories', 'Premium silicone phone case'),
('Screen Protector', 9.99, 500, 2, 'Accessories', 'Tempered glass screen protector'),
('Webcam HD', 59.99, 90, 1, 'Electronics', '1080p HD webcam for streaming'),
('Headphones', 79.99, 110, 5, 'Electronics', 'Noise-cancelling over-ear headphones'),
('Desk Lamp', 39.99, 75, 3, 'Accessories', 'LED desk lamp with adjustable brightness');