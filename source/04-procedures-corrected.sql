-- ============================================================================
-- UNIVERSITY LIBRARY MANAGEMENT SYSTEM
-- Stored Procedures (Corrected)
-- ============================================================================

USE university_library;

DELIMITER $$

-- ============================================================================
-- PROCEDURE 1: Issue Book to Member
-- ============================================================================
CREATE PROCEDURE sp_issue_book(
    IN p_member_id INT,
    IN p_book_id INT,
    IN p_staff_id INT,
    IN p_due_days INT,
    OUT p_loan_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_available INT;
    DECLARE v_member_exists INT;
    DECLARE v_book_exists INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_message = 'Error: Transaction rolled back';
        ROLLBACK;
    END;
    
    START TRANSACTION;
    
    -- Check if member exists
    SELECT COUNT(*) INTO v_member_exists FROM members WHERE member_id = p_member_id AND is_active = TRUE;
    IF v_member_exists = 0 THEN
        SET p_message = 'Error: Member not found or inactive';
        ROLLBACK;
        LEAVE sp_issue_book;
    END IF;
    
    -- Check if book exists
    SELECT COUNT(*) INTO v_book_exists FROM books WHERE book_id = p_book_id;
    IF v_book_exists = 0 THEN
        SET p_message = 'Error: Book not found';
        ROLLBACK;
        LEAVE sp_issue_book;
    END IF;
    
    -- Check available copies
    SELECT available_copies INTO v_available FROM books WHERE book_id = p_book_id FOR UPDATE;
    
    IF v_available <= 0 THEN
        -- Create reservation instead
        INSERT INTO reservations (book_id, member_id, status) VALUES (p_book_id, p_member_id, 'ACTIVE');
        INSERT INTO audit_logs (actor, action, details, status) 
        VALUES (CONCAT('staff:', p_staff_id), 'RESERVATION_CREATED', CONCAT('Member ', p_member_id, ' reserved book ', p_book_id), 'SUCCESS');
        SET p_message = 'Success: Book reserved (no copies available)';
        COMMIT;
        LEAVE sp_issue_book;
    END IF;
    
    -- Issue the book
    INSERT INTO loans (book_id, member_id, issued_by_staff_id, issue_date, due_date, status)
    VALUES (p_book_id, p_member_id, p_staff_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL p_due_days DAY), 'ISSUED');
    
    SET p_loan_id = LAST_INSERT_ID();
    
    -- Update available copies
    UPDATE books SET available_copies = available_copies - 1 WHERE book_id = p_book_id;
    
    -- Log the action
    INSERT INTO audit_logs (actor, action, details, status)
    VALUES (CONCAT('staff:', p_staff_id), 'ISSUE_BOOK', 
            CONCAT('Issued book ', p_book_id, ' to member ', p_member_id, ' (Loan ID: ', p_loan_id, ')'), 'SUCCESS');
    
    SET p_message = CONCAT('Success: Book issued. Loan ID: ', p_loan_id);
    COMMIT;
    
END$$

