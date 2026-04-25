-- Complete Library Database
-- ============================================================
CREATE TABLE IF NOT EXISTS Members (
    MemberID INTEGER PRIMARY KEY AUTOINCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100)
);


-- ============================================================
CREATE TABLE IF NOT EXISTS Authors (
    AuthorID INTEGER PRIMARY KEY AUTOINCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    BirthYear INTEGER,
    Country VARCHAR(50)
);


-- ============================================================
CREATE TABLE IF NOT EXISTS Books (
    BookID INTEGER PRIMARY KEY AUTOINCREMENT,
    Title VARCHAR(200) NOT NULL,
    AuthorID INTEGER NOT NULL,
    Publisher VARCHAR(100),
    Category VARCHAR(50),
    AvailableCopies INTEGER DEFAULT 1,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID) ON DELETE CASCADE
);


-- ============================================================
CREATE TABLE IF NOT EXISTS Loans (
    LoanID INTEGER PRIMARY KEY AUTOINCREMENT,
    MemberID INTEGER NOT NULL,
    BookID INTEGER NOT NULL,
    LoanDate DATE NOT NULL,
    ReturnDate DATE,
    Status TEXT DEFAULT 'Borrowed',
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID) ON DELETE CASCADE,
    FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE CASCADE
);


-- ============================================================
INSERT INTO Members (FirstName, LastName, Email) VALUES
('Farimah', 'Nourpanah', 'farimahnourpanah@email.com'),
('Mahshad', 'Salehi', 'mahshadsalehi@email.com'),
('Babak', 'Matin', 'matinbabak@email.com'),
('Shabnam', 'Shapoury', 'shabnamshapoury@email.com'),
('Artin', 'Panahi', 'artinpanahi@email.com');

-- ============================================================
INSERT INTO Authors (FirstName, LastName, BirthYear, Country) VALUES
('George', 'Orwell', 1950, 'England'),
('Virginia', 'Woolf', 1941, 'England'),
('Forough', 'Farrokhzad', 1934, 'Iran'),
('Bahram', 'Beizai', 1938, 'Iran'),
('Samad', 'Behrangi', 1339, 'Iran');

-- ============================================================
INSERT INTO Books (Title, AuthorID, Publisher, Category, AvailableCopies) VALUES
('1984', 1, 'Niloufar Publishing', 'Political', 3),
('A Room of Ones Own', 2, 'Niloufar Publishing', 'Feminism', 2),
('The Compelete Poems of Forough', 3, 'Negah Publishing', 'Poetical', 4),
('Siavash-Khani', 4, 'Roushan-Fekran Publishing', 'Dramatic Literature', 1),
('Little Black Fish', 5, 'Nazar Publishing', 'Narrative Fiction', 3);

-- ============================================================
INSERT INTO Loans (MemberID, BookID, LoanDate, ReturnDate, Status) VALUES
(1, 1, '2024-06-01', '2024-06-14', 'Returned'),
(2, 2, '2024-06-05', NULL, 'Borrowed'),
(3, 3, '2024-06-10', '2024-06-23', 'Returned'),
(1, 4, '2024-06-15', NULL, 'Borrowed'),
(4, 1, '2024-06-20', NULL, 'Overdue'),
(5, 5, '2024-06-25', NULL, 'Borrowed');

-- ============================================================
SELECT * FROM Members;


-- ============================================================
SELECT * FROM Books WHERE AvailableCopies > 0;

-- ============================================================
SELECT * FROM Books WHERE AuthorID = 2;

-- ============================================================
SELECT 
    b.BookID,
    b.Title,
    a.FirstName || ' ' || a.LastName AS AuthorName,
    b.Publisher,
    b.Category,
    b.AvailableCopies
FROM Books b
JOIN Authors a ON b.AuthorID = a.AuthorID;

-- ============================================================
SELECT 
    l.LoanID,
    m.FirstName || ' ' || m.LastName AS MemberName,
    b.Title AS BookTitle,
    l.LoanDate,
    l.Status
FROM Loans l
JOIN Members m ON l.MemberID = m.MemberID
JOIN Books b ON l.BookID = b.BookID;

-- ============================================================
SELECT 
    b.Title,
    a.FirstName || ' ' || a.LastName AS AuthorName,
    m.FirstName || ' ' || m.LastName AS Borrower,
    l.LoanDate,
    l.Status
FROM Loans l
JOIN Books b ON l.BookID = b.BookID
JOIN Authors a ON b.AuthorID = a.AuthorID
JOIN Members m ON l.MemberID = m.MemberID
WHERE l.ReturnDate IS NULL;

-- ============================================================
SELECT 
    m.MemberID,
    m.FirstName || ' ' || m.LastName AS MemberName,
    COUNT(l.LoanID) AS TotalLoans
FROM Members m
LEFT JOIN Loans l ON m.MemberID = l.MemberID
GROUP BY m.MemberID, m.FirstName, m.LastName;

-- ============================================================
SELECT SUM(AvailableCopies) AS AvailableBooks FROM Books;

-- ============================================================
SELECT 
    b.Title,
    a.FirstName || ' ' || a.LastName AS AuthorName,
    COUNT(l.LoanID) AS BorrowCount
FROM Books b
JOIN Authors a ON b.AuthorID = a.AuthorID
JOIN Loans l ON b.BookID = l.BookID
GROUP BY b.BookID, b.Title, a.FirstName, a.LastName
ORDER BY BorrowCount DESC;

-- ============================================================
UPDATE Books 
SET AvailableCopies = AvailableCopies - 1 
WHERE BookID = 1 AND AvailableCopies > 0;

-- ============================================================
UPDATE Loans 
SET ReturnDate = date('now'), Status = 'Returned' 
WHERE LoanID = 2;

UPDATE Books 
SET AvailableCopies = AvailableCopies + 1 
WHERE BookID = 2;

-- ============================================================
DELETE FROM Members WHERE MemberID = 5;
 
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_member_name ON Members(LastName, FirstName);
CREATE INDEX IF NOT EXISTS idx_book_title ON Books(Title);
CREATE INDEX IF NOT EXISTS idx_author_name ON Authors(LastName, FirstName);

-- ============================================================
SELECT * FROM Authors;

-- ============================================================
SELECT 
    a.AuthorID,
    a.FirstName || ' ' || a.LastName AS AuthorName,
    a.BirthYear,
    a.Country,
    COUNT(b.BookID) AS BookCount
FROM Authors a
LEFT JOIN Books b ON a.AuthorID = b.AuthorID
GROUP BY a.AuthorID, a.FirstName, a.LastName, a.BirthYear, a.Country;
