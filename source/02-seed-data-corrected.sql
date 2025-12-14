-- ============================================================================
-- UNIVERSITY LIBRARY MANAGEMENT SYSTEM
-- Sample Data (Corrected)
-- ============================================================================

USE university_library;

-- Insert Publishers
INSERT INTO publishers (name, contact) VALUES
('Oxford University Press', 'oxford@example.com'),
('Pearson Education', 'pearson@example.com'),
('Local Academic Press', 'local@example.com');

-- Insert Authors
INSERT INTO authors (first_name, last_name, bio) VALUES
('George', 'Orwell', 'British dystopian novelist and journalist'),
('J.K.', 'Rowling', 'British fantasy novelist'),
('Thomas', 'Cormen', 'American computer scientist specializing in algorithms');

-- Insert Genres
INSERT INTO genres (name, description) VALUES
('Fiction', 'Imaginative fictional works'),
('Fantasy', 'Fantasy and magical worlds'),
('Computer Science', 'Technical and programming books');

-- Insert Books
INSERT INTO books (title, publisher_id, published_year, isbn, pages, total_copies, available_copies, description) VALUES
('1984', 1, 1949, '9780451524935', 328, 3, 3, 'A dystopian novel about totalitarianism'),
('Harry Potter and the Philosopher Stone', 2, 1997, '9780747532699', 223, 5, 5, 'First book in the Harry Potter series'),
('Introduction to Algorithms', 2, 2009, '9780262033848', 1312, 2, 2, 'Comprehensive computer science textbook');

-- Link Books to Authors
INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1),
(2, 2),
(3, 3);

-- Link Books to Genres
INSERT INTO book_genres (book_id, genre_id) VALUES
(1, 1),
(2, 2),
(3, 3);

-- Insert Members
INSERT INTO members (member_type, first_name, last_name, email, phone, department, enrollment_no) VALUES
('STUDENT', 'Sai', 'Porus', 'sai@example.com', '9000000000', 'Computer Science', 'CSE001'),
('STUDENT', 'Arjun', 'Kumar', 'arjun@example.com', '9000000001', 'Information Technology', 'IT001'),
('EMPLOYEE', 'Jaswanth', 'K', 'jas@example.com', '9000000002', 'Library', NULL),
('EXTERNAL', 'Ravi', 'Shankar', 'ravi@example.com', '9000000003', NULL, NULL);

-- Insert Staff
INSERT INTO staff (username, full_name, role, email, phone) VALUES
('lib_admin', 'Arun Kumar', 'LIBRARIAN', 'arun@example.com', '9100000000'),
('lib_assist', 'Meera Sharma', 'ASSISTANT', 'meera@example.com', '9100000001');

-- Insert Loans (Example: Currently issued book)
INSERT INTO loans (book_id, member_id, issued_by_staff_id, issue_date, due_date, status) VALUES
(1, 1, 1, CURDATE() - INTERVAL 10 DAY, CURDATE() + INTERVAL 4 DAY, 'ISSUED');

-- Insert Loans (Example: Returned book)
INSERT INTO loans (book_id, member_id, issued_by_staff_id, issue_date, due_date, return_date, status, fine_amount) VALUES
(2, 2, 1, CURDATE() - INTERVAL 20 DAY, CURDATE() - INTERVAL 10 DAY, CURDATE() - INTERVAL 9 DAY, 'RETURNED', 0.00);

-- Insert Reservations
INSERT INTO reservations (book_id, member_id, status) VALUES
(3, 3, 'ACTIVE');

-- Insert Fines
INSERT INTO fines (loan_id, amount, paid) VALUES
(2, 5.00, FALSE);