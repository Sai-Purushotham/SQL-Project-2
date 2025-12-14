# 📚 Query Guide - Common SQL Patterns & Examples

**University Library Management System** | **Practical SQL Examples**

---

## Introduction

This guide provides practical SQL queries for common library management tasks. Copy and modify these queries for your needs.

---

## 🎯 Quick Reference

### Main Procedures
```sql
CALL issue_book(1, 2, 1, 14);      -- Issue book
CALL return_book(1);                -- Return book
```

### Main Views
```sql
SELECT * FROM vw_catalog;           -- All books
SELECT * FROM vw_overdue_loans;     -- Overdue books
SELECT * FROM vw_top_borrowed;      -- Popular books
```

---

## 📖 Book Management Queries

### 1. Find a Specific Book
```sql
-- Search by title (case-insensitive)
SELECT * FROM vw_catalog 
WHERE title LIKE '%Harry Potter%';

-- Search by ISBN
SELECT * FROM books 
WHERE isbn = '9780439708180';

-- Search by author
SELECT DISTINCT b.* FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id
WHERE a.first_name = 'J.K.' AND a.last_name = 'Rowling';
```

### 2. View All Books with Details
```sql
-- All books with complete information
SELECT * FROM vw_catalog 
ORDER BY title ASC;

-- Sorted by publication year (newest first)
SELECT * FROM vw_catalog 
ORDER BY publication_year DESC;

-- By publisher
SELECT * FROM vw_catalog 
WHERE publisher_name = 'Penguin Books'
ORDER BY title;
```

### 3. Find Available Books
```sql
-- Books available to borrow
SELECT * FROM vw_catalog 
WHERE available_copies > 0 
ORDER BY title;

-- Available books by genre
SELECT * FROM vw_catalog 
WHERE genre_names LIKE '%Fiction%' 
AND available_copies > 0;

-- Count available books by genre
SELECT genre_names, COUNT(*) as available_count 
FROM vw_catalog 
WHERE available_copies > 0 
GROUP BY genre_names;
```

### 4. Find Out of Stock Books
```sql
-- Books with no copies available
SELECT title, total_copies, available_copies 
FROM vw_catalog 
WHERE available_copies = 0 
ORDER BY total_copies DESC;

-- Books with low stock (less than 2 copies)
SELECT title, available_copies, total_copies 
FROM vw_catalog 
WHERE available_copies < 2 
AND total_copies > 0;

-- Count of out-of-stock books
SELECT COUNT(*) as out_of_stock_count 
FROM vw_catalog 
WHERE available_copies = 0;
```

### 5. Books by Author
```sql
-- All books by specific author
SELECT DISTINCT b.book_id, b.title, b.publication_year 
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id
WHERE CONCAT(a.first_name, ' ', a.last_name) = 'J.K. Rowling'
ORDER BY b.publication_year DESC;

-- Count books by author
SELECT CONCAT(a.first_name, ' ', a.last_name) as author_name, 
       COUNT(b.book_id) as book_count
FROM authors a
LEFT JOIN book_authors ba ON a.author_id = ba.author_id
LEFT JOIN books b ON ba.book_id = b.book_id
GROUP BY a.author_id
ORDER BY book_count DESC;
```

### 6. Books by Genre
```sql
-- All fiction books available
SELECT * FROM vw_catalog 
WHERE genre_names LIKE '%Fiction%' 
AND available_copies > 0;

-- Count books by genre
SELECT genre_names, COUNT(*) as total_books 
FROM vw_catalog 
GROUP BY genre_names 
ORDER BY total_books DESC;

-- Most popular genre (most borrowed)
SELECT bg.genre_id, g.genre_name, COUNT(l.loan_id) as times_borrowed
FROM book_genres bg
JOIN genres g ON bg.genre_id = g.genre_id
JOIN books b ON bg.book_id = b.book_id
LEFT JOIN loans l ON b.book_id = l.book_id
GROUP BY bg.genre_id
ORDER BY times_borrowed DESC;
```

---

## 👥 Member Management Queries

### 1. View All Members
```sql
-- All active members
SELECT * FROM members 
WHERE status = 'ACTIVE'
ORDER BY first_name, last_name;

-- All members with contact info
SELECT member_id, 
       CONCAT(first_name, ' ', last_name) as full_name,
       email, phone, membership_type, join_date
FROM members 
WHERE status = 'ACTIVE';

-- Member count by type
SELECT membership_type, COUNT(*) as member_count
FROM members
WHERE status = 'ACTIVE'
GROUP BY membership_type;
```

### 2. Find Specific Member
```sql
-- Search by name
SELECT * FROM members 
WHERE CONCAT(first_name, ' ', last_name) LIKE '%Sai%'
AND status = 'ACTIVE';

-- Search by email
SELECT * FROM members 
WHERE email = 'member@example.com';

-- By member ID
SELECT * FROM members 
WHERE member_id = 1;
```

