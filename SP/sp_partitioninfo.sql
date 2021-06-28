
-- Create service view and sp
CREATE VIEW [dbo].[PartitionRanges] AS
select pf.name as [partition_function],
       ps.name as [partition_scheme],
       1 as [partition_number],
       case when prv.value is null then NULL else '<' end as [relation],
       prv.value as [boundary_value],
       type_name(pp.system_type_id) as [type],
       fg.name as [filegroup],
       case when ps.name is null then NULL else N'IN USE' end as [status]
  from sys.partition_functions pf
  join sys.partition_parameters pp on pp.function_id = pf.function_id
  left join sys.partition_schemes ps on ps.function_id = pf.function_id
  left join sys.destination_data_spaces dds
    on dds.partition_scheme_id = ps.data_space_id and dds.destination_id = 1 
  left join sys.filegroups fg on fg.data_space_id = dds.data_space_id
  left join sys.partition_range_values prv
    on prv.function_id = pf.function_id and prv.parameter_id = 1 and
       prv.boundary_id = 1
 where pf.boundary_value_on_right = 1
 union all
select pf.name as [partition_function],
       ps.name as [partition_scheme],
       prv.boundary_id + cast(pf.boundary_value_on_right as int) as [partition_number],
       case when pf.boundary_value_on_right = 0 then '<=' else '>=' end as [relation],
       prv.value as [boundary_value],
       type_name(pp.system_type_id) as [type],
       fg.name as [filegroup],
       case when ps.name is null then NULL else N'IN USE' end as [status]
  from sys.partition_functions pf
  join sys.partition_range_values prv on
       prv.function_id = pf.function_id and prv.parameter_id = 1
  join sys.partition_parameters pp on pp.function_id = pf.function_id
  left join sys.partition_schemes ps on ps.function_id = pf.function_id
  left join sys.destination_data_spaces dds
    on dds.partition_scheme_id = ps.data_space_id and
       dds.destination_id = prv.boundary_id + cast(pf.boundary_value_on_right as int)
  left join sys.filegroups fg on fg.data_space_id = dds.data_space_id
 union all
select pf.name as [partition_function],
       ps.name as [partition_scheme],
       pf.fanout as [partition_number],
       case when prv.value is null then NULL else '>' end as [relation],
       prv.value as [boundary_value],
       type_name(pp.system_type_id) as [type],
       fg.name as [filegroup],
       case when ps.name is null then NULL else N'IN USE' end as [status]
  from sys.partition_functions pf
  join sys.partition_parameters pp on pp.function_id = pf.function_id
  left join sys.partition_schemes ps on ps.function_id = pf.function_id
  left join sys.destination_data_spaces dds
    on dds.partition_scheme_id = ps.data_space_id and dds.destination_id = pf.fanout 
  left join sys.filegroups fg on fg.data_space_id = dds.data_space_id
  left join sys.partition_range_values prv
    on prv.function_id = pf.function_id and prv.parameter_id = 1 and
       prv.boundary_id = pf.fanout - 1
 where pf.boundary_value_on_right = 0
 union all
select pf.name as [partition_function],
       ps.name as [partition_scheme],
       NULL, NULL, NULL, NULL,
       fg.name as [filegroup],
       case when dds.destination_id = pf.fanout + 1
            then N'NEXT USED' else N'NOT USED'
       end as [status]
  from sys.partition_functions pf
  join sys.partition_schemes ps on ps.function_id = pf.function_id
  join sys.destination_data_spaces dds
    on dds.partition_scheme_id = ps.data_space_id and
       dds.destination_id > pf.fanout
  join sys.filegroups fg on fg.data_space_id = dds.data_space_id 
go



------------- Procedure to get Partition Details
USE [REN_LOG]
GO

/****** Object:  StoredProcedure [dbo].[sp_partitioninfo]    Script Date: 5/22/2020 11:11:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


------------- Procedure to get Partition Details
CREATE procedure [dbo].[sp_partitioninfo] 
 @SchemaName sysname = 'dbo'
 , @TableName sysname = NULL
as
begin
SELECT
OBJECT_SCHEMA_NAME(pstats.object_id) AS SchemaName
,OBJECT_NAME(pstats.object_id) AS TableName
,ps.name AS PartitionSchemeName
,ds.name AS PartitionFilegroupName
,pf.name AS PartitionFunctionName
,CASE pf.boundary_value_on_right WHEN 0 THEN 'Range Left' ELSE 'Range Right' END AS PartitionFunctionRange
,CASE pf.boundary_value_on_right WHEN 0 THEN 'Upper Boundary' ELSE 'Lower Boundary' END AS PartitionBoundary
,prv.value AS PartitionBoundaryValue
,c.name AS PartitionKey
,CASE 
WHEN pf.boundary_value_on_right = 0 
THEN c.name + ' > ' + CAST(ISNULL(LAG(prv.value) OVER(PARTITION BY pstats.object_id ORDER BY pstats.object_id, pstats.partition_number), 'Infinity') AS VARCHAR(100)) + ' and ' + c.name + ' <= ' + CAST(ISNULL(prv.value, 'Infinity') AS VARCHAR(100)) 
ELSE c.name + ' >= ' + CAST(ISNULL(prv.value, 'Infinity') AS VARCHAR(100)) + ' and ' + c.name + ' < ' + CAST(ISNULL(LEAD(prv.value) OVER(PARTITION BY pstats.object_id ORDER BY pstats.object_id, pstats.partition_number), 'Infinity') AS VARCHAR(100))
END AS PartitionRange
,pstats.partition_number AS PartitionNumber
,pstats.row_count AS PartitionRowCount
,p.data_compression_desc AS DataCompression
FROM sys.dm_db_partition_stats AS pstats
INNER JOIN sys.partitions AS p ON pstats.partition_id = p.partition_id
INNER JOIN sys.destination_data_spaces AS dds ON pstats.partition_number = dds.destination_id
INNER JOIN sys.data_spaces AS ds ON dds.data_space_id = ds.data_space_id
INNER JOIN sys.partition_schemes AS ps ON dds.partition_scheme_id = ps.data_space_id
INNER JOIN sys.partition_functions AS pf ON ps.function_id = pf.function_id
INNER JOIN sys.indexes AS i ON pstats.object_id = i.object_id AND pstats.index_id = i.index_id AND dds.partition_scheme_id = i.data_space_id AND i.type <= 1 /* Heap or Clustered Index */
INNER JOIN sys.index_columns AS ic ON i.index_id = ic.index_id AND i.object_id = ic.object_id AND ic.partition_ordinal > 0
INNER JOIN sys.columns AS c ON pstats.object_id = c.object_id AND ic.column_id = c.column_id
LEFT JOIN sys.partition_range_values AS prv ON pf.function_id = prv.function_id AND pstats.partition_number = (CASE pf.boundary_value_on_right WHEN 0 THEN prv.boundary_id ELSE (prv.boundary_id+1) END)
where OBJECT_SCHEMA_NAME(pstats.object_id) = @SchemaName and OBJECT_NAME(pstats.object_id) like coalesce (@TableName, '%')
ORDER BY SchemaName, TableName, PartitionNumber;
end
GO
