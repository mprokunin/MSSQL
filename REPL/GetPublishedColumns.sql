use ABCBase;

--Which columns in the database are published?  (Run at Publisher)
SELECT schema_name(tab.schema_id) as 'schema', tab.name AS published_object, col.name as 'ColName', col.is_replicated
FROM sys.tables tab with (nolock) join sys.columns col with (nolock)
on col.object_id = tab.object_id
WHERE tab.is_published = 1 
and tab.name = 'Asset'
order by schema_name(tab.schema_id), tab.name, col.name

--select FStamp, IsObserved, RecStamp from OperPlace

EXEC Test_1112..sp_helparticlecolumns @publication='Test_1112_Pub', @article = 'Counterparty';  


-- Get Timestamp cols from publicated tables
select tab.is_published, tab.name, col.COLUMN_NAME, col.DATA_TYPE 
from sys.tables tab
left outer join INFORMATION_SCHEMA.COLUMNS col
on col.TABLE_NAME = tab.name and col.DATA_TYPE = 'timestamp' 
	where tab.is_published = 1 
	order by tab.name, col.COLUMN_NAME



use ABCBase;
--Which objects in the database are published?  (Run at Publisher)
SELECT name AS published_object, schema_id, is_published AS is_tran_published, is_merge_published, is_schema_published  
FROM sys.tables WHERE is_published = 1 or is_merge_published = 1 or is_schema_published = 1  
UNION  
SELECT name AS published_object, schema_id, 0, 0, is_schema_published  
FROM sys.procedures WHERE is_schema_published = 1  
UNION  
SELECT name AS published_object, schema_id, 0, 0, is_schema_published  
FROM sys.views WHERE is_schema_published = 1; 


USE ABCBase
go
--Get detailed info for published articles (Run at Publisher)
DECLARE @publication AS sysname;
SET @publication = N'ABCBase_Pub';

EXEC sp_helparticle
  @publication = @publication, @article = 'Asset'
GO
