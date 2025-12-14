-- ============================================================================
-- UNIVERSITY LIBRARY MANAGEMENT SYSTEM
-- Views (Corrected)
-- ============================================================================

USE university_library;

-- ============================================================================
-- View 1: Book Catalog with Authors and Genres
-- ============================================================================
DROP VIEW IF EXISTS vw_catalog;

CREATE VIEW vw_catalog AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    b.published_year,
    b.pages,
    b.total_copies,
    b.available_copies,
    GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS authors,
    GROUP_CONCAT(DISTINCT g.name SEPARATOR ', ') AS genres,
    p.name AS publisher,
    b.description
FROM books b
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
LEFT JOIN book_genres bg ON b.book_id = bg.book_id
LEFT JOIN genres g ON bg.genre_id = g.genre_id
LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
GROUP BY b.book_id, b.title, b.isbn, b.published_year, b.pages, b.total_copies, b.available_copies, p.name, b.description;

-- ============================================================================
-- View 2: Overdue Loans
-- ============================================================================
DROP VIEW IF EXISTS vw_overdue_loans;

CREATE VIEW vw_overdue_loans AS
SELECT 
    l.loan_id,
    l.book_id,
    b.title,
    l.member_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    m.email,
    l.issue_date,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) AS days_overdue,
    l.fine_amount
FROM loans l
JOIN books b ON l.book_id = b.book_id
JOIN members m ON l.member_id = m.member_id
WHERE l.status = 'ISSUED' AND l.due_date < CURDATE()
ORDER BY l.due_date ASC;

-- ============================================================================
-- View 3: Top Borrowed Books
-- ============================================================================
DROP VIEW IF EXISTS vw_top_borrowed;

CREATE VIEW vw_top_borrowed AS
SELECT 
    b.book_id,
    b.title,
    COUNT(l.loan_id) AS total_borrowed,
    COUNT(DISTINCT l.member_id) AS unique_members,
    b.total_copies,
    b.available_copies
FROM books b
LEFT JOIN loans l ON b.book_id = l.book_id AND l.status IN ('ISSUED', 'RETURNED')
GROUP BY b.book_id, b.title, b.total_copies, b.available_copies
ORDER BY total_borrowed DESC;

-- ============================================================================
-- View 4: Member Borrowing History
-- ============================================================================
DROP VIEW IF EXISTS vw_member_history;

CREATE VIEW vw_member_history AS
SELECT 
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    m.email,
    m.member_type,
    COUNT(DISTINCT l.loan_id) AS total_loans,
    COUNT(DISTINCT CASE WHEN l.status = 'ISSUED' THEN l.loan_id END) AS active_loans,
    COUNT(DISTINCT CASE WHEN l.status = 'RETURNED' THEN l.loan_id END) AS returned_loans,
    SUM(CASE WHEN l.status = 'RETURNED' THEN COALESCE(l.fine_amount, 0) ELSE 0 END) AS total_fines_incurred
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.first_name, m.last_name, m.email, m.member_type;

-- ============================================================================
-- View 5: Available Books
-- ============================================================================
DROP VIEW IF EXISTS vw_available_books;

CREATE VIEW vw_available_books AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    b.published_year,
    GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS authors,
    p.name AS publisher,
    b.total_copies,
    b.available_copies,
    (b.total_copies - b.available_copies) AS issued_copies
FROM books b
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
WHERE b.available_copies > 0
GROUP BY b.book_id, b.title, b.isbn, b.published_year, p.name, b.total_copies, b.available_copies
ORDER BY b.available_copies DESC;