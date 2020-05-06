--Get the list of outdated statistics
INSERT INTO Outdated_statistics
SELECT OBJECT_NAME(id),name,STATS_DATE(id, indid),rowmodctr
FROM sys.sysindexes
WHERE STATS_DATE(id, indid)<=DATEADD(DAY,-1,GETDATE()) 
AND rowmodctr>0 
AND id IN (SELECT object_id FROM sys.tables)
GO


-------------------
--Set the thresholds when to consider the statistics outdated
DECLARE @hours int
DECLARE @modified_rows int
DECLARE @update_statement nvarchar(300);

SET @hours=24
SET @modified_rows=1000

--Update all the outdated statistics
DECLARE statistics_cursor CURSOR FOR
SELECT 'UPDATE STATISTICS '+OBJECT_NAME(id)+' '+name
FROM sys.sysindexes
WHERE STATS_DATE(id, indid)<=DATEADD(HOUR,-@hours,GETDATE()) 
AND rowmodctr>=@modified_rows 
AND id IN (SELECT object_id FROM sys.tables)
 
OPEN statistics_cursor;
FETCH NEXT FROM statistics_cursor INTO @update_statement;
 
 WHILE (@@FETCH_STATUS <> -1)
 BEGIN
--  EXECUTE (@update_statement);
  PRINT @update_statement;
 
 FETCH NEXT FROM statistics_cursor INTO @update_statement;
 END;
 
 PRINT 'The outdated statistics have been updated.';
CLOSE statistics_cursor;
DEALLOCATE statistics_cursor;
GO