### 3. Member's Current Loans
```sql
-- Current loans for a member
SELECT l.loan_id, b.title, b.isbn, l.issue_date, l.due_date,
       DATEDIFF(CURDATE(), l.due_date) as days_overdue
FROM loans l
JOIN books b ON l.book_id = b.book_id
WHERE l.member_id = 1 
AND l.status = 'ISSUED'
ORDER BY l.due_date ASC;

-- Count of current loans per member
SELECT m.member_id,
       CONCAT(m.first_name, ' ', m.last_name) as member_name,
       COUNT(l.loan_id) as current_loans
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id AND l.status = 'ISSUED'
WHERE m.status = 'ACTIVE'
GROUP BY m.member_id
ORDER BY current_loans DESC;
```

### 4. Member's Borrowing History
```sql
-- Complete borrowing history for a member
SELECT l.loan_id, b.title, l.issue_date, l.due_date, l.return_date,
       DATEDIFF(l.return_date, l.issue_date) as days_borrowed,
       l.status
FROM loans l
JOIN books b ON l.book_id = b.book_id
WHERE l.member_id = 1
ORDER BY l.issue_date DESC;

-- Total books borrowed per member
SELECT m.member_id,
       CONCAT(m.first_name, ' ', m.last_name) as member_name,
       COUNT(l.loan_id) as total_borrowed
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id
ORDER BY total_borrowed DESC;
```

### 5. Member's Outstanding Fines
```sql
-- All unpaid fines for a member
SELECT f.fine_id, l.loan_id, b.title, f.amount, 
       f.date_created, f.status
FROM fines f
JOIN loans l ON f.loan_id = l.loan_id
JOIN books b ON l.book_id = b.book_id
WHERE l.member_id = 1
AND f.status = 'UNPAID'
ORDER BY f.date_created DESC;

-- Total fines per member
SELECT m.member_id,
       CONCAT(m.first_name, ' ', m.last_name) as member_name,
       SUM(f.amount) as total_fines,
       COUNT(f.fine_id) as fine_count
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
LEFT JOIN fines f ON l.loan_id = f.loan_id
WHERE f.status = 'UNPAID'
GROUP BY m.member_id
ORDER BY total_fines DESC;

-- Members with most fines
SELECT m.member_id,
       CONCAT(m.first_name, ' ', m.last_name) as member_name,
       COUNT(DISTINCT f.fine_id) as fine_count,
       SUM(f.amount) as total_fines
FROM members m
JOIN loans l ON m.member_id = l.member_id
JOIN fines f ON l.loan_id = f.loan_id
GROUP BY m.member_id
ORDER BY fine_count DESC
LIMIT 10;
```

---

## 📅 Loan Management Queries

### 1. Issue a Book (Using Procedure)
```sql
-- Issue book to member
CALL issue_book(1, 2, 1, 14);

-- What this does:
-- - Member 1 borrows Book 2
-- - Issued by Staff member 1
-- - For 14 days
-- - If available: Creates loan
-- - If not available: Creates reservation
```

### 2. Return a Book (Using Procedure)
```sql
-- Return book and calculate fine
CALL return_book(1);

-- What this does:
-- - Returns Loan 1
-- - Calculates days overdue
-- - Fine = days_overdue × ₹5
-- - Updates stock
-- - Records everything in audit
```

### 3. View All Active Loans
```sql
-- All currently issued books
SELECT l.loan_id, 
       CONCAT(m.first_name, ' ', m.last_name) as member,
       b.title as book,
       l.issue_date, l.due_date,
       DATEDIFF(CURDATE(), l.due_date) as days_overdue
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
WHERE l.status = 'ISSUED'
ORDER BY l.due_date ASC;
```

### 4. Find Overdue Books
```sql
-- All overdue loans (can also use view)
SELECT * FROM vw_overdue_loans
ORDER BY days_overdue DESC;

-- Overdue more than 7 days
SELECT * FROM vw_overdue_loans
WHERE days_overdue > 7;

-- Most overdue
SELECT * FROM vw_overdue_loans
WHERE days_overdue > 30;
```

### 5. Books Due Soon
```sql
-- Books due in next 3 days
SELECT l.loan_id, 
       CONCAT(m.first_name, ' ', m.last_name) as member,
       b.title, l.due_date,
       DATEDIFF(l.due_date, CURDATE()) as days_until_due
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
WHERE l.status = 'ISSUED'
AND DATEDIFF(l.due_date, CURDATE()) BETWEEN 0 AND 3
ORDER BY l.due_date ASC;
```

