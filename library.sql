
-- Library Management System Database
-- Purpose: Manages books, categories, authors, members, and loans.

-- Create Categories table
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
) COMMENT 'Stores book categories';

-- Create Authors table
CREATE TABLE Authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50),
    UNIQUE (first_name, last_name, birth_date)
) COMMENT 'Stores author information';

-- Create Books table
CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(13) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    publication_year INT,
    publisher VARCHAR(100),
    total_copies INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1,
    category_id INT NOT NULL,
    CHECK (available_copies <= total_copies),
    CHECK (available_copies >= 0),
    FOREIGN KEY (category_id)
        REFERENCES Categories(category_id)
        ON DELETE RESTRICT
) COMMENT 'Stores book information';

-- Create Book_Authors junction table
CREATE TABLE Book_Authors (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id)
        REFERENCES Books(book_id)
        ON DELETE CASCADE,
    FOREIGN KEY (author_id)
        REFERENCES Authors(author_id)
        ON DELETE CASCADE
) COMMENT 'Connects books and authors';

-- Create Members table
CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    join_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    address VARCHAR(255)
) COMMENT 'Stores library member information';

-- Create Loans table
CREATE TABLE Loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE,
    fine_amount DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (book_id)
        REFERENCES Books(book_id)
        ON DELETE RESTRICT,
    FOREIGN KEY (member_id)
        REFERENCES Members(member_id)
        ON DELETE RESTRICT,
    CHECK (due_date > loan_date),
    CHECK (fine_amount >= 0)
) COMMENT 'Tracks book loans and returns';

-- Create indexes for loan lookups
CREATE INDEX idx_loans_book_id ON Loans(book_id);
CREATE INDEX idx_loans_member_id ON Loans(member_id);


-- Trigger 1: Validate borrowing requests
DELIMITER //

CREATE TRIGGER before_loan_insert
BEFORE INSERT ON Loans
FOR EACH ROW
BEGIN
    DECLARE copies_available INT;

    SELECT available_copies
    INTO copies_available
    FROM Books
    WHERE book_id = NEW.book_id;

    IF copies_available IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Book does not exist';
    END IF;

    IF copies_available <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No copies available for borrowing';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM Loans
        WHERE book_id = NEW.book_id
        AND member_id = NEW.member_id
        AND return_date IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Member already has an active loan for this book';
    END IF;
END //

-- Trigger 2: Decrease available copies after borrowing
CREATE TRIGGER after_loan_insert
AFTER INSERT ON Loans
FOR EACH ROW
BEGIN
    UPDATE Books
    SET available_copies = available_copies - 1
    WHERE book_id = NEW.book_id;
END //

-- Trigger 3: Restore available copies after returning a book
CREATE TRIGGER after_loan_update
AFTER UPDATE ON Loans
FOR EACH ROW
BEGIN
    IF OLD.return_date IS NULL AND NEW.return_date IS NOT NULL THEN
        UPDATE Books
        SET available_copies = available_copies + 1
        WHERE book_id = NEW.book_id;
    END IF;
END //

-- Trigger 4: Restore available copies when an active loan is deleted
CREATE TRIGGER after_loan_delete
AFTER DELETE ON Loans
FOR EACH ROW
BEGIN
    IF OLD.return_date IS NULL THEN
        UPDATE Books
        SET available_copies = available_copies + 1
        WHERE book_id = OLD.book_id;
    END IF;
END //

DELIMITER ;
