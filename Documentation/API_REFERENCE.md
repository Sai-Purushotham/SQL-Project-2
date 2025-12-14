# 📖 API Reference - Database Procedures & Functions

**University Library Management System** | **Complete API Documentation**

---

## Overview

This document provides complete reference for all callable database procedures and available views. Use this as a quick lookup for all database operations.

---

## 🔧 Stored Procedures

### PROCEDURE: `issue_book`

**Purpose:** Issue a book to a member

**Syntax:**
```sql
CALL issue_book(member_id, book_id, staff_id, due_days);
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `member_id` | INT | Yes | ID of member borrowing the book |
| `book_id` | INT | Yes | ID of book being borrowed |
| `staff_id` | INT | Yes | ID of staff member issuing the book |
| `due_days` | INT | Yes | Number of days for which book is issued (e.g., 14) |

**Returns:**
- Success message with loan ID
- Error message if operation fails

**Example:**
```sql
-- Member 1 borrows Book 2 for 14 days, issued by Staff 1
CALL issue_book(1, 2, 1, 14);

-- Expected Output:
-- Loan created with ID: 1
-- Book borrowed until: 2025-12-28
```

**What Happens Internally:**
1. ✓ Validates member exists and is ACTIVE
2. ✓ Validates book exists
3. ✓ Checks if book is available (available_copies > 0)
4. ✓ If available:
   - Creates loan record with status = ISSUED
   - Sets issue_date = TODAY
   - Sets due_date = TODAY + due_days
5. ✓ If NOT available:
   - Creates reservation record
   - Sets status = WAITING
6. ✓ Logs the action in audit_logs
7. ✓ Returns appropriate message

**Business Rules:**
- Member must be ACTIVE
- Book must have available_copies > 0
- due_days must be positive integer
- If stock exhausted, creates reservation instead

**Error Handling:**
- Invalid member → Error: "Member not found or inactive"
- Invalid book → Error: "Book not found"
- No stock available → Creates reservation automatically
- Staff not found → Error: "Staff member not found"

---

### PROCEDURE: `return_book`

**Purpose:** Return a borrowed book and calculate fine if overdue

**Syntax:**
```sql
CALL return_book(loan_id);
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `loan_id` | INT | Yes | ID of the loan to be returned |

**Returns:**
- Loan status (RETURNED)
- Fine amount (0 if not overdue)
- Return date
- Status message

**Example:**
```sql
-- Return loan #1
CALL return_book(1);

-- Expected Output:
-- Status: RETURNED
-- Fine Amount: ₹50
-- Days Overdue: 10
-- Return Date: 2025-12-14
```

**What Happens Internally:**
1. ✓ Validates loan_id exists
2. ✓ Validates loan status is ISSUED
3. ✓ Gets issue_date and due_date
4. ✓ Calculates:
   - days_overdue = TODAY - due_date (if positive)
   - fine_amount = days_overdue × ₹5
5. ✓ Updates:
   - loan.return_date = TODAY
   - loan.status = RETURNED
6. ✓ Restores book stock:
   - available_copies += 1
7. ✓ If fine > 0:
   - Creates fine record
   - fine.status = UNPAID
8. ✓ Logs the action in audit_logs
9. ✓ Returns all details

**Business Rules:**
- Loan must exist and be in ISSUED status
- Can only return ISSUED loans
- Fine = ₹5 per day overdue
- If no days overdue, fine = 0
- Stock automatically restored

**Fine Calculation:**
```
If return_date <= due_date:
  fine = 0

If return_date > due_date:
  days_late = return_date - due_date
  fine = days_late × ₹5
```

**Error Handling:**
- Invalid loan_id → Error: "Loan not found"
- Already returned → Error: "Loan already returned"
- Wrong status → Error: "Can only return ISSUED loans"

---

## 📊 Views (Read-Only Reports)

### VIEW: `vw_catalog`

**Purpose:** Browse complete catalog of all books with details

**Syntax:**
```sql
SELECT * FROM vw_catalog;
SELECT * FROM vw_catalog WHERE publisher_id = 1;
SELECT * FROM vw_catalog WHERE available_copies > 0;
```

**Columns Returned:**

| Column | Type | Description |
|--------|------|-------------|
| `book_id` | INT | Unique book identifier |
| `title` | VARCHAR(255) | Book title |
| `author_names` | TEXT | Comma-separated list of authors |
| `genre_names` | TEXT | Comma-separated list of genres |
| `publisher_name` | VARCHAR(255) | Publishing company |
| `isbn` | VARCHAR(20) | ISBN number |
| `total_copies` | INT | Total copies in library |
| `available_copies` | INT | Copies available to borrow |
| `publication_year` | INT | Year of publication |

