-- ============================================================================
-- SMART INVENTORY & SALES MANAGEMENT SYSTEM
-- File 5: Triggers
-- ============================================================================

DELIMITER $$

CREATE TRIGGER trg_log_stock_changes
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    IF OLD.stock != NEW.stock THEN
        INSERT INTO inventory_logs (product_id, old_stock, new_stock, change_type, quantity_changed, user_action)
        VALUES (NEW.product_id, OLD.stock, NEW.stock, 'Adjustment', (NEW.stock - OLD.stock), 'Manual Update');
    END IF;
END$$

CREATE TRIGGER trg_prevent_product_deletion
BEFORE DELETE ON products
FOR EACH ROW
BEGIN
    DECLARE sale_count INT;
    SELECT COUNT(*) INTO sale_count FROM sales_items WHERE product_id = OLD.product_id;
    IF sale_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete product with existing sales';
    END IF;
END$$

CREATE TRIGGER trg_update_sales_total_insert
AFTER INSERT ON sales_items
FOR EACH ROW
BEGIN
    UPDATE sales 
    SET total_amount = (SELECT COALESCE(SUM(line_total), 0) FROM sales_items WHERE sale_id = NEW.sale_id)
    WHERE sale_id = NEW.sale_id;
END$$

CREATE TRIGGER trg_update_sales_total_update
AFTER UPDATE ON sales_items
FOR EACH ROW
BEGIN
    UPDATE sales 
    SET total_amount = (SELECT COALESCE(SUM(line_total), 0) FROM sales_items WHERE sale_id = NEW.sale_id)
    WHERE sale_id = NEW.sale_id;
END$$

CREATE TRIGGER trg_update_sales_total_delete
AFTER DELETE ON sales_items
FOR EACH ROW
BEGIN
    UPDATE sales 
    SET total_amount = (SELECT COALESCE(SUM(line_total), 0) FROM sales_items WHERE sale_id = OLD.sale_id)
    WHERE sale_id = OLD.sale_id;
END$$

DELIMITER ;