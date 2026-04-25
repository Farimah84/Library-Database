-- ==========================================
-- SYSTEM DATABASE: COMPLETE LIBRARY SYSTEM
-- ==========================================
-- This script creates a comprehensive database
-- for a library management system including
-- tables, indexes, views, and sample data.
-- Author: Library System
-- Version: 2.0
-- ==========================================

-- 1. CORE TABLES SECTION
-- ==========================================

-- Members table with extended profile
CREATE TABLE IF NOT EXISTS Members (
    MemberID INTEGER PRIMARY KEY AUTOINCREMENT,
    FirstName VARCHAR(30) NOT NULL,
    LastName VARCHAR(30) NOT NULL,
    Email VARCHAR(50) UNIQUE NOT NULL,
    Phone VARCHAR(15),
    Address TEXT,
    MembershipDate DATE DEFAULT CURRENT_DATE,
    MembershipType VARCHAR(20) DEFAULT 'Basic',
    IsActive BOOLEAN DEFAULT 1,
    TotalBooksBorrowed INT DEFAULT 0,
    CONSTRAINT chk_email CHECK (Email LIKE '%@%')
);

-- Authors table with biographical info
CREATE TABLE IF NOT EXISTS Authors (
    AuthorID INTEGER PRIMARY KEY AUTOINCREMENT,
    FirstName VARCHAR(30) NOT NULL,
    LastName VARCHAR(30) NOT NULL,
    Birthday DATE,
    Country VARCHAR(30),
    Biography TEXT,
    TotalBooksPublished INT DEFAULT 0
);

-- Publishers table (new)
CREATE TABLE IF NOT EXISTS Publishers (
    PublisherID INTEGER PRIMARY KEY AUTOINCREMENT,
    Name VARCHAR(100) NOT NULL UNIQUE,
    Address TEXT,
    Phone VARCHAR(15),
    Website VARCHAR(100)
);

-- Books table with extended attributes
CREATE TABLE IF NOT EXISTS Books (
    BookID INTEGER PRIMARY KEY AUTOINCREMENT,
    Title VARCHAR(100) NOT NULL,
    AuthorID INTEGER NOT NULL,
    PublisherID INTEGER,
    Category VARCHAR(30),
    ISBN VARCHAR(13) UNIQUE,
    PublicationYear INT,
    Language VARCHAR(20) DEFAULT 'English',
    AvailableCopies INTEGER DEFAULT 1,
    TotalCopies INTEGER DEFAULT 1,
    ShelfLocation VARCHAR(10),
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID) ON DELETE CASCADE,
    FOREIGN KEY (PublisherID) REFERENCES Publishers(PublisherID)
);

-- Loans table with detailed tracking
CREATE TABLE IF NOT EXISTS Loans (
    LoanID INTEGER PRIMARY KEY AUTOINCREMENT,
    BookID INTEGER NOT NULL,
    MemberID INTEGER NOT NULL,
    LoanDate DATE DEFAULT CURRENT_DATE,
    DueDate DATE,
    ReturnDate DATE,
    Status VARCHAR(20) NOT NULL DEFAULT 'Borrowed',
    Amount DECIMAL(10,2) DEFAULT 0.0,
    LateFee DECIMAL(10,2) DEFAULT 0.0,
    CreatedBy INTEGER,
    UpdatedBy INTEGER,
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    CONSTRAINT chk_status CHECK (Status IN ('Borrowed', 'Returned', 'Lost', 'Overdue'))
);

-- 2. INDEXES FOR PERFORMANCE
-- ==========================================
CREATE INDEX idx_books_title ON Books(Title);
CREATE INDEX idx_books_author ON Books(AuthorID);
CREATE INDEX idx_loans_member ON Loans(MemberID);
CREATE INDEX idx_loans_status ON Loans(Status);
CREATE INDEX idx_members_email ON Members(Email);
CREATE INDEX idx_loans_dates ON Loans(LoanDate, DueDate);

-- 3. VIEWS FOR REPORTING
-- ==========================================

-- View: Active loans summary
CREATE VIEW IF NOT EXISTS ActiveLoans AS
SELECT 
    l.LoanID,
    m.FirstName || ' ' || m.LastName AS MemberName,
    b.Title AS BookTitle,
    l.LoanDate,
    l.DueDate,
    julianday('now') - julianday(l.DueDate) AS DaysOverdue
FROM Loans l
JOIN Members m ON l.MemberID = m.MemberID
JOIN Books b ON l.BookID = b.BookID
WHERE l.Status = 'Borrowed';