**Usage Examples:**

```sql
-- See ALL books
SELECT * FROM vw_catalog;

-- Find available books
SELECT * FROM vw_catalog WHERE available_copies > 0;

-- Search by title (partial match)
SELECT * FROM vw_catalog WHERE title LIKE '%Harry%';

-- Books by specific publisher
SELECT * FROM vw_catalog WHERE publisher_name = 'Penguin Books';

-- Count books by genre
SELECT genre_names, COUNT(*) as book_count 
FROM vw_catalog 
GROUP BY genre_names;

-- Out of stock books
SELECT * FROM vw_catalog WHERE available_copies = 0;
```

**Performance:** Optimized for fast reading, includes indexes

---

### VIEW: `vw_overdue_loans`

**Purpose:** Identify overdue books and calculate fines

**Syntax:**
```sql
SELECT * FROM vw_overdue_loans;
SELECT * FROM vw_overdue_loans WHERE days_overdue > 7;
```

**Columns Returned:**

| Column | Type | Description |
|--------|------|-------------|
| `loan_id` | INT | Loan identifier |
| `member_name` | VARCHAR(255) | Full name of borrower |
| `book_title` | VARCHAR(255) | Title of borrowed book |
| `issue_date` | DATE | When book was issued |
| `due_date` | DATE | When book was due |
| `days_overdue` | INT | Number of days overdue |
| `fine_amount` | DECIMAL(10,2) | Calculated fine (₹5/day) |
| `member_email` | VARCHAR(255) | Member's email for notification |
| `member_phone` | VARCHAR(20) | Member's phone for contact |

**Usage Examples:**

```sql
-- See ALL overdue books
SELECT * FROM vw_overdue_loans;

-- Overdue more than 7 days
SELECT * FROM vw_overdue_loans WHERE days_overdue > 7;

-- Total fines per member
SELECT member_name, SUM(fine_amount) as total_fine 
FROM vw_overdue_loans 
GROUP BY member_id;

-- Sort by days overdue (most overdue first)
SELECT * FROM vw_overdue_loans 
ORDER BY days_overdue DESC;

-- Find high-value fines
SELECT * FROM vw_overdue_loans WHERE fine_amount > 500;
```

**Business Use:** 
- Send reminders to members
- Generate fine reports
- Track problem borrowers
- Calculate revenue from fines

---

### VIEW: `vw_top_borrowed`

**Purpose:** Identify most popular books for inventory decisions

**Syntax:**
```sql
SELECT * FROM vw_top_borrowed;
SELECT * FROM vw_top_borrowed LIMIT 10;
```

**Columns Returned:**

| Column | Type | Description |
|--------|------|-------------|
| `book_id` | INT | Book identifier |
| `title` | VARCHAR(255) | Book title |
| `author_names` | TEXT | Authors |
| `total_borrowed` | INT | Times borrowed (all-time) |
| `current_copies` | INT | Current copies in stock |
| `borrowed_this_year` | INT | Times borrowed this year |
| `avg_days_borrowed` | DECIMAL(5,2) | Average days per loan |

**Usage Examples:**

```sql
-- Top 10 most borrowed books
SELECT * FROM vw_top_borrowed LIMIT 10;

-- Books borrowed more than 5 times
SELECT * FROM vw_top_borrowed WHERE total_borrowed > 5;

-- Popular books with low stock
SELECT * FROM vw_top_borrowed 
WHERE total_borrowed > 10 AND current_copies < 3;

-- Books borrowed this year
SELECT * FROM vw_top_borrowed 
WHERE borrowed_this_year > 0 
ORDER BY borrowed_this_year DESC;
```

**Business Use:**
- Decide which books to order more copies of
- Identify popular genres
- Manage inventory allocation
- Plan library expansion

---

## 📋 Table Schema Reference

### Table: `publishers`
```
PRIMARY KEY: publisher_id
Columns:
  - publisher_id (INT)
  - name (VARCHAR 255)
  - city (VARCHAR 100)
  - country (VARCHAR 100)
```

### Table: `authors`
```
PRIMARY KEY: author_id
Columns:
  - author_id (INT)
  - first_name (VARCHAR 100)
  - last_name (VARCHAR 100)
  - birth_year (INT)
  - nationality (VARCHAR 100)
```

### Table: `genres`
```
PRIMARY KEY: genre_id
Columns:
  - genre_id (INT)
  - genre_name (VARCHAR 100)
  - description (TEXT)
```