### 6. Loan Statistics
```sql
-- Total loans issued
SELECT COUNT(*) as total_loans
FROM loans;

-- Loans by status
SELECT status, COUNT(*) as count
FROM loans
GROUP BY status;

-- Average loan duration
SELECT AVG(DATEDIFF(return_date, issue_date)) as avg_days
FROM loans
WHERE return_date IS NOT NULL;

-- Books most frequently loaned
SELECT b.book_id, b.title, COUNT(l.loan_id) as times_loaned
FROM books b
LEFT JOIN loans l ON b.book_id = l.book_id
GROUP BY b.book_id
ORDER BY times_loaned DESC
LIMIT 10;
```

---

## 💰 Fine Management Queries

### 1. View All Fines
```sql
-- All unpaid fines
SELECT f.fine_id, l.loan_id, 
       CONCAT(m.first_name, ' ', m.last_name) as member,
       b.title, f.amount, f.date_created
FROM fines f
JOIN loans l ON f.loan_id = l.loan_id
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
WHERE f.status = 'UNPAID'
ORDER BY f.amount DESC;

-- All fines (including paid)
SELECT * FROM fines
ORDER BY date_created DESC;
```

### 2. Fine Statistics
```sql
-- Total revenue from fines
SELECT SUM(amount) as total_fines
FROM fines
WHERE status = 'PAID';

-- Fines by status
SELECT status, COUNT(*) as count, SUM(amount) as total
FROM fines
GROUP BY status;

-- Average fine amount
SELECT AVG(amount) as average_fine
FROM fines;

-- Member with most fines
SELECT l.member_id, 
       CONCAT(m.first_name, ' ', m.last_name) as member,
       COUNT(f.fine_id) as fine_count,
       SUM(f.amount) as total_owed
FROM fines f
JOIN loans l ON f.loan_id = l.loan_id
JOIN members m ON l.member_id = m.member_id
WHERE f.status = 'UNPAID'
GROUP BY l.member_id
ORDER BY total_owed DESC;
```

### 3. Mark Fine as Paid
```sql
-- Update fine status (manual payment)
UPDATE fines 
SET status = 'PAID', payment_date = CURDATE()
WHERE fine_id = 1;

-- Mark all fines for a member as paid
UPDATE fines 
SET status = 'PAID', payment_date = CURDATE()
WHERE fine_id IN (
  SELECT f.fine_id FROM fines f
  JOIN loans l ON f.loan_id = l.loan_id
  WHERE l.member_id = 1
);
```

---

## 📊 Popular Books & Analytics

### 1. Most Borrowed Books
```sql
-- Using view (faster)
SELECT * FROM vw_top_borrowed
LIMIT 10;

-- Using query (more details)
SELECT b.book_id, b.title, 
       COUNT(l.loan_id) as times_borrowed,
       CONCAT(a.first_name, ' ', a.last_name) as author,
       b.available_copies
FROM books b
LEFT JOIN loans l ON b.book_id = l.book_id
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
GROUP BY b.book_id
ORDER BY times_borrowed DESC
LIMIT 10;
```

### 2. Inventory Status
```sql
-- Complete inventory overview
SELECT b.title, b.total_copies, b.available_copies,
       (b.total_copies - b.available_copies) as on_loan,
       ROUND(100 * b.available_copies / b.total_copies, 1) as percent_available,
       COUNT(DISTINCT l.loan_id) as active_loans
FROM books b
LEFT JOIN loans l ON b.book_id = l.book_id AND l.status = 'ISSUED'
GROUP BY b.book_id
ORDER BY percent_available ASC;

-- Low stock alert
SELECT title, total_copies, available_copies
FROM books
WHERE available_copies < 2
ORDER BY available_copies ASC;
```

### 3. Genre Analysis
```sql
-- Most popular genres
SELECT g.genre_name, COUNT(l.loan_id) as total_borrowed
FROM genres g
LEFT JOIN book_genres bg ON g.genre_id = bg.genre_id
LEFT JOIN books b ON bg.book_id = b.book_id
LEFT JOIN loans l ON b.book_id = l.book_id
GROUP BY g.genre_id
ORDER BY total_borrowed DESC;
```

---

## 🔍 Search & Filter Queries

### 1. Advanced Book Search
```sql
-- Books by multiple criteria
SELECT * FROM vw_catalog
WHERE publisher_name = 'Penguin Books'
AND publication_year >= 2000
AND available_copies > 0
AND genre_names LIKE '%Fiction%'
ORDER BY title;

-- Price range search
SELECT * FROM books
WHERE price BETWEEN 200 AND 500
ORDER BY price DESC;
```

### 2. Member Search
```sql
-- Active members by type
SELECT * FROM members
WHERE status = 'ACTIVE'
AND membership_type = 'STUDENT'
ORDER BY join_date DESC;

-- Members joined in specific year
SELECT * FROM members
WHERE YEAR(join_date) = 2025
AND status = 'ACTIVE';
```