-- ============================================================================
-- PROCEDURE 2: Return Book from Member
-- ============================================================================
CREATE PROCEDURE sp_return_book(
    IN p_loan_id INT,
    IN p_staff_id INT,
    OUT p_fine_amount DECIMAL(10,2),
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_book_id INT;
    DECLARE v_due_date DATE;
    DECLARE v_status VARCHAR(20);
    DECLARE v_days_overdue INT;
    DECLARE v_fine DECIMAL(10,2) DEFAULT 0.00;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_message = 'Error: Transaction rolled back';
        ROLLBACK;
    END;
    
    START TRANSACTION;
    
    -- Get loan details
    SELECT book_id, due_date, status INTO v_book_id, v_due_date, v_status 
    FROM loans WHERE loan_id = p_loan_id FOR UPDATE;
    
    -- Validate loan
    IF v_status IS NULL THEN
        SET p_message = 'Error: Loan not found';
        ROLLBACK;
        LEAVE sp_return_book;
    END IF;
    
    IF v_status <> 'ISSUED' THEN
        SET p_message = CONCAT('Error: Loan is already ', v_status);
        ROLLBACK;
        LEAVE sp_return_book;
    END IF;
    
    -- Calculate fine for overdue books (5 units per day)
    SET v_days_overdue = GREATEST(DATEDIFF(CURDATE(), v_due_date), 0);
    SET v_fine = v_days_overdue * 5.00;
    SET p_fine_amount = v_fine;
    
    -- Update loan
    UPDATE loans 
    SET return_date = CURDATE(), fine_amount = v_fine, status = 'RETURNED', updated_at = NOW()
    WHERE loan_id = p_loan_id;
    
    -- Restore available copies
    UPDATE books SET available_copies = available_copies + 1 WHERE book_id = v_book_id;
    
    -- Create fine if overdue
    IF v_fine > 0 THEN
        INSERT INTO fines (loan_id, amount, paid) VALUES (p_loan_id, v_fine, FALSE);
    END IF;
    
    -- Log the action
    INSERT INTO audit_logs (actor, action, details, status)
    VALUES (CONCAT('staff:', p_staff_id), 'RETURN_BOOK', 
            CONCAT('Returned loan ', p_loan_id, ' (Book: ', v_book_id, ', Fine: ', v_fine, ')'), 'SUCCESS');
    
    IF v_fine > 0 THEN
        SET p_message = CONCAT('Success: Book returned. Fine: ', v_fine, ' units');
    ELSE
        SET p_message = 'Success: Book returned. No fine';
    END IF;
    
    COMMIT;
    
END$$

-- ============================================================================
-- PROCEDURE 3: Renew Book Loan
-- ============================================================================
CREATE PROCEDURE sp_renew_loan(
    IN p_loan_id INT,
    IN p_additional_days INT,
    OUT p_new_due_date DATE,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_current_due DATE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_message = 'Error: Transaction rolled back';
        ROLLBACK;
    END;
    
    START TRANSACTION;
    
    -- Get loan status
    SELECT status, due_date INTO v_status, v_current_due 
    FROM loans WHERE loan_id = p_loan_id FOR UPDATE;
    
    IF v_status IS NULL THEN
        SET p_message = 'Error: Loan not found';
        ROLLBACK;
        LEAVE sp_renew_loan;
    END IF;
    
    IF v_status <> 'ISSUED' THEN
        SET p_message = 'Error: Only active loans can be renewed';
        ROLLBACK;
        LEAVE sp_renew_loan;
    END IF;
    
    -- Update due date
    SET p_new_due_date = DATE_ADD(v_current_due, INTERVAL p_additional_days DAY);
    UPDATE loans SET due_date = p_new_due_date, updated_at = NOW() WHERE loan_id = p_loan_id;
    
    -- Log the action
    INSERT INTO audit_logs (actor, action, details, status)
    VALUES ('system', 'RENEW_LOAN', CONCAT('Renewed loan ', p_loan_id, ' to ', p_new_due_date), 'SUCCESS');
    
    SET p_message = CONCAT('Success: Loan renewed. New due date: ', p_new_due_date);
    COMMIT;
    
END$$

-- ============================================================================
-- PROCEDURE 4: Get Member Dashboard
-- ============================================================================
CREATE PROCEDURE sp_get_member_dashboard(
    IN p_member_id INT
)
BEGIN
    SELECT 
        m.member_id,
        CONCAT(m.first_name, ' ', m.last_name) AS member_name,
        m.member_type,
        m.email,
        (SELECT COUNT(*) FROM loans WHERE member_id = p_member_id AND status = 'ISSUED') AS active_loans,
        (SELECT COUNT(*) FROM reservations WHERE member_id = p_member_id AND status = 'ACTIVE') AS reserved_books,
        (SELECT SUM(amount) FROM fines WHERE loan_id IN (SELECT loan_id FROM loans WHERE member_id = p_member_id) AND paid = FALSE) AS pending_fines
    FROM members m
    WHERE m.member_id = p_member_id;
END$$

DELIMITER ;