### Table: `books`
```
PRIMARY KEY: book_id
FOREIGN KEYS:
  - publisher_id → publishers
Columns:
  - book_id (INT)
  - title (VARCHAR 255)
  - isbn (VARCHAR 20)
  - publisher_id (INT)
  - publication_year (INT)
  - total_copies (INT)
  - available_copies (INT)
  - price (DECIMAL 10,2)
```

### Table: `book_authors`
```
PRIMARY KEY: (book_id, author_id)
FOREIGN KEYS:
  - book_id → books
  - author_id → authors
```

### Table: `book_genres`
```
PRIMARY KEY: (book_id, genre_id)
FOREIGN KEYS:
  - book_id → books
  - genre_id → genres
```

### Table: `members`
```
PRIMARY KEY: member_id
Columns:
  - member_id (INT)
  - first_name (VARCHAR 100)
  - last_name (VARCHAR 100)
  - email (VARCHAR 255)
  - phone (VARCHAR 20)
  - membership_type (ENUM: 'STUDENT', 'FACULTY', 'STAFF', 'EXTERNAL')
  - join_date (DATE)
  - status (ENUM: 'ACTIVE', 'INACTIVE', 'SUSPENDED')
```

### Table: `staff`
```
PRIMARY KEY: staff_id
Columns:
  - staff_id (INT)
  - first_name (VARCHAR 100)
  - last_name (VARCHAR 100)
  - email (VARCHAR 255)
  - position (VARCHAR 100)
  - hire_date (DATE)
  - status (ENUM: 'ACTIVE', 'INACTIVE')
```

### Table: `loans`
```
PRIMARY KEY: loan_id
FOREIGN KEYS:
  - member_id → members
  - book_id → books
  - staff_id → staff
Columns:
  - loan_id (INT)
  - member_id (INT)
  - book_id (INT)
  - staff_id (INT)
  - issue_date (DATE)
  - due_date (DATE)
  - return_date (DATE, nullable)
  - status (ENUM: 'ISSUED', 'RETURNED', 'LOST')
```

### Table: `reservations`
```
PRIMARY KEY: reservation_id
FOREIGN KEYS:
  - member_id → members
  - book_id → books
Columns:
  - reservation_id (INT)
  - member_id (INT)
  - book_id (INT)
  - reservation_date (DATE)
  - status (ENUM: 'WAITING', 'READY', 'CANCELLED')
```

### Table: `fines`
```
PRIMARY KEY: fine_id
FOREIGN KEYS:
  - loan_id → loans
Columns:
  - fine_id (INT)
  - loan_id (INT)
  - amount (DECIMAL 10,2)
  - date_created (DATE)
  - status (ENUM: 'UNPAID', 'PAID', 'WAIVED')
  - payment_date (DATE, nullable)
```

### Table: `audit_logs`
```
PRIMARY KEY: log_id
Columns:
  - log_id (INT)
  - action (VARCHAR 255)
  - table_name (VARCHAR 100)
  - record_id (INT)
  - action_date (TIMESTAMP)
  - action_by (VARCHAR 255)
```

---

## ⚡ Quick Command Reference

### Common Operations

```sql
-- Issue a book
CALL issue_book(1, 2, 1, 14);

-- Return a book
CALL return_book(1);

-- View all available books
SELECT * FROM vw_catalog WHERE available_copies > 0;

-- Check overdue books
SELECT * FROM vw_overdue_loans;

-- Get member's current loans
SELECT l.loan_id, b.title, l.due_date 
FROM loans l 
JOIN books b ON l.book_id = b.book_id 
WHERE l.member_id = 1 AND l.status = 'ISSUED';

-- Get member's fines
SELECT f.*, l.book_id 
FROM fines f 
JOIN loans l ON f.loan_id = l.loan_id 
WHERE l.member_id = 1 AND f.status = 'UNPAID';

-- View popular books
SELECT * FROM vw_top_borrowed LIMIT 10;

-- Find specific book
SELECT * FROM vw_catalog WHERE title LIKE '%Harry%';
```

---

## 🔐 Error Codes & Messages

| Code | Message | Solution |
|------|---------|----------|
| 001 | Member not found | Verify member_id exists |
| 002 | Book not found | Verify book_id exists |
| 003 | Book not available | Check available_copies or create reservation |
| 004 | Staff not found | Verify staff_id exists |
| 005 | Loan not found | Verify loan_id exists |
| 006 | Loan already returned | Cannot return twice |
| 007 | Invalid loan status | Loan must be ISSUED |

---

## 📞 Support & Help

For detailed examples and more information, see:
- **README.md** - General system overview
- **QUERY_GUIDE.md** - Common query patterns
- **Database Design** - Full schema details

---

**API Version:** 1.0  
**Status:** Production Ready ✅