### 3. Date-Based Searches
```sql
-- Books borrowed today
SELECT * FROM loans
WHERE issue_date = CURDATE()
AND status = 'ISSUED';

-- Books due today
SELECT * FROM loans
WHERE due_date = CURDATE()
AND status = 'ISSUED';

-- Books borrowed this month
SELECT * FROM loans
WHERE YEAR(issue_date) = YEAR(CURDATE())
AND MONTH(issue_date) = MONTH(CURDATE());
```

---

## 📈 Reporting Queries

### 1. Monthly Activity Report
```sql
-- Loans issued per month
SELECT DATE_FORMAT(issue_date, '%Y-%m') as month,
       COUNT(*) as loans_issued
FROM loans
GROUP BY DATE_FORMAT(issue_date, '%Y-%m')
ORDER BY month DESC;

-- Returns per month
SELECT DATE_FORMAT(return_date, '%Y-%m') as month,
       COUNT(*) as returns
FROM loans
WHERE return_date IS NOT NULL
GROUP BY DATE_FORMAT(return_date, '%Y-%m')
ORDER BY month DESC;
```

### 2. Staff Performance
```sql
-- Loans issued per staff member
SELECT s.staff_id,
       CONCAT(s.first_name, ' ', s.last_name) as staff_name,
       COUNT(l.loan_id) as loans_issued
FROM staff s
LEFT JOIN loans l ON s.staff_id = l.staff_id
GROUP BY s.staff_id
ORDER BY loans_issued DESC;
```

### 3. Overall Dashboard
```sql
-- Get key metrics
SELECT 
  (SELECT COUNT(*) FROM books) as total_books,
  (SELECT SUM(available_copies) FROM books) as available_books,
  (SELECT COUNT(*) FROM members WHERE status = 'ACTIVE') as active_members,
  (SELECT COUNT(*) FROM loans WHERE status = 'ISSUED') as current_loans,
  (SELECT COUNT(*) FROM fines WHERE status = 'UNPAID') as unpaid_fines,
  (SELECT SUM(amount) FROM fines WHERE status = 'UNPAID') as total_fines_owed;
```

---

## 🛠️ Maintenance Queries

### 1. Data Validation
```sql
-- Check for orphaned loans
SELECT l.* FROM loans l
WHERE l.member_id NOT IN (SELECT member_id FROM members)
OR l.book_id NOT IN (SELECT book_id FROM books);

-- Check stock consistency
SELECT * FROM books
WHERE available_copies > total_copies
OR available_copies < 0;
```

### 2. Clean Up
```sql
-- Cancel old reservations (older than 30 days)
UPDATE reservations
SET status = 'CANCELLED'
WHERE status = 'WAITING'
AND DATEDIFF(CURDATE(), reservation_date) > 30;

-- Mark overdue books as lost (unreturned after 90 days)
UPDATE loans
SET status = 'LOST'
WHERE status = 'ISSUED'
AND DATEDIFF(CURDATE(), due_date) > 90;
```

---

## 💡 Tips & Tricks

### 1. Common Filters
```sql
-- Find records from last 7 days
WHERE created_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)

-- Find records from this year
WHERE YEAR(created_date) = YEAR(CURDATE())

-- Find records from specific date range
WHERE created_date BETWEEN '2025-01-01' AND '2025-12-31'
```

### 2. Useful Functions
```sql
-- Format dates
DATE_FORMAT(issue_date, '%d-%m-%Y')

-- Calculate differences
DATEDIFF(return_date, issue_date)

-- Concatenate names
CONCAT(first_name, ' ', last_name)

-- Count records
COUNT(*), COUNT(DISTINCT member_id)

-- Aggregate
SUM(), AVG(), MIN(), MAX()
```

### 3. Performance Tips
```sql
-- Use LIMIT to reduce results
SELECT * FROM books LIMIT 10;

-- Use indexes (already created)
-- Use views when available
SELECT * FROM vw_catalog

-- Use EXPLAIN to analyze
EXPLAIN SELECT * FROM loans WHERE member_id = 1;
```

---

## 📞 Quick Reference

| Task | Query |
|------|-------|
| Issue book | `CALL issue_book(m_id, b_id, s_id, days);` |
| Return book | `CALL return_book(loan_id);` |
| View all books | `SELECT * FROM vw_catalog;` |
| View overdue | `SELECT * FROM vw_overdue_loans;` |
| View popular | `SELECT * FROM vw_top_borrowed;` |
| Member loans | `SELECT * FROM loans WHERE member_id = ?;` |
| Member fines | `SELECT * FROM fines WHERE loan_id IN (...);` |
| Fine stats | `SELECT SUM(amount) FROM fines;` |

---

**Query Guide Version:** 1.0  
**Last Updated:** December 2025  
**Status:** Production Ready ✅