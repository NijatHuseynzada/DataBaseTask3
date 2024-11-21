README for SQL Normalization Procedure

Overview:
This project implements a SQL-based procedure (NormalizeBooks) to normalize data stored in a table called UnnormalizedBooks. The procedure transforms the unnormalized data into a series of normalized tables conforming to the principles of 1NF, 2NF, and 3NF. The procedure ensures that the data is efficiently organized.

Prerequisites:
Database System: PostgreSQL (PL/pgSQL)
Table Dependency: The UnnormalizedBooks table must exist and be populated before running the procedure. Below is the structure of the table:

Importing Unnormalized Data
Unnormalized Data Source
- File Name: UnnormalizedBooks.csv
- Description: This file contains the unnormalized data used in the project. It is uploaded as part of this repository.

Import Process
The unnormalized data was imported into the PostgreSQL database using pgAdmin4's Import/Export tool. Here’s the process followed:
1. Table Creation:
A table was created in PostgreSQL to match the structure of the unnormalized data.
Example SQL code for table creation:

CREATE TABLE IF NOT EXISTS UnnormalizedBooks (
    CRN INT,
    ISBN VARCHAR(20),
    Title VARCHAR(255),
    Authors VARCHAR(255),
    Edition INT,
    Publisher VARCHAR(100),
    PublisherAddress VARCHAR(255),
    Pages INT,
    Year INT,
    CourseName VARCHAR(100),
    PRIMARY KEY (CRN, ISBN)
);

2. Data Import:
- The unnormalized data was imported into the UnnormalizedBooks table using pgAdmin4's Import/Export wizard.
- Steps followed in pgAdmin4:
1. Open the created table (UnnormalizedBooks).
2. Right-click the table and select Import/Export.
3. Choose the file UnnormalizedBooks.csv
4. Configure the import options (e.g., file format, delimiter, etc.).
5. Execute the import.

The following query can be run to verify the data in the database:
SELECT * FROM UnnormalizedData;

The UnnormalizedBooks table contains denormalized book data with multiple authors stored in a single field (Authors), and duplicate information about publishers, courses, and books.

What the Procedure Does:
The NormalizeBooks procedure performs the following:
1. Drops Previous Tables: If previously created normalized tables exist, they are dropped to ensure a fresh start.

2. 1NF Transformation:
- Splits the Authors field (comma-separated values) into individual records using STRING_TO_ARRAY and UNNEST.
- Creates a table (Course_1NF) that satisfies 1NF by ensuring atomicity of data and unique rows.

3. 2NF Transformation:
Extracts functional dependencies into separate tables:
- Course_2NF: Maps CRN to CourseName.
- Book_2NF: Contains unique book information (e.g., ISBN, Title, Edition, etc.).
- Author_2NF: Establishes a relationship between ISBN and individual authors.

4. 3NF Transformation:
Eliminates transitive dependencies by creating:
- Publisher_3NF: Separates Publisher and its address.
- Book_3NF: Links books to their publishers.
- BookAuthor_3NF: Establishes a normalized relationship between books and authors.
- PublisherAddress_3NF: Stores unique publisher addresses.

5. Adds Primary and Foreign Keys:
Ensures data integrity by adding constraints and linking tables with foreign keys.

6. Execution:
The procedure is invoked with CALL NormalizeBooks(); to execute all normalization steps.

Created Tables:
1NF Table
- Course_1NF
Stores atomic records with the split authors.

2NF Tables
- Course_2NF
Columns: CRN, CourseName
Primary Key: CRN

- Book_2NF
Columns: ISBN, Title, Edition, Publisher, PublisherAddress, Pages, Year
Primary Key: ISBN

- Author_2NF
Columns: ISBN, Author
No primary key, as it transitions to 3NF.

3NF Tables
- Publisher_3NF
Columns: Publisher, PublisherAddress
Primary Key: Publisher

- Book_3NF
Columns: ISBN, Title, Edition, Publisher, Pages, Year
Primary Key: ISBN
Foreign Key: Publisher references Publisher_3NF(Publisher)

- PublisherAddress_3NF
Columns: PublisherAddress
Primary Key: PublisherAddress

- BookAuthor_3NF
Columns: ISBN, Author
Primary Key: (ISBN, Author)
Foreign Key: ISBN references Book_3NF(ISBN)

How to Use
1. Prepare the UnnormalizedBooks Table:
- Populate the table with denormalized data, ensuring it matches the structure provided above.
2. Run the Procedure:
- Execute the NormalizeBooks procedure using: CALL NormalizeBooks();
3. Verify the Results:
- Query the resulting tables (Course_1NF, Course_2NF, Book_2NF, Author_2NF, Publisher_3NF, Book_3NF, PublisherAddress_3NF, BookAuthor_3NF) to validate normalization.
- Check UnnormalizedBooks table
SELECT * FROM UnnormalizedBooks;

- Check 1NF table
SELECT * FROM Course_1NF;

- Check Course table in 2NF
SELECT * FROM Course_2NF;

- Check Book table in 2NF
SELECT * FROM Book_2NF;

- Check Author table in 2NF
SELECT * FROM Author_2NF;

- Check Book table in 3NF
SELECT * FROM Book_3NF;

- Check Publisher table in 3NF
SELECT * FROM Publisher_3NF;

- Check BookAuthor table in 3NF
SELECT * FROM BookAuthor_3NF;

4. Use the Normalized Data:
- The normalized tables can now be used for queries, reports, or integration with other applications.

Benefits of This Procedure
- Improved Data Integrity: Ensures that data adheres to normalization rules and avoids redundancy.
- Simplified Updates: Changes to a specific entity are reflected across related data without duplication.
- Enhanced Query Efficiency: Organized and indexed tables improve the performance of SQL queries.







