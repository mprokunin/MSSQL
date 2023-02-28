--Script to automate statistics maintenance
--Script 1 of 3:
--Update column statistics only.
--Statistics related to indexes are updated in steps 2 and 3.
-- Ensure a USE <databasename> statement has been executed first.
SET NOCOUNT ON;
DECLARE @objectid int;
DECLARE @schemaname nvarchar(130);
DECLARE @objectname nvarchar(130);
DECLARE @statsname nvarchar(130);
DECLARE @command nvarchar(4000);
-- Populate a temp table with a list of all column statistics in the database (user tables only).
SELECT [object_id], name
INTO #stats_work_to_do
FROM sys.stats
WHERE OBJECTPROPERTY([object_id], 'IsUserTable') = 1
-- Declare the cursor for the list of stats to be processed.
DECLARE stats_cursor CURSOR FOR SELECT * FROM #stats_work_to_do;
-- Open the cursor.
OPEN stats_cursor;
-- Loop through the stats_cursor updating all column stats with a full scan.
WHILE (1=1)
BEGIN;
FETCH NEXT
FROM stats_cursor
INTO @objectid, @statsname;
IF @@FETCH_STATUS < 0 BREAK;
SELECT @objectname = QUOTENAME(o.name), @schemaname = QUOTENAME(s.name)
FROM sys.objects AS o
JOIN sys.schemas as s ON s.schema_id = o.schema_id
WHERE o.object_id = @objectid;
SET @command = N'UPDATE STATISTICS ' + @schemaname + N'.' + @objectname + N' ' + @statsname + N' WITH FULLSCAN';
EXEC (@command);
PRINT N'Executed: ' + @command;
END;
-- Close and deallocate the cursor.
CLOSE stats_cursor;
DEALLOCATE stats_cursor;
-- Drop the temporary table.
DROP TABLE #stats_work_to_do;
GO