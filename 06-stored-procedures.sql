-- ============================================================================
-- SMART INVENTORY & SALES MANAGEMENT SYSTEM
-- File 6: Stored Procedures
-- ============================================================================

DELIMITER $$

CREATE PROCEDURE sp_make_sale(IN p_customer_id INT, IN p_sale_date DATE, OUT p_sale_id INT, OUT p_status VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_status = 'Error: Transaction rolled back';
        ROLLBACK;
    END;
    START TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM customers WHERE customer_id = p_customer_id) THEN
        SET p_status = 'Error: Customer not found';
        ROLLBACK;
    ELSE
        INSERT INTO sales (customer_id, sale_date, payment_status)
        VALUES (p_customer_id, p_sale_date, 'Completed');
        SET p_sale_id = LAST_INSERT_ID();
        SET p_status = 'Sale created successfully';
        COMMIT;
    END IF;
END$$

CREATE PROCEDURE sp_add_sale_item(IN p_sale_id INT, IN p_product_id INT, IN p_quantity INT, OUT p_status VARCHAR(100))
BEGIN
    DECLARE v_current_stock INT;
    DECLARE v_unit_price DECIMAL(10, 2);
    DECLARE v_line_total DECIMAL(12, 2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_status = 'Error: Transaction rolled back';
        ROLLBACK;
    END;
    START TRANSACTION;
    SELECT stock, price INTO v_current_stock, v_unit_price FROM products WHERE product_id = p_product_id FOR UPDATE;
    IF v_current_stock IS NULL THEN
        SET p_status = 'Error: Product not found';
        ROLLBACK;
    ELSEIF v_current_stock < p_quantity THEN
        SET p_status = CONCAT('Error: Insufficient stock. Available: ', v_current_stock);
        ROLLBACK;
    ELSE
        SET v_line_total = v_unit_price * p_quantity;
        INSERT INTO sales_items (sale_id, product_id, quantity, unit_price, line_total)
        VALUES (p_sale_id, p_product_id, p_quantity, v_unit_price, v_line_total);
        UPDATE products SET stock = stock - p_quantity WHERE product_id = p_product_id;
        INSERT INTO inventory_logs (product_id, old_stock, new_stock, change_type, quantity_changed, user_action)
        VALUES (p_product_id, v_current_stock, v_current_stock - p_quantity, 'Sale', p_quantity, 'Sale Transaction');
        SET p_status = 'Item added to sale successfully';
        COMMIT;
    END IF;
END$$

CREATE PROCEDURE sp_get_monthly_revenue_report(IN p_year INT)
BEGIN
    SELECT MONTH(sale_date) AS month, DATE_FORMAT(sale_date, '%M') AS month_name,
        COUNT(DISTINCT sale_id) AS total_sales, SUM(total_amount) AS total_revenue,
        AVG(total_amount) AS avg_sale_value, COUNT(DISTINCT customer_id) AS unique_customers
    FROM sales
    WHERE YEAR(sale_date) = p_year AND payment_status = 'Completed'
    GROUP BY MONTH(sale_date), DATE_FORMAT(sale_date, '%M')
    ORDER BY MONTH(sale_date);
END$$

CREATE PROCEDURE sp_restock_product(IN p_product_id INT, IN p_quantity INT, OUT p_status VARCHAR(100))
BEGIN
    DECLARE v_old_stock INT;
    DECLARE v_new_stock INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_status = 'Error: Restock failed';
        ROLLBACK;
    END;
    START TRANSACTION;
    SELECT stock INTO v_old_stock FROM products WHERE product_id = p_product_id;
    IF v_old_stock IS NULL THEN
        SET p_status = 'Error: Product not found';
        ROLLBACK;
    ELSE
        UPDATE products SET stock = stock + p_quantity WHERE product_id = p_product_id;
        SET v_new_stock = v_old_stock + p_quantity;
        INSERT INTO inventory_logs (product_id, old_stock, new_stock, change_type, quantity_changed, user_action)
        VALUES (p_product_id, v_old_stock, v_new_stock, 'Purchase', p_quantity, 'Restock from Supplier');
        SET p_status = 'Product restocked successfully';
        COMMIT;
    END IF;
END$$

CREATE PROCEDURE sp_get_top_selling_products(IN p_limit INT)
BEGIN
    SELECT p.product_id, p.name, p.price,
        COALESCE(SUM(si.quantity), 0) AS total_quantity_sold,
        COALESCE(SUM(si.line_total), 0) AS total_revenue,
        COUNT(DISTINCT s.sale_id) AS number_of_sales
    FROM products p
    LEFT JOIN sales_items si ON p.product_id = si.product_id
    LEFT JOIN sales s ON si.sale_id = s.sale_id AND s.payment_status = 'Completed'
    GROUP BY p.product_id, p.name, p.price
    ORDER BY total_revenue DESC
    LIMIT p_limit;
END$$

CREATE PROCEDURE sp_cancel_sale(IN p_sale_id INT, OUT p_status VARCHAR(100))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_old_stock INT;
    DECLARE cur_items CURSOR FOR SELECT product_id, quantity FROM sales_items WHERE sale_id = p_sale_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_status = 'Error: Sale cancellation rolled back';
        ROLLBACK;
    END;
    START TRANSACTION;
    OPEN cur_items;
    read_loop: LOOP
        FETCH cur_items INTO v_product_id, v_quantity;
        IF done THEN LEAVE read_loop; END IF;
        SELECT stock INTO v_old_stock FROM products WHERE product_id = v_product_id;
        UPDATE products SET stock = stock + v_quantity WHERE product_id = v_product_id;
        INSERT INTO inventory_logs (product_id, old_stock, new_stock, change_type, quantity_changed, user_action)
        VALUES (v_product_id, v_old_stock, v_old_stock + v_quantity, 'Return', v_quantity, 'Sale Cancellation');
    END LOOP;
    CLOSE cur_items;
    UPDATE sales SET payment_status = 'Cancelled' WHERE sale_id = p_sale_id;
    SET p_status = 'Sale cancelled successfully and stock restored';
    COMMIT;
END$$

DELIMITER ;