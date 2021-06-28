EXEC msdb..sp__dbinfo 3

select @@VERSION
--sp_helpdb
------------------- Largest tables
use msdb
go
SELECT 
	SCHEMA_NAME(t.schema_id) as 'Schema', 
    t.NAME AS TableName,
    i.name as indexName,
    case 
      when i.index_id = 0 then 'Heap'
      when i.index_id = 1 then 'Clustered Index/b-tree'
      when i.index_id > 1 then 'Non-clustered Index/b-tree'
    end as 'Type',

    sum(p.rows) as RowCounts,
    sum(a.total_pages) as TotalPages, 
    sum(a.used_pages) as UsedPages, 
    sum(a.data_pages) as DataPages,
    (sum(a.total_pages) * 8) / 1024 as TotalSpaceMB, 
    (sum(a.used_pages) * 8) / 1024 as UsedSpaceMB, 
    (sum(a.data_pages) * 8) / 1024 as DataSpaceMB
FROM 
    sys.tables t with (nolock)
INNER JOIN      
    sys.indexes i with (nolock) ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p with (nolock) ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a with (nolock) ON p.partition_id = a.container_id
WHERE 
    i.OBJECT_ID > 255
    AND i.index_id <= 1
--	t.NAME NOT LIKE 'dt%'
--	AND SCHEMA_NAME(t.schema_id) <> 'core'

--and (t.NAME like 'FCT%' or t.NAME like 'FHT%' or t.NAME like 'DCT%' or t.NAME like 'DHT%')

GROUP BY 
    t.schema_id, t.NAME, i.object_id, i.index_id, i.name 
ORDER BY 
--    object_name(i.object_id) 
--t.name
TotalPages desc
--sum(p.rows) desc

declare @BEFORE datetime = dateadd(dd, -30,getdate())
exec msdb..sysmail_delete_mailitems_sp  @sent_before = @BEFORE 

--Schema	TableName			indexName							Type		RowCounts		TotalPages	UsedPages	DataPages	TotalSpaceMB	UsedSpaceMB	DataSpaceMB
--dbo		sysmail_attachments	NULL								Heap		133425			374293		374114		824	2924	2922	6
--dbo		sysmail_mailitems	sysmail_mailitems_id_MustBeUnique	Clustered	Index/b-tree	147621		120334		120275	7143	940	939	55