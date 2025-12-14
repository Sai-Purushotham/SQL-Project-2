-- ============================================================================
-- UNIVERSITY LIBRARY MANAGEMENT SYSTEM
-- Complete & Corrected Database Schema
-- ============================================================================

CREATE DATABASE IF NOT EXISTS university_library;
USE university_library;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS fines;
DROP TABLE IF EXISTS reservations;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS book_genres;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS publishers;

-- ============================================================================
-- PUBLISHERS TABLE
-- ============================================================================
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    contact VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_publisher_name (name)
) ENGINE=InnoDB;

-- ============================================================================
-- AUTHORS TABLE
-- ============================================================================
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_author_name (first_name, last_name)
) ENGINE=InnoDB;

-- ============================================================================
-- GENRES TABLE
-- ============================================================================
CREATE TABLE genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_genre_name (name)
) ENGINE=InnoDB;

-- ============================================================================
-- BOOKS TABLE
-- ============================================================================
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    publisher_id INT,
    published_year YEAR,
    isbn VARCHAR(20) UNIQUE,
    pages INT,
    total_copies INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    CONSTRAINT chk_available_not_negative CHECK (available_copies >= 0),
    CONSTRAINT chk_total_positive CHECK (total_copies > 0),
    INDEX idx_books_title (title),
    INDEX idx_books_isbn (isbn),
    INDEX idx_books_publisher (publisher_id)
) ENGINE=InnoDB;

-- ============================================================================
-- BOOK_AUTHORS TABLE (Many-to-Many)
-- ============================================================================
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================================
-- BOOK_GENRES TABLE (Many-to-Many)
-- ============================================================================
CREATE TABLE book_genres (
    book_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (book_id, genre_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================================
-- MEMBERS TABLE
-- ============================================================================
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    member_type ENUM('STUDENT','EMPLOYEE','EXTERNAL') NOT NULL,
    first_name VARCHAR(120) NOT NULL,
    last_name VARCHAR(120) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    department VARCHAR(100),
    enrollment_no VARCHAR(60),
    join_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_email_valid CHECK (email LIKE '%@%.%'),
    INDEX idx_member_type (member_type),
    INDEX idx_member_email (email),
    INDEX idx_member_name (first_name, last_name)
) ENGINE=InnoDB;

-- ============================================================================
-- STAFF TABLE
-- ============================================================================
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    full_name VARCHAR(200) NOT NULL,
    role ENUM('LIBRARIAN','ASSISTANT') DEFAULT 'ASSISTANT',
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_staff_username (username),
    INDEX idx_staff_role (role)
) ENGINE=InnoDB;

-- ============================================================================
-- LOANS TABLE
-- ============================================================================
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    issued_by_staff_id INT,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('ISSUED','RETURNED','LOST','CANCELED') DEFAULT 'ISSUED',
    fine_amount DECIMAL(10,2) DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT,
    FOREIGN KEY (issued_by_staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL,
    CONSTRAINT chk_fine_not_negative CHECK (fine_amount >= 0),
    CONSTRAINT chk_return_after_issue CHECK (return_date IS NULL OR return_date >= issue_date),
    INDEX idx_loans_member (member_id),
    INDEX idx_loans_book (book_id),
    INDEX idx_loans_status (status),
    INDEX idx_loans_dates (issue_date, due_date)
) ENGINE=InnoDB;

-- ============================================================================
-- RESERVATIONS TABLE
-- ============================================================================
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reserved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('ACTIVE','CANCELED','FULFILLED') DEFAULT 'ACTIVE',
    fulfilled_at TIMESTAMP NULL,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    INDEX idx_reservations_book (book_id),
    INDEX idx_reservations_member (member_id),
    INDEX idx_reservations_status (status)
) ENGINE=InnoDB;

-- ============================================================================
-- FINES TABLE
-- ============================================================================
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    paid BOOLEAN DEFAULT FALSE,
    paid_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE,
    CONSTRAINT chk_fine_amount_positive CHECK (amount > 0),
    INDEX idx_fines_loan (loan_id),
    INDEX idx_fines_paid (paid)
) ENGINE=InnoDB;

-- ============================================================================
-- AUDIT_LOGS TABLE
-- ============================================================================
CREATE TABLE audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actor VARCHAR(200),
    action VARCHAR(100) NOT NULL,
    details TEXT,
    status VARCHAR(50),
    INDEX idx_audit_time (log_time),
    INDEX idx_audit_action (action)
) ENGINE=InnoDB;