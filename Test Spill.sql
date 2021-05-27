USE Northwind
GO
-- Creating test table
-- 1 row per page... so 1k pages
DROP TABLE IF EXISTS TestSpill 
CREATE TABLE TestSpill (Col1 INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED, Col2 CHAR(7000)) 
GO
INSERT INTO TestSpill (Col2)
SELECT TOP 1000
       NEWID()
  FROM sysobjects a, sysobjects b, sysobjects c, sysobjects d
GO

DROP TABLE IF EXISTS tmp1
SELECT
    num_of_bytes_written = num_of_bytes_written, 
    num_of_writes = num_of_writes
INTO tmp1
FROM sys.dm_io_virtual_file_stats(2, 1) AS FS
GO
DECLARE @t1 TABLE (ID Int) 
INSERT INTO @t1
SELECT TOP (3) 
       ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) * -1 AS ID
  FROM sysobjects a, sysobjects b, sysobjects c, sysobjects d

-- Query that will do the spill
SELECT [@t1].ID,
       (SELECT COUNT_BIG(DISTINCT Col2) AS dCol1
                FROM TestSpill
               WHERE TestSpill.Col1 >= [@t1].ID) AS CountTestSpill
  FROM @t1
GO

-- Capturing sys.dm_io_virtual_file_stats snapshot
DROP TABLE IF EXISTS tmp1
SELECT
    num_of_bytes_written = num_of_bytes_written, 
    num_of_writes = num_of_writes
INTO tmp1
FROM sys.dm_io_virtual_file_stats(2, 1) AS FS
GO
