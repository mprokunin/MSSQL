-- Count Transactions 
DECLARE @First BIGINT
 DECLARE @Second BIGINT
 SELECT @First = cntr_value
FROM sys.dm_os_performance_counters
WHERE OBJECT_NAME = 'SQLSERVER:Databases' -- Change name of your server
AND counter_name = 'Transactions/sec'
AND instance_name = '_Total';
-- Following is the delay
WAITFOR DELAY '00:01:00'
-- Second PASS
SELECT @Second = cntr_value
FROM sys.dm_os_performance_counters
WHERE OBJECT_NAME = 'SQLSERVER:Databases' -- Change name of your server
AND counter_name = 'Transactions/sec'
AND instance_name = '_Total';
SELECT (@Second - @First) 'TotalTransactions' 
GO
select @@SERVERNAME


