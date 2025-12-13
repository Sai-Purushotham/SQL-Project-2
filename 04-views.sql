-- ============================================================================
-- SMART INVENTORY & SALES MANAGEMENT SYSTEM
-- File 4: Views (All Database Views)
-- ============================================================================

CREATE OR REPLACE VIEW v_product_inventory_status AS
SELECT p.product_id, p.name AS product_name, p.price, p.stock,
    s.name AS supplier_name, p.category,
    CASE WHEN p.stock = 0 THEN 'Out of Stock'
         WHEN p.stock < 10 THEN 'Low Stock'
         WHEN p.stock < 50 THEN 'Medium Stock'
         ELSE 'Healthy Stock' END AS stock_status
FROM products p LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id;

CREATE OR REPLACE VIEW v_sales_summary AS
SELECT s.sale_id, s.customer_id, c.name AS customer_name, c.email,
    s.sale_date, s.total_amount, s.payment_status,
    COUNT(si.item_id) AS total_items, COUNT(DISTINCT si.product_id) AS unique_products
FROM sales s
LEFT JOIN customers c ON s.customer_id = c.customer_id
LEFT JOIN sales_items si ON s.sale_id = si.sale_id
GROUP BY s.sale_id, s.customer_id, c.name, c.email, s.sale_date, s.total_amount, s.payment_status;

CREATE OR REPLACE VIEW v_top_selling_products AS
SELECT p.product_id, p.name, p.price,
    SUM(si.quantity) AS total_quantity_sold,
    SUM(si.line_total) AS total_revenue,
    COUNT(DISTINCT s.sale_id) AS number_of_sales,
    AVG(si.quantity) AS avg_quantity_per_sale
FROM products p
LEFT JOIN sales_items si ON p.product_id = si.product_id
LEFT JOIN sales s ON si.sale_id = s.sale_id
WHERE s.payment_status = 'Completed'
GROUP BY p.product_id, p.name, p.price
ORDER BY total_revenue DESC;

CREATE OR REPLACE VIEW v_customer_purchase_history AS
SELECT c.customer_id, c.name, c.email,
    COUNT(DISTINCT s.sale_id) AS total_purchases,
    COUNT(DISTINCT si.product_id) AS unique_products_bought,
    SUM(si.quantity) AS total_quantity_purchased,
    SUM(s.total_amount) AS total_spent,
    MAX(s.sale_date) AS last_purchase_date
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
LEFT JOIN sales_items si ON s.sale_id = si.sale_id
WHERE s.payment_status = 'Completed'
GROUP BY c.customer_id, c.name, c.email;

CREATE OR REPLACE VIEW v_monthly_revenue_report AS
SELECT YEAR(s.sale_date) AS year, MONTH(s.sale_date) AS month,
    DATE_FORMAT(s.sale_date, '%Y-%m') AS month_year,
    COUNT(DISTINCT s.sale_id) AS total_sales,
    SUM(s.total_amount) AS total_revenue,
    AVG(s.total_amount) AS avg_sale_value,
    COUNT(DISTINCT s.customer_id) AS unique_customers
FROM sales s
WHERE s.payment_status = 'Completed'
GROUP BY YEAR(s.sale_date), MONTH(s.sale_date), DATE_FORMAT(s.sale_date, '%Y-%m');