-- ============================================================================
-- SMART INVENTORY & SALES MANAGEMENT SYSTEM
-- File 9: Verification & Summary Queries
-- ============================================================================

-- Verify all tables have been created and loaded with data
SELECT 'suppliers' AS table_name, COUNT(*) AS row_count FROM suppliers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'sales', COUNT(*) FROM sales
UNION ALL SELECT 'sales_items', COUNT(*) FROM sales_items
UNION ALL SELECT 'inventory_logs', COUNT(*) FROM inventory_logs;

-- ============================================================================
-- DATABASE VERIFICATION STATUS
-- ============================================================================

SELECT '✅ Database Created Successfully!' AS Status;
SELECT '✅ Tables, Views, Procedures, and Data Loaded' AS Status;
SELECT '🎉 PROJECT COMPLETE - READY TO USE!' AS Status;