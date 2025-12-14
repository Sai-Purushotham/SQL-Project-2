-- ============================================================================
-- UNIVERSITY LIBRARY MANAGEMENT SYSTEM
-- Queries & Tests (Corrected & Runnable)
-- ============================================================================

USE university_library;

-- ============================================================================
-- SECTION 1: Basic Catalog Queries
-- ============================================================================

-- Query 1: View all books with complete information
SELECT 'Query 1: All Books Catalog' AS query_name;
SELECT * FROM vw_catalog;

-- Query 2: View only available books
SELECT 'Query 2: Available Books' AS query_name;
SELECT * FROM vw_available_books LIMIT 10;

-- Query 3: Find books by specific author
SELECT 'Query 3: Books by George Orwell' AS query_name;
SELECT DISTINCT b.* 
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id
WHERE a.first_name = 'George' AND a.last_name = 'Orwell';

-- ============================================================================
-- SECTION 2: Member & Loan Queries
-- ============================================================================

-- Query 4: Get member borrowing history
SELECT 'Query 4: Member Borrowing History' AS query_name;
SELECT * FROM vw_member_history WHERE member_id = 1;

-- Query 5: List all active loans
SELECT 'Query 5: Active Loans' AS query_name;
SELECT 
    l.loan_id,
    b.title AS book_title,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    l.issue_date,
    l.due_date,
    DATEDIFF(l.due_date, CURDATE()) AS days_remaining
FROM loans l
JOIN books b ON l.book_id = b.book_id
JOIN members m ON l.member_id = m.member_id
WHERE l.status = 'ISSUED'
ORDER BY l.due_date ASC;

-- Query 6: Check overdue books
SELECT 'Query 6: Overdue Books' AS query_name;
SELECT * FROM vw_overdue_loans;

-- ============================================================================
-- SECTION 3: Top Performing Books
-- ============================================================================

-- Query 7: Top borrowed books
SELECT 'Query 7: Top 5 Most Borrowed Books' AS query_name;
SELECT 
    book_id,
    title,
    total_borrowed,
    unique_members,
    ROUND(total_borrowed / NULLIF(unique_members, 0), 2) AS avg_borrows_per_member
FROM vw_top_borrowed
LIMIT 5;

-- Query 8: Books with highest availability
SELECT 'Query 8: Books with Best Availability' AS query_name;
SELECT 
    book_id,
    title,
    total_copies,
    available_copies,
    ROUND((available_copies / total_copies) * 100, 2) AS availability_percent
FROM books
WHERE total_copies > 0
ORDER BY availability_percent DESC;

-- ============================================================================
-- SECTION 4: Fine & Payment Queries
-- ============================================================================

-- Query 9: View pending fines
SELECT 'Query 9: Pending Fines' AS query_name;
SELECT 
    f.fine_id,
    l.loan_id,
    b.title,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    f.amount,
    f.created_at,
    DATEDIFF(CURDATE(), f.created_at) AS days_pending
FROM fines f
JOIN loans l ON f.loan_id = l.loan_id
JOIN books b ON l.book_id = b.book_id
JOIN members m ON l.member_id = m.member_id
WHERE f.paid = FALSE
ORDER BY f.created_at ASC;

-- Query 10: Total fines by member
SELECT 'Query 10: Fines Summary by Member' AS query_name;
SELECT 
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    COUNT(f.fine_id) AS total_fines,
    SUM(f.amount) AS total_amount,
    SUM(CASE WHEN f.paid = FALSE THEN f.amount ELSE 0 END) AS pending_amount,
    SUM(CASE WHEN f.paid = TRUE THEN f.amount ELSE 0 END) AS paid_amount
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
LEFT JOIN fines f ON l.loan_id = f.loan_id
GROUP BY m.member_id, m.first_name, m.last_name
HAVING total_fines > 0;

-- ============================================================================
-- SECTION 5: Procedure Tests - UNCOMMENT TO RUN
-- ============================================================================

-- Test 1: Issue a book to a member
-- CALL sp_issue_book(1, 3, 1, 14, @loan_id, @message);
-- SELECT @loan_id AS loan_id, @message AS message;

-- Test 2: Return a book
-- CALL sp_return_book(1, 1, @fine, @message);
-- SELECT @fine AS fine_amount, @message AS message;

-- Test 3: Renew a loan
-- CALL sp_renew_loan(1, 7, @new_due, @message);
-- SELECT @new_due AS new_due_date, @message AS message;

-- Test 4: Get member dashboard
-- CALL sp_get_member_dashboard(1);

-- ============================================================================
-- SECTION 6: Admin & Reporting Queries
-- ============================================================================

-- Query 11: Library statistics
SELECT 'Query 11: Library Statistics' AS query_name;
SELECT 
    (SELECT COUNT(*) FROM books) AS total_books,
    (SELECT SUM(total_copies) FROM books) AS total_copies,
    (SELECT SUM(available_copies) FROM books) AS available_copies,
    (SELECT COUNT(*) FROM members WHERE is_active = TRUE) AS active_members,
    (SELECT COUNT(*) FROM loans WHERE status = 'ISSUED') AS active_loans,
    (SELECT COUNT(*) FROM reservations WHERE status = 'ACTIVE') AS pending_reservations,
    (SELECT COUNT(*) FROM fines WHERE paid = FALSE) AS unpaid_fines,
    (SELECT SUM(amount) FROM fines WHERE paid = FALSE) AS total_fine_amount;

-- Query 12: Staff activity log
SELECT 'Query 12: Recent Staff Activity' AS query_name;
SELECT 
    log_time,
    actor,
    action,
    details,
    status
FROM audit_logs
WHERE action IN ('ISSUE_BOOK', 'RETURN_BOOK')
ORDER BY log_time DESC
LIMIT 20;

-- Query 13: Member types distribution
SELECT 'Query 13: Member Types Distribution' AS query_name;
SELECT 
    member_type,
    COUNT(*) AS count,
    SUM(CASE WHEN is_active = TRUE THEN 1 ELSE 0 END) AS active
FROM members
GROUP BY member_type;

-- Query 14: Books per publisher
SELECT 'Query 14: Books per Publisher' AS query_name;
SELECT 
    p.name AS publisher,
    COUNT(b.book_id) AS book_count,
    SUM(b.total_copies) AS total_copies,
    SUM(b.available_copies) AS available_copies
FROM publishers p
LEFT JOIN books b ON p.publisher_id = b.publisher_id
GROUP BY p.publisher_id, p.name
ORDER BY book_count DESC;

-- Query 15: Reservation queue
SELECT 'Query 15: Books with Reservations' AS query_name;
SELECT 
    b.title,
    COUNT(r.reservation_id) AS reservation_count,
    GROUP_CONCAT(CONCAT(m.first_name, ' ', m.last_name) SEPARATOR ', ') AS reserved_by
FROM books b
LEFT JOIN reservations r ON b.book_id = r.book_id AND r.status = 'ACTIVE'
LEFT JOIN members m ON r.member_id = m.member_id
WHERE r.reservation_id IS NOT NULL
GROUP BY b.book_id, b.title
ORDER BY reservation_count DESC;