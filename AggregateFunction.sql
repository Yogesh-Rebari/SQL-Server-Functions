-- Aggregate Functions

-- 01. AVG()
-- Returns the average (mean) value
-- Syntax : SELECT AVG(column_name) FROM table_name;
SELECT AVG(Fees) AS AverageFees
FROM StudentBasic;


-- 02. COUNT()
-- Counts number of rows (ignores NULLs)
-- Syntax : SELECT COUNT(column_name) FROM table_name;
SELECT COUNT(StudentId) AS TotalStudents
FROM StudentBasic;


-- 03. COUNT(*)
-- Counts all rows, including NULL values
-- Syntax : SELECT COUNT(*) FROM table_name;
SELECT COUNT(*) AS TotalRecords
FROM StudentBasic;


-- 04. COUNT_BIG()
-- Same as COUNT() but returns BIGINT(Used when records are extremely large)
-- Syntax : SELECT COUNT_BIG(column_name) FROM table_name;
SELECT COUNT_BIG(StudentId) AS TotalStudents
FROM StudentBasic;


-- 05. SUM()
-- Returns the total sum of a numeric column
-- Syntax : SELECT SUM(column_name) FROM table_name;
SELECT SUM(Fees) AS TotalFeesCollected
FROM StudentBasic;


-- 06. MIN()
-- Finds the minimum value
-- Syntax : SELECT MIN(column_name) FROM table_name;
SELECT MIN(Age) AS MinimumAge
FROM StudentBasic;


-- 07. MAX()
-- Finds the maximum value
-- Syntax : SELECT MAX(column_name) FROM table_name;
SELECT MAX(Fees) AS HighestFees
FROM StudentBasic;


-- 08. STDEV()
-- Calculates standard deviation (sample)
-- Syntax : SELECT STDEV(column_name) FROM table_name;
SELECT STDEV(Fees) AS FeesDeviation
FROM StudentBasic;


-- 09. STDEVP()
-- Standard deviation of entire population
-- Syntax : SELECT STDEVP(column_name) FROM table_name;
SELECT STDEVP(Age) AS AgeDeviation
FROM StudentBasic;


-- 10. VAR()
-- Variance of a sample
-- Syntax : SELECT VAR(column_name) FROM table_name;
SELECT VAR(Fees) AS FeesVariance
FROM StudentBasic;


-- 11. VARP()
-- Variance of entire population
-- Syntax : SELECT VARP(Age) FROM table_name;
SELECT VARP(Age) AS AgeVariance
FROM StudentBasic;


-- 12. GROUPING()
-- Used with GROUP BY + ROLLUP / CUBE Tells whether a column is aggregated or not
SELECT Course, COUNT(StudentId) AS StudentCount,
       GROUPING(Course) AS IsGrouped
FROM StudentBasic
GROUP BY ROLLUP(Course);


-- 13. GROUPING_ID()
-- Identifies which columns are aggregated
SELECT Course, isActive, COUNT(*),
       GROUPING_ID(Course, isActive) AS GroupID
FROM StudentBasic
GROUP BY ROLLUP(Course, isActive);


-- 14. CHECKSUM()
-- Generates a hash value (used in comparison)
SELECT CHECKSUM(StudentName, Email)
FROM StudentBasic;


-- 15. CHECKSUM_AGG()
-- Aggregate version of CHECKSUM()
SELECT CHECKSUM_AGG(CHECKSUM(StudentId, Fees))
FROM StudentBasic;

-- 16. BINARY_CHECKSUM()
-- Faster but less accurate checksum
SELECT BINARY_CHECKSUM(StudentId, StudentName)
FROM StudentBasic;


