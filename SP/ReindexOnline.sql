USE [AtonBase]
GO

/****** Object:  StoredProcedure [dbo].[ReindexOnline]    Script Date: 12.02.2019 16:43:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ReindexOnline]   
AS   
    SET NOCOUNT ON;  
	DECLARE @SessionId int = RAND() * 1E9
    DECLARE @MachineName nvarchar(50) = @@SERVERNAME;
    DECLARE @SchemaName sysname, @TableName sysname,  @IndexName sysname, @IndexType NVARCHAR(255)
	DECLARE @TableId int, @IndexId INT
	DECLARE @Fragmentation FLOAT
	DECLARE @StrToLogs NVARCHAR(255)
	DECLARE @Rebuild NVARCHAR(255), @Reorganize NVARCHAR(255)
	DECLARE TestCursor CURSOR FOR 
		   SELECT 
		   --DB_NAME() AS Database_Name
		   sc.name AS Schema_Name
		   ,o.name AS Table_Name
		   ,i.name AS Index_Name
		   ,i.type_desc AS Index_Type
		   ,i.object_id as TableId
		   ,i.index_id as IndexId
		   FROM sys.indexes i
		   INNER JOIN sys.objects o ON i.object_id = o.object_id
		   INNER JOIN sys.schemas sc ON o.schema_id = sc.schema_id
		   WHERE i.name IS NOT NULL
		   AND o.type = 'U'
		   ORDER BY o.name, i.type

	OPEN TestCursor
	FETCH NEXT FROM TestCursor INTO @SchemaName, @TableName, @IndexName, @IndexType, @TableId, @IndexId

	WHILE @@FETCH_STATUS = 0
	BEGIN
			DECLARE @Now datetime = GETDATE()

			SELECT 
				@Fragmentation = indexstats.avg_fragmentation_in_percent
			FROM 
				sys.dm_db_index_physical_stats (DB_ID(), @TableId, @IndexId, default, default) AS indexstats
			SET @StrToLogs = '['+@SchemaName+'].['+@TableName+'].['+@IndexName+'] before: '+STR(@Fragmentation)
			
			SET @Rebuild = 'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + '] REBUILD WITH (ONLINE = ON)';
			SET @Reorganize = 'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + '] REORGANIZE';

			IF (@IndexType = 'NONCLUSTERED')
			BEGIN
				IF (@Fragmentation > 20)
				BEGIN
					exec(@Rebuild);
				END
				IF (@Fragmentation <= 20 AND @Fragmentation > 10)
				BEGIN
					exec(@Reorganize);
				END
			END
			ELSE
			BEGIN
				IF (@Fragmentation > 10)
				BEGIN
					exec(@Rebuild);
				END
			END
			SELECT 
				@Fragmentation = indexstats.avg_fragmentation_in_percent
			FROM 
				sys.dm_db_index_physical_stats (DB_ID(), @TableId, @IndexId, default, default) AS indexstats
			SET @StrToLogs = '['+@SchemaName+'].['+@TableName+'].['+@IndexName+'] after: '+STR(@Fragmentation)
			FETCH NEXT FROM TestCursor INTO @SchemaName, @TableName, @IndexName, @IndexType, @TableId, @IndexId
	END

	CLOSE TestCursor
	DEALLOCATE TestCursor

GO


