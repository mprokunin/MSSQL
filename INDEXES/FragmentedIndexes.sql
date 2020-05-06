use D_AST4
GO
declare @DBID int = db_id('T_REQ1')

SELECT   @DBID as DB, object_id AS objectid,    index_id AS indexid,
   index_type_desc,
   partition_number AS partitionnum,   convert(decimal(10,2),avg_fragmentation_in_percent) AS frag, --  процент фрагментации
   convert(decimal(10,2),((page_count*8192.)/1024)/1024) as [Size(kb)], page_count --   размер индекса в кб
  INTO #work_table
  FROM  sys.dm_db_index_physical_stats (@DBID, 0, NULL , NULL, 'LIMITED')
  --WHERE avg_fragmentation_in_percent > 10.0 AND index_id > 0;

  --select * from #work_table order by page_count desc,frag desc
  SELECT
   objectid, object_schema_name([objectid])+'.'+OBJECT_NAME(objectid) as tblname, (select Name from sys.indexes 
   where sys.indexes.index_id=#work_table.indexid and
   sys.indexes.object_id=#work_table.objectid) as indname,
   indexid,index_type_desc,
   --partitionnum, 
   frag,[Size(kb)],page_count FROM #work_table 
where object_name(objectid) in ( '_AccumRg11629'
,'_AccumRgTn11642'
,'_AccumRg10304'
,'_AccumRgTn10322'
,'_Document11608'
)
  order by page_count desc,frag desc,tblname
   --,tblname
  go 
  drop table #work_table 
  go



  select db_id('P_AST')
  --------------------
use P_AST
go
SELECT   object_id AS objectid,    index_id AS indexid,
   index_type_desc,
   partition_number AS partitionnum,   convert(decimal(10,2),avg_fragmentation_in_percent) AS frag, --  процент фрагментации
   convert(decimal(10,2),((page_count*8192.)/1024)/1024) as [Size(kb)], page_count --   размер индекса в кб
  INTO #work_table
  FROM  sys.dm_db_index_physical_stats (DB_ID(),0, NULL , NULL, 'LIMITED')
  --WHERE avg_fragmentation_in_percent > 10.0 AND index_id > 0;
  insert into ##Fragmentation (tblname, indname, indexid, index_type_desc, frag, [Size(kb)],page_count) SELECT 
   object_schema_name([objectid])+'.'+OBJECT_NAME(objectid) as tblname, (select Name from sys.indexes 
   where sys.indexes.index_id=#work_table.indexid and
   sys.indexes.object_id=#work_table.objectid) as indname,
   indexid,index_type_desc,
   --partitionnum, 
   frag,[Size(kb)],page_count 
   FROM #work_table 
  order by page_count desc,frag desc,tblname
   --,tblname
  go 

drop table #work_table
go

select * from ##Fragmentation
go
----------------


--drop table ##Fragmentation 
create table ##Fragmentation (
dt datetime default getdate(),
tblname nvarchar(514),
indname nvarchar(256),
indexid int,
index_type_desc nvarchar(120),
frag decimal(10,2),
[Size(kb)] decimal(10,2),
page_count bigint
)

  sp_spaceused 'dbo._InfoRg8251'
sp_helpindex 'dbo._infoRg8251'
alter index _InfoRe8251_ByDims_RRRRT on dbo._infoRg8251 rebuild;
go
alter index _InfoRe8251_ByDims8265_RTRRR on dbo._infoRg8251 rebuild;
go
alter index _InfoRe8251_ByPeriod_TRRRR on dbo._infoRg8251 rebuild;
go

sp_helpindex dbo._Reference85
DBCC FREESYSTEMCACHE ('SQL Plans')

 
