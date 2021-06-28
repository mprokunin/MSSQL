sp_helpdb
select is_master_key_encrypted_by_server, is_encrypted, name from sys.databases --where name in ('')


SELECT '[IrisCoefficientDB]' AS DatabaseName, CASE WHEN ISNULL(Name,'')!='' THEN 1 ELSE 0 END AS AlwaysEncryptedAvailable, (SELECT COUNT(*) FROM [IrisCoefficientDB].sys.columns WHERE encryption_type IS not null) AS NumofEncryptedColumns FROM [IrisCoefficientDB].sys.column_master_keys

SELECT '[IrisFilesDB-performance]' AS DatabaseName, CASE WHEN ISNULL(Name,'')!='' THEN 1 ELSE 0 END AS AlwaysEncryptedAvailable, (SELECT COUNT(*) FROM [IrisFilesDB-performance].sys.columns WHERE encryption_type IS not null) AS NumofEncryptedColumns FROM [IrisFilesDB-performance].sys.column_master_keys

SELECT '[IrisInsuranceDB]' AS DatabaseName, CASE WHEN ISNULL(Name,'')!='' THEN 1 ELSE 0 END AS AlwaysEncryptedAvailable, (SELECT COUNT(*) FROM [IrisInsuranceDB].sys.columns WHERE encryption_type IS not null) AS NumofEncryptedColumns FROM [IrisInsuranceDB].sys.column_master_keys

SELECT '[IrisInsuranceDB-performance]' AS DatabaseName, CASE WHEN ISNULL(Name,'')!='' THEN 1 ELSE 0 END AS AlwaysEncryptedAvailable, (SELECT COUNT(*) FROM [IrisInsuranceDB-performance].sys.columns WHERE encryption_type IS not null) AS NumofEncryptedColumns FROM [IrisInsuranceDB-performance].sys.column_master_keys

SELECT '[IrisSharedIdDB]' AS DatabaseName, CASE WHEN ISNULL(Name,'')!='' THEN 1 ELSE 0 END AS AlwaysEncryptedAvailable, (SELECT COUNT(*) FROM [IrisSharedIdDB].sys.columns WHERE encryption_type IS not null) AS NumofEncryptedColumns FROM [IrisSharedIdDB].sys.column_master_keys

SELECT '[IrisCoefficientDB-performance]' AS DatabaseName, CASE WHEN ISNULL(Name,'')!='' THEN 1 ELSE 0 END AS AlwaysEncryptedAvailable, (SELECT COUNT(*) FROM [IrisCoefficientDB-performance].sys.columns WHERE encryption_type IS not null) AS NumofEncryptedColumns FROM [IrisCoefficientDB-performance].sys.column_master_keys

SELECT '[IrisFilesDB]' AS DatabaseName, CASE WHEN ISNULL(Name,'')!='' THEN 1 ELSE 0 END AS AlwaysEncryptedAvailable, (SELECT COUNT(*) FROM [IrisFilesDB].sys.columns WHERE encryption_type IS not null) AS NumofEncryptedColumns FROM [IrisFilesDB].sys.column_master_keys

SELECT '[IrisBox]' AS DatabaseName, CASE WHEN ISNULL(Name,'')!='' THEN 1 ELSE 0 END AS AlwaysEncryptedAvailable, (SELECT COUNT(*) FROM [IrisBox].sys.columns WHERE encryption_type IS not null) AS NumofEncryptedColumns FROM [IrisBox].sys.column_master_keys

SELECT '[IrisBox-staging]' AS DatabaseName, CASE WHEN ISNULL(Name,'')!='' THEN 1 ELSE 0 END AS AlwaysEncryptedAvailable, (SELECT COUNT(*) FROM [IrisBox-staging].sys.columns WHERE encryption_type IS not null) AS NumofEncryptedColumns FROM [IrisBox-staging].sys.column_master_keys

SELECT '[EOSAGO_LOG]' AS DatabaseName, CASE WHEN ISNULL(Name,'')!='' THEN 1 ELSE 0 END AS AlwaysEncryptedAvailable, (SELECT COUNT(*) FROM [EOSAGO_LOG].sys.columns WHERE encryption_type IS not null) AS NumofEncryptedColumns FROM [EOSAGO_LOG].sys.column_master_keys

SELECT '[IrisMessageQueueDB]' AS DatabaseName, CASE WHEN ISNULL(Name,'')!='' THEN 1 ELSE 0 END AS AlwaysEncryptedAvailable, (SELECT COUNT(*) FROM [IrisMessageQueueDB].sys.columns WHERE encryption_type IS not null) AS NumofEncryptedColumns FROM [IrisMessageQueueDB].sys.column_master_keys

SELECT '[monitoring]' AS DatabaseName, CASE WHEN ISNULL(Name,'')!='' THEN 1 ELSE 0 END AS AlwaysEncryptedAvailable, (SELECT COUNT(*) FROM [monitoring].sys.columns WHERE encryption_type IS not null) AS NumofEncryptedColumns FROM [monitoring].sys.column_master_keys
 

Completion time: 2020-04-10T11:45:29.1014616+03:00


SET NOCOUNT ON;
 
DECLARE @DB_NAME NVARCHAR(50);
DECLARE @SQLString2 AS NVARCHAR(MAX)
 
DECLARE @AlwaysEncryptedDatabases TABLE (database_name VARCHAR(50), AlwaysEncryptedAvailable BIT, NumofEncryptedColumns INT)
DECLARE db_cursor CURSOR FOR
SELECT name AS database_name
FROM sys.databases
WHERE database_id>4 -- exclude master, msdb, model, tempdb
OPEN db_cursor
 
FETCH NEXT FROM db_cursor
INTO  @DB_NAME
 
WHILE @@FETCH_STATUS = 0
BEGIN
 
 SET  @SQLString2 = N'SELECT ''[' + @DB_NAME + ']'' AS DatabaseName'
+ ', CASE WHEN ISNULL(Name,'''')!='''' THEN 1 ELSE 0 END AS AlwaysEncryptedAvailable'
+ ', (SELECT COUNT(*) FROM [' + @DB_NAME + '].sys.columns WHERE encryption_type IS not null) AS NumofEncryptedColumns'
+ ' FROM [' + @DB_NAME + '].sys.column_master_keys' PRINT '@SQLString2: ' + @SQLString2
INSERT INTO @AlwaysEncryptedDatabases EXECUTE SP_EXECUTESQL @SQLString2
PRINT ' '
    FETCH NEXT FROM db_cursor INTO @DB_NAME
END
CLOSE db_cursor;
DEALLOCATE db_cursor;
SELECT *FROM @AlwaysEncryptedDatabases



select @@VERSION
