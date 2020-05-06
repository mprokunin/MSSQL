-- Fix Index sizes
insert into master.dbo.index_sizes (
data_compression, obj, ind, schemaid, 
tablename, indexname, indextype, rowcounts, totalpages, usedpages, datapages
)
SELECT 
    p.data_compression, t.object_id, i.index_id, t.schema_id,
	t.NAME,
    i.name,
    case 
      when i.index_id = 0 then 'Heap'
      when i.index_id = 1 then 'Clustered Index/b-tree'
      when i.index_id > 1 then 'Non-clustered Index/b-tree'
    end,

    sum(p.rows) ,
    sum(a.total_pages), 
    sum(a.used_pages), 
    sum(a.data_pages)
FROM 
    P_AST.sys.tables t
INNER JOIN      
    P_AST.sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    P_AST.sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    P_AST.sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
    t.NAME NOT LIKE 'dt%' AND
    i.OBJECT_ID > 255 
--	AND       i.index_id <= 1
GROUP BY 
    p.data_compression, t.schema_id, t.NAME, t.object_id, i.index_id, i.name
