# Library Database System (SQLite Version)

A student academic project for a **Database course** – a complete SQLite database schema for a small library management system.  
The project demonstrates core database concepts including table creation, relationships (foreign keys), sample data insertion, and essential SQL queries (selection, filtering, joins, set operations, `DELETE`, `UPDATE`).

## Project Overview

This database manages:
- **Members** – library members with personal details
- **Authors** – book authors with biographical information
- **Books** – book titles, categories, authors, and available copies
- **Loans** – borrowing transactions, due dates, return statuses

All data is stored in a relational schema with proper **primary keys** and **foreign key constraints** to maintain referential integrity.

## Database Schema

| Table     | Key Columns                                                                 | Relationships                             |
|-----------|-----------------------------------------------------------------------------|-------------------------------------------|
| Members   | `MemberID` (PK), `FirstName`, `LastName`, `Email`                          | –                                         |
| Authors   | `AuthorID` (PK), `FirstName`, `LastName`, `BirthYear`, `Country`           | –                                         |
| Books     | `BookID` (PK), `Title`, `AuthorID` (FK), `Publisher`, `Category`, `AvailableCopies` | `AuthorID` → `Authors(AuthorID)`        |
| Loans     | `LoanID` (PK), `MemberID` (FK), `BookID` (FK), `LoanDate`, `ReturnDate`, `Status` | `MemberID` → `Members(MemberID)`, <br>`BookID` → `Books(BookID)` |

All foreign keys are defined with `ON DELETE CASCADE` to automatically remove dependent records when a parent record is deleted.

## How to Run

### Prerequisites
- [SQLite](https://www.sqlite.org/download.html) (command-line tool or any SQLite GUI like DB Browser for SQLite, DBeaver, or SQLiteStudio)

### Setup Instructions

1. **Clone the repository** (or download the `main.sql` file):
   ```bash
   git clone https://github.com/Farimah84/Library-Database.git
   cd Library-Database

2. Run the script using SQLite command-line:
'''
sqlite3 library.db < main.sql
'''
- This will:

- Create the database file library.db

- Create all tables (Members, Authors, Books, Loans)

- Insert sample data (5 members, 5 authors, 6 books, 6 loans)

- Execute 13 demonstration queries

3. Alternative – Open main.sql in a SQLite GUI and execute it directly.

## Sample Data Overview
- Members: Farimah Nourpanah, Mahshad Salehi, Babak Matin Azad, Shabnam Shapoury, Artin Panahi
- Authors: George Orwell, Virginia Woolf, Forough Farrokhzad, Bahram Beizai, Samad Behrangi
- Books: *1984*, A Room of One's Own, The Complete Poems of Forough, Siavash-Khani, Little Black Fish, Animal Farm
- Loans: A mix of returned, borrowed, and overdue statuses with realistic dates

## Included SQL Queries (Educational Examples)
The script contains 13 queries demonstrating essential SQL concepts:
