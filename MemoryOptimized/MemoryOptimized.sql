SELECT SCHEMA_NAME(Schema_id) SchemaName,
name TableName,
is_memory_optimized,
durability_desc,
create_date, modify_date
FROM sys.tables
where is_memory_optimized > 0
GO

SELECT Name, durability_desc, durability
FROM sys.tables 
WHERE is_memory_optimized = 1

select top 100 * from sys.dm_db_xtp_checkpoint_files


CREATE TYPE [dbo].[ListIds] AS TABLE(
	[ID] [int] NOT NULL,
	INDEX [ix_tmp_list_ids] NONCLUSTERED HASH 
(
	[ID]
)WITH ( BUCKET_COUNT = 128)
)
WITH ( MEMORY_OPTIMIZED = ON )
GO

select @@VERSION