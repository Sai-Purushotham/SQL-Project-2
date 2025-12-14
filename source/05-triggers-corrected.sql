-- ============================================================================
-- UNIVERSITY LIBRARY MANAGEMENT SYSTEM
-- Triggers (Corrected)
-- ============================================================================

USE university_library;

DELIMITER $$

-- ============================================================================
-- TRIGGER 1: Prevent Negative Available Copies
-- ============================================================================
CREATE TRIGGER trg_books_before_update
BEFORE UPDATE ON books
FOR EACH ROW
BEGIN
    IF NEW.available_copies < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: available_copies cannot be negative';
    END IF;
    
    IF NEW.total_copies < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: total_copies cannot be negative';
    END IF;
    
    IF NEW.available_copies > NEW.total_copies THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: available_copies cannot exceed total_copies';
    END IF;
END$$

-- ============================================================================
-- TRIGGER 2: Auto Decrement Available Copies on Loan Insert
-- ============================================================================
CREATE TRIGGER trg_loans_after_insert
AFTER INSERT ON loans
FOR EACH ROW
BEGIN
    IF NEW.status = 'ISSUED' THEN
        UPDATE books SET available_copies = available_copies - 1 WHERE book_id = NEW.book_id;
        INSERT INTO audit_logs (actor, action, details, status)
        VALUES ('system', 'LOAN_INSERTED', CONCAT('Loan ', NEW.loan_id, ' inserted for book ', NEW.book_id), 'SUCCESS');
    END IF;
END$$

-- ============================================================================
-- TRIGGER 3: Auto Increment Available Copies on Loan Return
-- ============================================================================
CREATE TRIGGER trg_loans_after_update
AFTER UPDATE ON loans
FOR EACH ROW
BEGIN
    IF OLD.status = 'ISSUED' AND NEW.status = 'RETURNED' THEN
        UPDATE books SET available_copies = available_copies + 1 WHERE book_id = NEW.book_id;
        INSERT INTO audit_logs (actor, action, details, status)
        VALUES ('system', 'LOAN_RETURNED', CONCAT('Loan ', NEW.loan_id, ' returned; book ', NEW.book_id, ' restored'), 'SUCCESS');
    END IF;
END$$

-- ============================================================================
-- TRIGGER 4: Prevent Member Deletion if Active Loans Exist
-- ============================================================================
CREATE TRIGGER trg_members_before_delete
BEFORE DELETE ON members
FOR EACH ROW
BEGIN
    DECLARE v_active_loans INT;
    SELECT COUNT(*) INTO v_active_loans FROM loans 
    WHERE member_id = OLD.member_id AND status = 'ISSUED';
    
    IF v_active_loans > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Cannot delete member with active loans';
    END IF;
END$$

-- ============================================================================
-- TRIGGER 5: Prevent Book Deletion if Loans Exist
-- ============================================================================
CREATE TRIGGER trg_books_before_delete
BEFORE DELETE ON books
FOR EACH ROW
BEGIN
    DECLARE v_loan_count INT;
    SELECT COUNT(*) INTO v_loan_count FROM loans WHERE book_id = OLD.book_id;
    
    IF v_loan_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Cannot delete book with existing loan records';
    END IF;
END$$

-- ============================================================================
-- TRIGGER 6: Log Loan Status Changes
-- ============================================================================
CREATE TRIGGER trg_loans_status_change
AFTER UPDATE ON loans
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO audit_logs (actor, action, details, status)
        VALUES ('system', 'LOAN_STATUS_CHANGE', 
                CONCAT('Loan ', NEW.loan_id, ' status changed from ', OLD.status, ' to ', NEW.status), 'SUCCESS');
    END IF;
END$$

-- ============================================================================
-- TRIGGER 7: Auto Update Book Timestamp on Copy Change
-- ============================================================================
CREATE TRIGGER trg_books_update_timestamp
BEFORE UPDATE ON books
FOR EACH ROW
BEGIN
    SET NEW.updated_at = NOW();
END$$

DELIMITER ;