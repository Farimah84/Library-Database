-- Library Database 
-- ============================================================
CREATE TABLE IF NOT EXISTS Members (
    MemberID INTEGER PRIMARY KEY AUTOINCREMENT,
    FirstName VARCHAR(30) NOT NULL,
    LastName VARCHAR(30) NOT NULL,
    Email VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Authors (
    AuthorID INTEGER PRIMARY KEY AUTOINCREMENT,
    FirstName VARCHAR(30) NOT NULL,
    LastName VARCHAR(30) NOT NULL,
    BirthYear INTEGER,
    Country VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS Books (
    BookID INTEGER PRIMARY KEY AUTOINCREMENT,
    Title VARCHAR(100) NOT NULL,
    AuthorID INTEGER NOT NULL,
    Publisher VARCHAR(50),
    Category VARCHAR(30),
    AvailableCopies INTEGER DEFAULT 1,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID) ON DELETE CASCADE
);

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

--Insert Data
-- ============================================================
INSERT INTO Members (FirstName, LastName, Email) VALUES
('Farimah', 'Nourpanah', 'farimahnourpanah@email.com'),
('Mahshad', 'Salehi', 'mahshadsalehi@email.com'),
('Babak', 'Matin Azad', 'matinbabak@email.com'),
('Shabnam', 'Shapoury', 'shabnamshapoury@email.com'),
('Artin', 'Panahi', 'artinpanahi@email.com');

INSERT INTO Authors (FirstName, LastName, BirthYear, Country) VALUES
('George', 'Orwell', 1950, 'England'),
('Virginia', 'Woolf', 1941, 'England'),
('Forough', 'Farrokhzad', 1934, 'Iran'),
('Bahram', 'Beizai', 1938, 'Iran'),
('Samad', 'Behrangi', 1939, 'Iran');

INSERT INTO Books (Title, AuthorID, Publisher, Category, AvailableCopies) VALUES
('1984', 1, 'Niloufar Publishing', 'Political', 3),
('A Room of Ones Own', 2, 'Niloufar Publishing', 'Feminism', 2),
('The Complete Poems of Forough', 3, 'Negah Publishing', 'Poetical', 4),
('Siavash-Khani', 4, 'Roushan-Fekran Publishing', 'Dramatic Literature', 1),
('Little Black Fish', 5, 'Nazar Publishing', 'Narrative Fiction', 3);

INSERT INTO Loans (MemberID, BookID, LoanDate, ReturnDate, Status) VALUES
(1, 1, '2024-06-01', '2024-06-14', 'Returned'),
(2, 2, '2024-06-05', NULL, 'Borrowed'),
(3, 3, '2024-06-10', '2024-06-23', 'Returned'),
(1, 4, '2024-06-15', NULL, 'Borrowed'),
(4, 1, '2024-06-20', NULL, 'Overdue'),
(5, 5, '2024-06-25', NULL, 'Borrowed');

-- ============================================================
-- Start Query
-- ============================================================

-- 1. SELECT WHERE LIKE
SELECT * FROM Members WHERE FirstName LIKE 'F%';

-- 2. BETWEEN
SELECT Title, AvailableCopies FROM Books WHERE AvailableCopies BETWEEN 2 AND 4;

-- 3. IN
SELECT Title, Category FROM Books WHERE Category IN ('Political', 'Feminism');

-- 4.  DISTINCT
SELECT DISTINCT Category FROM Books;

-- 5.  ORDER BY
SELECT FirstName, LastName FROM Members ORDER BY LastName DESC;

-- 6. CROSS JOIN
SELECT Members.FirstName, Books.Title FROM Members CROSS JOIN Books;

-- 7. (NATURAL JOIN) JOIN
SELECT 
    Books.Title,
    Authors.FirstName || ' ' || Authors.LastName AS AuthorName
FROM Books 
JOIN Authors ON Books.AuthorID = Authors.AuthorID;

-- 8.
SELECT 
    Loans.LoanID,
    Members.FirstName || ' ' || Members.LastName AS MemberName,
    Books.Title AS BookTitle,
    Loans.LoanDate,
    Loans.Status
FROM Loans
JOIN Members ON Loans.MemberID = Members.MemberID
JOIN Books ON Loans.BookID = Books.BookID;

-- 9. UNION 
SELECT Title FROM Books WHERE AuthorID = 1
UNION
SELECT Title FROM Books WHERE AvailableCopies > 2;

-- 10. INTERSECT
SELECT Title FROM Books WHERE AuthorID = 1
INTERSECT
SELECT Title FROM Books WHERE AvailableCopies > 2;

-- 11. EXCEPT
SELECT Title FROM Books WHERE AuthorID = 1
EXCEPT
SELECT Title FROM Books WHERE AvailableCopies > 2;

-- 12. DELETE: Loans 
DELETE FROM Loans 
WHERE MemberID = 1 AND BookID = 4 AND ReturnDate IS NULL;

-- 13. UPDATE
UPDATE Members 
SET Email = 'mahshad.new@email.com' 
WHERE MemberID = 2;

-- Results
SELECT 'After DELETE: Loans without MemberID=1, BookID=4' AS Info;
SELECT * FROM Loans;

SELECT 'After UPDATE: Members with MemberID=2' AS Info;
SELECT * FROM Members WHERE MemberID = 2;
