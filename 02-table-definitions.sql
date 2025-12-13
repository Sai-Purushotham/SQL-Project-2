-- ============================================================================
-- SMART INVENTORY & SALES MANAGEMENT SYSTEM
-- File 2: Table Definitions
-- ============================================================================

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    city VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_phone_length CHECK (LENGTH(phone) >= 10)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    supplier_id INT NOT NULL,
    category VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_price CHECK (price > 0),
    CONSTRAINT chk_stock CHECK (stock >= 0),
    INDEX idx_supplier_id (supplier_id),
    INDEX idx_product_name (name),
    INDEX idx_category (category)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    city VARCHAR(50),
    country VARCHAR(50),
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_customer_email CHECK (email LIKE '%@%.%'),
    INDEX idx_customer_email (email),
    INDEX idx_customer_name (name)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    sale_date DATE NOT NULL,
    total_amount DECIMAL(12, 2) DEFAULT 0.00,
    payment_status ENUM('Pending', 'Completed', 'Cancelled') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_total_amount CHECK (total_amount >= 0),
    INDEX idx_customer_id (customer_id),
    INDEX idx_sale_date (sale_date),
    INDEX idx_sale_date_id (sale_date, sale_id)
);

CREATE TABLE sales_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    line_total DECIMAL(12, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_quantity CHECK (quantity > 0),
    CONSTRAINT chk_unit_price CHECK (unit_price > 0),
    CONSTRAINT chk_line_total CHECK (line_total > 0),
    INDEX idx_sale_id (sale_id),
    INDEX idx_product_id (product_id)
);

CREATE TABLE inventory_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    old_stock INT NOT NULL,
    new_stock INT NOT NULL,
    change_type ENUM('Purchase', 'Sale', 'Adjustment', 'Return') NOT NULL,
    quantity_changed INT NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_action VARCHAR(50),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_product_id (product_id),
    INDEX idx_change_date (change_date),
    INDEX idx_product_date (product_id, change_date)
);