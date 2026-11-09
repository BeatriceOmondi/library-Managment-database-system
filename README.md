# Library Management System Database

## Overview

A relational database project built with MariaDB and SQL to manage library books, authors, categories, members, and borrowing activities.

The project focuses on database design, data integrity, inventory management, and automated loan processing.

## Features

- Book and category management.
- Author management and many-to-many book-author relationships.
- Library member records.
- Book borrowing and return tracking.
- Automatic book availability updates.
- Prevention of borrowing when no copies are available.
- Prevention of duplicate active loans for the same member and book.
- Loan and inventory integrity constraints.

## Database Structure

The database contains six tables:

| Table | Purpose |
|---|---|
| Categories | Stores book categories. |
| Authors | Stores author information. |
| Books | Stores book details and inventory. |
| Book_Authors | Connects books and authors. |
| Members | Stores library member information. |
| Loans | Tracks borrowing and returns. |

### Database Relationships

- One category can contain multiple books.
- Books and authors have a many-to-many relationship through `Book_Authors`.
- One member can have multiple loan records.
- A book can appear in multiple loan records over time.

## Data Integrity and Performance

The database uses:

- Primary keys and foreign keys.
- UNIQUE and NOT NULL constraints.
- CHECK constraints for inventory, loan dates, and fine amounts.
- Indexes for loan lookups.
- Foreign-key deletion rules to protect related records.

## Automated Loan Management

Four triggers automate loan processing:

| Trigger | Function |
|---|---|
| `before_loan_insert` | Validates book availability and prevents duplicate active loans. |
| `after_loan_insert` | Decreases available copies after borrowing. |
| `after_loan_update` | Restores available copies when a book is returned. |
| `after_loan_delete` | Restores available copies when an active loan is deleted. |

## Testing and Validation

The database was tested using MariaDB.

Validation included:

- Successful creation of all six tables.
- Successful creation of all four triggers.
- Foreign-key enforcement.
- UNIQUE constraint enforcement.
- CHECK constraint enforcement.
- Prevention of invalid borrowing requests.
- Automatic inventory updates after borrowing and returning.
- Verification that inventory is not restored twice during unrelated loan updates.
- Successful import into a fresh test database.

## Setup and Installation

### Requirements

- MariaDB Server 11.8.3 or compatible version.
- MariaDB command-line client.

### 1. Clone the repository

```bash
git clone https://github.com/BeatriceOmondi/library-Managment-database-system.git
cd library-Managment-database-system
```

### 2. Create the database

```sql
CREATE DATABASE library_management;
```

### 3. Import the database schema and triggers

```bash
sudo mariadb library_management < library.sql
```

### 4. Verify the tables and triggers

```sql
USE library_management;
SHOW TABLES;
SHOW TRIGGERS;
```

## Repository Structure

```text
library-Managment-database-system/
├── library.sql
├── image.png
└── README.md
```

## Project Scope

This project currently focuses on the database layer. A frontend interface and application backend have not yet been implemented.

## Technologies

- SQL
- MariaDB
- Relational Database Design
- Database Constraints and Indexing
- SQL Triggers
