use master
go
-- drop table index_frag 
create table index_frag (
dt datetime default getdate(),
db int,
objectid int, 
indexid int null, 
index_type_desc nvarchar(120), 
partitionnum int null, 
frag decimal(10,2) null, 
page_count bigint null
)
create clustered index index_frag on index_frag (dt, db, objectid, indexid) 
go
grant all on index_frag to svu_job
go



USE [master]
GO
/****** Object:  StoredProcedure [dbo].[IndexOptimize_P_REQ]    Script Date: 29.05.2019 23:36:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[IndexOptimize_P_REQ] 
@Execute nvarchar(max) = 'Y', 
@UpdateStatistics nvarchar(max) = 'ALL', 
@FragmentationLow nvarchar(max) = NULL,
@FragmentationMedium nvarchar(max) = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh nvarchar(max) = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'
as
begin

declare @DBID int = db_id('P_REQ')
/*
insert into master.dbo.index_frag (DB, objectid, indexid, index_type_desc, partitionnum, frag, page_count)
SELECT   @DBID as DB, object_id AS objectid, index_id AS indexid, index_type_desc, partition_number AS partitionnum,  convert(decimal(10,2),avg_fragmentation_in_percent) AS frag, page_count 
   FROM sys.dm_db_index_physical_stats (@DBID, 0, NULL , NULL, 'LIMITED')
*/
EXECUTE master.dbo.IndexOptimize
@Databases = 'P_REQ',
@FragmentationLow = @FragmentationLow,
@FragmentationMedium = @FragmentationMedium,
@FragmentationHigh = @FragmentationHigh,
@UpdateStatistics = @UpdateStatistics,
@Indexes = 'P_REQ.dbo._AccumRg11629
,P_REQ.dbo._AccumRgTn11642
,P_REQ.dbo._AccumRg10304
,P_REQ.dbo._AccumRgTn10322
,P_REQ.dbo._Document11608',
@OnlyModifiedStatistics = 'Y',
@LogToTable = 'Y',
@Execute = @Execute
/*
insert into master.dbo.index_frag (DB, objectid, indexid, index_type_desc, partitionnum, frag, page_count)
SELECT   @DBID as DB, object_id AS objectid, index_id AS indexid, index_type_desc, partition_number AS partitionnum,  convert(decimal(10,2),avg_fragmentation_in_percent) AS frag, page_count 
   FROM sys.dm_db_index_physical_stats (@DBID, 0, NULL , NULL, 'LIMITED')
delete from master.dbo.index_frag where dt < DATEADD(dd, -90, getdate()) 
*/
end
go
grant exec on [IndexOptimize_P_REQ] to svu_job
go

grant exec on CommandExecute to svu_job
go
grant select,insert,update, delete   on CommandLog to svu_job
go
/*

exec [IndexOptimize_P_REQ] @Execute = 'N'
select top 100 * from index_frag order by page_count desc, frag
truncate table index_frag 



truncate table master.dbo.index_stats 
truncate table master.dbo.index_sizes

use P_REQ
execute as user='svu_job'
exec master.dbo.[IndexOptimize_P_REQ]  @execute ='N'

REVERT;  
GO  

select * from master.dbo.index_stats 
select * from master.dbo.index_sizes 
*/