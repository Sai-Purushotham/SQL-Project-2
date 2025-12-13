-- ============================================================================
-- SMART INVENTORY & SALES MANAGEMENT SYSTEM
-- File 3: Indexes (Additional Indexes Beyond Table Definitions)
-- ============================================================================

CREATE INDEX idx_sales_items_sale_product ON sales_items(sale_id, product_id);
CREATE INDEX idx_inventory_logs_product_date ON inventory_logs(product_id, change_date);
CREATE INDEX idx_products_name_category ON products(name, category);
CREATE INDEX idx_customers_city ON customers(city);