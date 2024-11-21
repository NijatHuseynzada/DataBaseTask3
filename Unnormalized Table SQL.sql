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

   -- 3NF tables
    CREATE TABLE Publisher_3NF AS
    SELECT DISTINCT Publisher, PublisherAddress
    FROM Book_2NF;

    ALTER TABLE Publisher_3NF ADD PRIMARY KEY (Publisher);

    CREATE TABLE Book_3NF AS
    SELECT 
        ISBN, 
        Title, 
        Edition, 
        Publisher, 
        Pages, 
        Year
    FROM Book_2NF;

    ALTER TABLE Book_3NF ADD PRIMARY KEY (ISBN);

    CREATE TABLE PublisherAddress_3NF AS
    SELECT DISTINCT PublisherAddress 
    FROM Course_1NF;

    ALTER TABLE PublisherAddress_3NF ADD PRIMARY KEY (PublisherAddress);

    CREATE TABLE BookAuthor_3NF AS
    SELECT DISTINCT ISBN, Author
    FROM Author_2NF;

    ALTER TABLE BookAuthor_3NF ADD PRIMARY KEY (ISBN, Author);

    -- foreign keys
    ALTER TABLE Book_3NF ADD CONSTRAINT fk_publisher FOREIGN KEY (Publisher) REFERENCES Publisher_3NF (Publisher);
    ALTER TABLE BookAuthor_3NF ADD CONSTRAINT fk_book FOREIGN KEY (ISBN) REFERENCES Book_3NF (ISBN);
END;
$$;

-- Execute the procedure
CALL NormalizeBooks();

-- Check UnnormalizedBooks table
-- SELECT * FROM UnnormalizedBooks;

-- Check 1NF table
-- SELECT * FROM Course_1NF;

-- Check 2NF tables
-- SELECT * FROM Course_2NF;
-- SELECT * FROM Book_2NF;
-- SELECT * FROM Author_2NF;

-- Check 3NF tables
-- SELECT * FROM Book_3NF;
-- SELECT * FROM Publisher_3NF;
-- SELECT * FROM BookAuthor_3NF;

