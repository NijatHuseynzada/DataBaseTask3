DROP PROCEDURE IF EXISTS NormalizeBooks;

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
	
CREATE OR REPLACE PROCEDURE NormalizeBooks()
LANGUAGE plpgsql
AS $$
BEGIN
   
    DROP TABLE IF EXISTS BookAuthor_3NF CASCADE;
    DROP TABLE IF EXISTS PublisherAddress_3NF CASCADE;
    DROP TABLE IF EXISTS Book_3NF CASCADE;
    DROP TABLE IF EXISTS Publisher_3NF CASCADE;
    DROP TABLE IF EXISTS Author_2NF CASCADE;
    DROP TABLE IF EXISTS Book_2NF CASCADE;
    DROP TABLE IF EXISTS Course_2NF CASCADE;
    DROP TABLE IF EXISTS Course_1NF CASCADE;
   
   
  --    1NF
    CREATE TABLE Course_1NF AS
    SELECT 
        CRN,
        ISBN,
        Title,
        TRIM(UNNEST(STRING_TO_ARRAY(Authors, ','))) AS Author, -- Split authors into separate rows
        Edition,
        Publisher,
        PublisherAddress,
        Pages,
        Year,
        CourseName
    FROM UnnormalizedBooks;

    ALTER TABLE Course_1NF ADD PRIMARY KEY (CRN, ISBN, Author);

    --  2NF tables
    CREATE TABLE Course_2NF AS
    SELECT DISTINCT CRN, CourseName
    FROM Course_1NF;

    ALTER TABLE Course_2NF ADD PRIMARY KEY (CRN);

    CREATE TABLE Book_2NF AS
    SELECT DISTINCT ISBN, Title, Edition, Publisher, PublisherAddress, Pages, Year
    FROM Course_1NF;

    ALTER TABLE Book_2NF ADD PRIMARY KEY (ISBN);

    CREATE TABLE Author_2NF AS
    SELECT DISTINCT ISBN, Author
    FROM Course_1NF;
