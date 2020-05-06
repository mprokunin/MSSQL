-- List Tables and Indexes on filegroups with partitions

-- by size
SELECT OBJECT_SCHEMA_NAME(t.object_id) AS schema_name
,t.name AS table_name
,i.index_id
,i.name AS index_name
,p.partition_number
,fg.name AS filegroup_name
,SUM(u.total_pages) * 8 / 1024 as SizeMB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id=p.object_id AND i.index_id=p.index_id
LEFT OUTER JOIN sys.partition_schemes ps ON i.data_space_id=ps.data_space_id
LEFT OUTER JOIN sys.destination_data_spaces dds ON ps.data_space_id=dds.partition_scheme_id AND p.partition_number=dds.destination_id
INNER JOIN sys.filegroups fg ON COALESCE(dds.data_space_id, i.data_space_id)=fg.data_space_id
INNER JOIN sys.allocation_units as u on p.partition_id = u.container_id 
group by OBJECT_SCHEMA_NAME(t.object_id), t.name, i.index_id, i.name, p.partition_number, fg.name
order by SUM(u.total_pages) desc


-- by name
SELECT OBJECT_SCHEMA_NAME(t.object_id) AS schema_name
,t.name AS table_name
,i.index_id
,i.name AS index_name
,p.partition_number
,fg.name AS filegroup_name
,FORMAT(p.rows, '#,###') AS rows
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id=p.object_id AND i.index_id=p.index_id
LEFT OUTER JOIN sys.partition_schemes ps ON i.data_space_id=ps.data_space_id
LEFT OUTER JOIN sys.destination_data_spaces dds ON ps.data_space_id=dds.partition_scheme_id AND p.partition_number=dds.destination_id
INNER JOIN sys.filegroups fg ON COALESCE(dds.data_space_id, i.data_space_id)=fg.data_space_id
order by OBJECT_SCHEMA_NAME(t.object_id), t.name, i.name, p.partition_number
