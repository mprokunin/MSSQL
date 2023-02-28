--Script to automate index/statistics maintenance.
--Script 2 of 3:
--Update statistics on indexes with less than 30% fragmentation.
--Statistics with greater than 30% fragmentation with be rebuilt in step 3 making a stats update unnecessary.
-- Ensure a USE <databasename> statement has been executed first.
SET NOCOUNT ON;
DECLARE @objectid int;
DECLARE @indexid int;
DECLARE @schemaname nvarchar(130);
DECLARE @objectname nvarchar(130);
DECLARE @indexname nvarchar(130);
DECLARE @frag float;
DECLARE @command nvarchar(4000);
-- Populate a temp table with a list of indexes that are more than 30% fragmented based on the sys.dm_db_index_physical_stats function.
SELECT
object_id AS objectid,
index_id AS indexid
INTO #stats_work_to_do
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, 'LIMITED')
WHERE avg_fragmentation_in_percent < 30.0 AND index_id > 0;
-- Declare the cursor for the list of indexes to be processed.
DECLARE index_cursor CURSOR FOR SELECT * FROM #stats_work_to_do;
-- Open the cursor.
OPEN index_cursor;
-- Loop through the index_cursor updating stats for indexes with less than 30% fragmentation.
WHILE (1=1)
BEGIN;
FETCH NEXT
FROM index_cursor
INTO @objectid, @indexid;
IF @@FETCH_STATUS < 0 BREAK;
SELECT @objectname = QUOTENAME(o.name), @schemaname = QUOTENAME(s.name)
FROM sys.objects AS o
JOIN sys.schemas as s ON s.schema_id = o.schema_id
WHERE o.object_id = @objectid;
SELECT @indexname = QUOTENAME(name)
FROM sys.indexes
WHERE object_id = @objectid AND index_id = @indexid;
SET @command = N'UPDATE STATISTICS ' + @schemaname + N'.' + @objectname + N' ' + @indexname + N' WITH FULLSCAN';
EXEC (@command);
PRINT N'Executed: ' + @command;
END;
-- Close and deallocate the cursor.
CLOSE index_cursor;
DEALLOCATE index_cursor;
-- Drop the temporary table.
--select * from #stats_work_to_do
DROP TABLE #stats_work_to_do;
GO