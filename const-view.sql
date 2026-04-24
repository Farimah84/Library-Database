-- CONSTRAINT
CREATE TRIGGER IF NOT EXISTS prevent_negative_copies
BEFORE UPDATE OF AvailableCopies ON Books
WHEN NEW.AvailableCopies < 0
BEGIN SELECT RAISE(ABORT, 'Error: Negative copies'); END;

CREATE TRIGGER IF NOT EXISTS validate_loan_status
BEFORE INSERT ON Loans
WHEN NEW.Status NOT IN ('Borrowed','Returned','Overdue')
BEGIN SELECT RAISE(ABORT, 'Error: Invalid status'); END;

-- VIEW 1:
DROP VIEW IF EXISTS MemberStatusView;
CREATE VIEW MemberStatusView AS
SELECT m.MemberID, m.FirstName||' '||m.LastName AS MemberName,
COUNT(l.LoanID) AS TotalLoans,
SUM(CASE WHEN l.ReturnDate IS NULL THEN 1 ELSE 0 END) AS CurrentLoans,
CASE WHEN SUM(CASE WHEN l.ReturnDate IS NULL AND l.Status='Overdue' THEN 1 ELSE 0 END)>0 THEN 'Overdue'
WHEN SUM(CASE WHEN l.ReturnDate IS NULL THEN 1 ELSE 0 END)>0 THEN 'Active'
ELSE 'No Loan' END AS Status
FROM Members m LEFT JOIN Loans l ON m.MemberID=l.MemberID GROUP BY m.MemberID;

-- VIEW 2: Summery
DROP VIEW IF EXISTS LibrarySummaryView;
CREATE VIEW LibrarySummaryView AS
SELECT (SELECT COUNT(*) FROM Members) AS TotalMembers,
(SELECT COUNT(*) FROM Books) AS TotalBooks,
(SELECT SUM(AvailableCopies) FROM Books) AS TotalCopies,
(SELECT COUNT(*) FROM Loans WHERE ReturnDate IS NULL) AS ActiveLoans,
(SELECT COUNT(*) FROM Loans WHERE Status='Overdue') AS OverdueLoans;

-- Results
SELECT * FROM MemberStatusView;
SELECT * FROM LibrarySummaryView;