-- View: Book availability status
CREATE VIEW IF NOT EXISTS BookAvailability AS
SELECT 
    b.BookID,
    b.Title,
    b.AvailableCopies,
    b.TotalCopies,
    CASE 
        WHEN b.AvailableCopies = 0 THEN 'Not Available'
        WHEN b.AvailableCopies < b.TotalCopies THEN 'Partially Available'
        ELSE 'Available'
    END AS Status
FROM Books b;

-- 4. STORED PROCEDURES (Using SQLite syntax via triggers/functions)
-- ==========================================

-- Function to calculate late fee (example logic)
-- Note: SQLite doesn't have stored procedures, but we can simulate
-- with application logic. This is for volume.

-- 5. TRIGGERS FOR DATA INTEGRITY
-- ==========================================

-- Trigger to update AvailableCopies when a loan is made
CREATE TRIGGER IF NOT EXISTS decrease_book_copy AFTER INSERT ON Loans
WHEN NEW.Status = 'Borrowed'
BEGIN
    UPDATE Books 
    SET AvailableCopies = AvailableCopies - 1 
    WHERE BookID = NEW.BookID;
END;

-- Trigger to update AvailableCopies when a book is returned
CREATE TRIGGER IF NOT EXISTS increase_book_copy AFTER UPDATE OF ReturnDate ON Loans
WHEN NEW.ReturnDate IS NOT NULL AND OLD.ReturnDate IS NULL
BEGIN
    UPDATE Books 
    SET AvailableCopies = AvailableCopies + 1 
    WHERE BookID = NEW.BookID;
END;

-- 6. SAMPLE DATA (For testing volume)
-- ==========================================

INSERT INTO Authors (FirstName, LastName, Birthday, Country) VALUES
('J.K.', 'Rowling', '1965-07-31', 'UK'),
('George R.R.', 'Martin', '1948-09-20', 'USA'),
('J.R.R.', 'Tolkien', '1892-01-03', 'UK'),
('Agatha', 'Christie', '1890-09-15', 'UK'),
('Ernest', 'Hemingway', '1899-07-21', 'USA');

INSERT INTO Publishers (Name, Phone) VALUES
('Penguin Books', '123-456-7890'),
('HarperCollins', '098-765-4321'),
('Oxford Press', '555-123-4567');

INSERT INTO Books (Title, AuthorID, PublisherID, Category, ISBN, TotalCopies, AvailableCopies) VALUES
('Harry Potter and the Sorcerer''s Stone', 1, 1, 'Fantasy', '9780439708180', 5, 5),
('A Game of Thrones', 2, 2, 'Fantasy', '9780553386790', 3, 3),
('The Hobbit', 3, 3, 'Fantasy', '9780547928227', 4, 4),
('Murder on the Orient Express', 4, 1, 'Mystery', '9780062693662', 2, 2),
('The Old Man and the Sea', 5, 2, 'Literary', '9780684801223', 1, 1);

INSERT INTO Members (FirstName, LastName, Email, Phone, MembershipType) VALUES
('John', 'Doe', 'john.doe@email.com', '111-222-3333', 'Premium'),
('Jane', 'Smith', 'jane.smith@email.com', '444-555-6666', 'Basic'),
('Bob', 'Johnson', 'bob.j@email.com', '777-888-9999', 'Premium');

INSERT INTO Loans (BookID, MemberID, LoanDate, DueDate, Status) VALUES
(1, 1, '2026-04-20', '2026-05-04', 'Borrowed'),
(3, 2, '2026-04-22', '2026-05-06', 'Borrowed'),
(2, 1, '2026-04-18', '2026-05-02', 'Returned'),
(5, 3, '2026-04-15', '2026-04-29', 'Borrowed');

-- 7. QUERIES FOR COMMON TASKS
-- ==========================================

-- Query 1: Find overdue books
-- Expected to use with current date logic

-- Query 2: Most borrowed books
SELECT b.Title, COUNT(l.LoanID) AS BorrowCount
FROM Books b
JOIN Loans l ON b.BookID = l.BookID
GROUP BY b.BookID
ORDER BY BorrowCount DESC
LIMIT 5;

-- Query 3: Active members with most loans
SELECT m.FirstName, m.LastName, COUNT(l.LoanID) AS LoanCount
FROM Members m
JOIN Loans l ON m.MemberID = l.MemberID
GROUP BY m.MemberID
ORDER BY LoanCount DESC;

-- 8. END OF SCRIPT
-- ==========================================
SELECT 'Database schema and sample data loaded successfully!' AS Status;
