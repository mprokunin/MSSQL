-- Count Transactions 
DECLARE @First BIGINT
 DECLARE @Second BIGINT
SELECT @First = cntr_value
FROM sys.dm_os_performance_counters
WHERE OBJECT_NAME = 'MSSQL$BUH:Databases' -- Change name of your server
AND counter_name = 'Transactions/sec'
AND instance_name = '_Total';
-- Following is the delay
WAITFOR DELAY '00:00:10'
-- Second PASS
SELECT @Second = cntr_value
FROM sys.dm_os_performance_counters
WHERE OBJECT_NAME = 'MSSQL$BUH:Databases' -- Change name of your server
AND counter_name = 'Transactions/sec'
AND instance_name = '_Total';
SELECT (@Second - @First)/10 'TotalTransactions/sec' 
GO

select @@SERVERNAME


SELECT cntr_value, *
FROM sys.dm_os_performance_counters
WHERE OBJECT_NAME = 'MSSQL$BUH:Databases' -- Change name of your server
AND counter_name = 'Transactions/sec'
AND instance_name = '_Total';

sp_helpdb
