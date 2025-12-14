
# 📚 University Library Management System

**A comprehensive database system for managing library operations, book inventories, member records, and loan management.**

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [ERD](#entity-relationship-diagram)
- [Technology Stack](#technology-stack)
- [Database Architecture](#database-architecture)
- [Setup Instructions](#setup-instructions)
- [File Structure](#file-structure)
- [Tables & Schema](#tables--schema)
- [Key Features](#key-features)
- [Screenshots & Proof](#screenshots--proof)
- [Stored Procedures](#stored-procedures)
- [Views Available](#views-available)
- [Triggers Implemented](#triggers-implemented)
- [Sample Queries](#sample-queries)
- [Author](#author)

---

## Project Overview

The **University Library Management System** is a full-featured database application designed to streamline library operations at educational institutions. It manages:

- **Book Inventory**: Track books, publishers, authors, and genres
- **Member Management**: Student, employee, and external member records
- **Loan Operations**: Issue, return, and renew books with automatic fine calculation
- **Reservations**: Members can reserve books when unavailable
- **Fine Management**: Track and manage overdue penalties
- **Audit Logging**: Complete activity logs for all operations

This system is built using **MySQL** with advanced features including triggers, stored procedures, views, and transactions for data integrity.

---

## Entity-Relationship Diagram

<img width="1536" height="1024" alt="ERD Rectified" src="https://github.com/user-attachments/assets/da25efb1-e2c9-4ce9-9a88-27b4439e355a" />

---

## Features

✅ **Complete Book Management**
- Track multiple copies of books
- Manage authors and genres with many-to-many relationships
- Publisher information and book descriptions
- ISBN tracking and book metadata

✅ **Member & Staff Management**
- Support for Students, Employees, and External members
- Member activation/deactivation
- Staff roles (Librarian, Assistant)
- Contact and enrollment tracking

✅ **Advanced Loan Operations**
- Issue books with automatic stock deduction
- Return books with automatic fine calculation (₹5 per day overdue)
- Automatic reservation creation when books unavailable
- Support for LOST and CANCELLED statuses

✅ **Financial Management**
- Automatic fine calculation on overdue returns
- Fine payment tracking
- Financial reporting and summaries

✅ **Data Integrity**
- Foreign key constraints
- Transaction support for critical operations
- Triggers for automatic updates
- Check constraints for data validation

✅ **Reporting & Analytics**
- Pre-built views for catalog browsing
- Overdue loan tracking
- Top borrowed books ranking
- Member activity history
- Fine summaries

---

## Technology Stack

- **Database**: MySQL 8.x
- **Management Tools**: phpMyAdmin, MySQL Workbench
- **SQL Features**: 
  - Stored Procedures
  - Triggers (7 total)
  - Views (3 core views)
  - Transactions
  - Foreign Keys & Constraints

---

## Database Architecture

### Entity Relationship Diagram (ERD)

The database follows a normalized relational model with the following structure:

```
┌─────────────────────────────────────────────────────────────────┐
│                    LIBRARY MANAGEMENT SYSTEM                     │
└─────────────────────────────────────────────────────────────────┘

                              ┌──────────────┐
                              │  Publishers  │
                              └──────┬───────┘
                                     │
                                     │ 1:N
                                     │
                    ┌────────────────┴───────────────┐
                    │                                │
                    │         ┌──────────────┐      │
                    │         │    Books     │◄─────┘
                    │         └──────┬───────┘
                    │                │
            ┌───────┴────────┬──────┴───────┬───────┐
            │                │              │       │
    ┌───────▼────────┐ ┌─────▼──┐ ┌────────▼────┐   │
    │ Book_Authors   │ │ Genres │ │ Book_Genres │   │
    └────────────────┘ └────────┘ └─────────────┘   │
            │                                        │
        ┌───▼──────┐                            ┌────▼───────┐
        │ Authors  │                            │  Members   │
        └──────────┘                            └────┬───────┘
                                                     │
                                     ┌───────────────┼───────────┐
                                     │               │           │
                                  ┌──▼─────────┐ ┌──▼────────┐   │
                                  │   Loans    │ │Reservations  │
                                  └──┬────┬────┘ └───────────┘   │
                                     │    │                      │
                             ┌───────┘    └──────┬────────┐      │
                             │                   │        │      │
                        ┌────▼──────┐      ┌─────▼────┐   │      │
                        │   Staff    │      │  Fines   │   │      │
                        └───────────┘      └──────────┘   │      │
                                                          │
                                                  ┌───────▼────┐
                                                  │ Audit_logs │
                                                  └────────────┘
```

---

## Setup Instructions

### Prerequisites

- MySQL Server 8.0 or higher installed
- phpMyAdmin or MySQL Workbench
- Basic SQL knowledge
- Text editor for SQL files

### Step-by-Step Installation

#### 1. Create Database & Tables

Run `01_schema.sql`:

```bash
mysql -u root -p < 01_schema.sql
```

Or in phpMyAdmin:
1. Go to SQL tab
2. Copy and paste content of `01_schema.sql`
3. Click "Go"

✅ Creates 12 tables with proper constraints and indexes

#### 2. Load Sample Data

Run `02_seed.sql`:

```bash
mysql -u root -p university_library < 02_seed.sql
```

✅ Loads sample publishers, authors, genres, books, members, staff, and loans

#### 3. Create Views

Run `03_views.sql`:

```bash
mysql -u root -p university_library < 03_views.sql
```

✅ Creates 3 analytical views for reporting

#### 4. Create Triggers

Run `04_triggers.sql`:

```bash
mysql -u root -p university_library < 04_triggers.sql
```

✅ Implements 3 database triggers for automation

#### 5. Create Stored Procedures

Run `05_procedures.sql`:

```bash
mysql -u root -p university_library < 05_procedures.sql
```

✅ Creates 2 stored procedures for core operations

#### 6. Run Test Queries

Run `06_queries_tests.sql`:

```bash
mysql -u root -p university_library < 06_queries_tests.sql
```

✅ Executes sample queries to verify setup

---

## File Structure

```
university-library-system/
│
├── 01_schema.sql              # Database & table creation
├── 02_seed.sql                # Sample data loading
├── 03_views.sql               # Analytical views
├── 04_triggers.sql            # Database triggers
├── 05_procedures.sql          # Stored procedures
├── 06_queries_tests.sql       # Test queries
│
├── README.md                  # This file
├── ERD_Diagram.png            # Entity Relationship Diagram
├── SCREENSHOTS/               # Implementation proof
│   ├── phpMyAdmin_books.png
│   ├── phpMyAdmin_members.png
│   ├── MySQL_Workbench.png
│   └── Query_Results.png
│
└── DOCUMENTATION/
    ├── API_Reference.md       # Procedure documentation
    └── Query_Guide.md         # Query examples
```

---

## Tables & Schema

### Core Tables

#### 1. **Publishers**
```
publisher_id (PK)   INT
name               VARCHAR(255) UNIQUE
contact            VARCHAR(200)
created_at         TIMESTAMP
```

#### 2. **Authors**
```
author_id          INT (PK)
first_name         VARCHAR(100)
last_name          VARCHAR(100)
bio                TEXT
created_at         TIMESTAMP
```

#### 3. **Genres**
```
genre_id           INT (PK)
name               VARCHAR(100) UNIQUE
description        TEXT
created_at         TIMESTAMP
```

#### 4. **Books**
```
book_id            INT (PK)
title              VARCHAR(300)
publisher_id       INT (FK → Publishers)
published_year     YEAR
isbn               VARCHAR(20) UNIQUE
pages              INT
total_copies       INT
available_copies   INT
description        TEXT
created_at         TIMESTAMP
updated_at         TIMESTAMP
```

#### 5. **Book_Authors** (Many-to-Many)
```
book_id            INT (FK → Books)
author_id          INT (FK → Authors)
PRIMARY KEY (book_id, author_id)
```

#### 6. **Book_Genres** (Many-to-Many)
```
book_id            INT (FK → Books)
genre_id           INT (FK → Genres)
PRIMARY KEY (book_id, genre_id)
```

#### 7. **Members**
```
member_id          INT (PK)
member_type        ENUM('STUDENT','EMPLOYEE','EXTERNAL')
first_name         VARCHAR(120)
last_name          VARCHAR(120)
email              VARCHAR(255) UNIQUE
phone              VARCHAR(20)
department         VARCHAR(100)
enrollment_no      VARCHAR(60)
join_date          DATE
is_active          BOOLEAN
created_at         TIMESTAMP
```

#### 8. **Staff**
```
staff_id           INT (PK)
username           VARCHAR(100) UNIQUE
full_name          VARCHAR(200)
role               ENUM('LIBRARIAN','ASSISTANT')
email              VARCHAR(255) UNIQUE
created_at         TIMESTAMP
```

#### 9. **Loans**
```
loan_id            INT (PK)
book_id            INT (FK → Books)
member_id          INT (FK → Members)
issued_by_staff_id INT (FK → Staff)
issue_date         DATE
due_date           DATE
return_date        DATE
status             ENUM('ISSUED','RETURNED','LOST','CANCELLED')
fine_amount        DECIMAL(10,2)
created_at         TIMESTAMP
updated_at         TIMESTAMP
```

#### 10. **Reservations**
```
reservation_id     INT (PK)
book_id            INT (FK → Books)
member_id          INT (FK → Members)
reserved_at        TIMESTAMP
status             ENUM('ACTIVE','CANCELLED','FULFILLED')
```

#### 11. **Fines**
```
fine_id            INT (PK)
loan_id            INT (FK → Loans)
amount             DECIMAL(10,2)
paid               BOOLEAN
created_at         TIMESTAMP
```

#### 12. **Audit_Logs**
```
log_id             INT (PK)
log_time           TIMESTAMP
actor              VARCHAR(100)
action             VARCHAR(100)
details            TEXT
```

---

## Key Features

### Data Validation
- ✅ Prevents negative available copies
- ✅ Ensures available copies ≤ total copies
- ✅ Validates fine amounts
- ✅ Enforces unique emails and ISBNs

### Transaction Support
- ✅ ACID compliance for critical operations
- ✅ Automatic rollback on errors
- ✅ Locked row updates during operations

### Indexing
- ✅ Primary keys on all tables
- ✅ Foreign key indexes
- ✅ Search indexes on title, email, type
- ✅ Status and member lookup indexes

### Relationships
- ✅ 1:N (Publishers → Books, Staff → Loans)
- ✅ M:N (Books ↔ Authors, Books ↔ Genres)
- ✅ Proper cascade on delete

---

## Stored Procedures

### 1. **issue_book()**

Issues a book to a member.

```sql
CALL issue_book(
    member_id,      -- IN: Member ID
    book_id,        -- IN: Book ID
    staff_id,       -- IN: Staff ID issuing book
    due_days        -- IN: Number of days for return
);
```

**Behavior**:
- Checks member and book exist
- If copies available: Issues book, decrements stock
- If no copies: Creates automatic reservation
- Logs all actions

### 2. **return_book()**

Returns a book and calculates fines.

```sql
CALL return_book(loan_id);  -- IN: Loan ID to return
```

**Behavior**:
- Validates loan exists and is ISSUED
- Calculates fine (₹5 per day overdue)
- Updates return date and status
- Increments available copies
- Creates fine record if applicable
- Logs action

---

## Views Available

### 1. **vw_catalog**

Complete book catalog with authors and genres.

```sql
SELECT * FROM vw_catalog;
```

Columns: book_id, title, isbn, published_year, total_copies, available_copies, authors, genres, publisher

### 2. **vw_overdue_loans**

Books that are overdue.

```sql
SELECT * FROM vw_overdue_loans;
```

Columns: loan_id, title, member_id, member_name, issue_date, due_date, days_overdue

### 3. **vw_top_borrowed**

Most borrowed books ranking.

```sql
SELECT * FROM vw_top_borrowed;
```

Columns: book_id, title, borrowed_count

---

## Triggers Implemented

### 1. **trg_books_before_update**

Validates book stock before updates.

- Prevents negative available_copies
- Prevents available > total

### 2. **trg_loans_after_insert**

Auto-updates book stock on loan creation.

- Decrements available_copies
- Logs RAW_ISSUE action

### 3. **trg_loans_after_update**

Auto-updates stock on loan return.

- Increments available_copies on ISSUED → RETURNED
- Logs RAW_RETURN action

---

## Sample Queries

### Get All Books with Authors

```sql
SELECT * FROM vw_catalog;
```

### Find Member's Borrowing History

```sql
SELECT 
    l.loan_id, b.title, l.issue_date, l.due_date, l.status
FROM loans l
JOIN books b ON l.book_id = b.book_id
WHERE l.member_id = 1
ORDER BY l.issue_date DESC;
```

### Check Overdue Books

```sql
SELECT * FROM vw_overdue_loans;
```

### Calculate Total Fines by Member

```sql
SELECT 
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    SUM(f.amount) AS total_fines
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
LEFT JOIN fines f ON l.loan_id = f.loan_id
GROUP BY m.member_id;
```

### Issue a Book

```sql
CALL issue_book(1, 2, 1, 14);  -- Member 1 borrows book 2 for 14 days
```

### Return a Book

```sql
CALL return_book(1);  -- Return loan #1
```

---

## Screenshots & Proof

This project has been fully implemented and tested in MySQL. Below are screenshots showing the working system:

### Screenshot 1: Database Tables Created
<img width="1899" height="863" alt="image" src="https://github.com/user-attachments/assets/a76140bd-ed64-455f-b95b-8cd34ee66c35" />


*Proof: All 12 tables successfully created in phpMyAdmin*

### Screenshot 2: Books Table Data
<img width="1903" height="878" alt="image" src="https://github.com/user-attachments/assets/828a20ab-1eb3-44b5-ae58-f55e9f7a4c64" />


*Proof: Sample book data with publishers, years, and copy counts*

### Screenshot 3: Members Table Data
<img width="1919" height="959" alt="image" src="https://github.com/user-attachments/assets/7049b4f5-a1f3-42e5-bbdf-aca6cd9d77dd" />

*Proof: Member records showing students and employees*

### Screenshot 4: MySQL Workbench Query Results
<img width="1919" height="959" alt="image" src="https://github.com/user-attachments/assets/419a7c19-419c-449b-beb2-3f5a449889d7" />


*Proof: Views and queries executing successfully with results*

---

## Performance Optimization

- ✅ **Indexes**: Created on frequently searched columns
- ✅ **Constraints**: Check constraints prevent invalid data
- ✅ **Triggers**: Automatic updates prevent inconsistency
- ✅ **Transactions**: ACID compliance ensures data safety
- ✅ **Foreign Keys**: Maintain referential integrity

---

## Future Enhancements

- [ ] Payment gateway integration for fine settlements
- [ ] Email notifications for due dates
- [ ] Mobile app for member self-service
- [ ] Advanced reporting dashboard
- [ ] Book recommendation engine
- [ ] Multi-branch support
- [ ] Barcode scanning integration
- [ ] Late fee waiver system

---

## Troubleshooting

### Issue: Triggers not working

**Solution**: Ensure MySQL version is 5.7+. Check trigger status:
```sql
SHOW TRIGGERS;
```

### Issue: Foreign key constraint fails

**Solution**: Verify parent records exist before inserting. Check constraints:
```sql
SELECT * FROM books WHERE book_id = X;
```

### Issue: Procedure errors

**Solution**: Verify DELIMITER is properly set. Re-run `05_procedures.sql`.

---

## Best Practices Used

1. **Normalization**: 3NF database design
2. **Constraints**: Check, Foreign Key, Unique constraints
3. **Transactions**: BEGIN/COMMIT/ROLLBACK for data safety
4. **Indexing**: Strategic indexes for performance
5. **Documentation**: Comments in all SQL files
6. **Audit Trail**: Complete logging of operations
7. **Error Handling**: SIGNAL SQLSTATE for errors
8. **Naming**: Clear, consistent naming conventions

---

## Author

**Project By**: Sai Purushotham  
**Location**: Nellore, Andhra Pradesh, India  
**Contact**: purushsai637@gmail.com 

---

## License

This project is created for educational purposes. Feel free to use and modify for your learning.

---

## Acknowledgments

- Database design principles from database engineering courses
- MySQL documentation and best practices
- SQL trigger and stored procedure examples
- University library operations research

---

## Quick Start Command

Run all files in sequence:

```bash
mysql -u root -p university_library < 01_schema.sql && \
mysql -u root -p university_library < 02_seed.sql && \
mysql -u root -p university_library < 03_views.sql && \
mysql -u root -p university_library < 04_triggers.sql && \
mysql -u root -p university_library < 05_procedures.sql && \
mysql -u root -p university_library < 06_queries_tests.sql
```

✅ **System Ready!**

---
 
**Status**: ✅ Production Ready
