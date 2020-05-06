USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[sp__dbinfo]    Script Date: 28/06/2018 14:47:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


create procedure [dbo].[sp__dbinfo] @order nvarchar(1) = NULL as
begin
declare @sql nvarchar(255)

create table #dbinfo (
	DBName nvarchar(255),
	[FileName] nvarchar(255),
	PhysicalName nvarchar(255),
	CurrentSizeMB int,
	SpaceUsedMB int,
	FreeMB int
)

exec msdb..sp_msforeachdb '
if ''?'' not in (''tempdb'', ''model'', ''msdb'', ''master'')
begin
use [?]
insert into #dbinfo
select
"?",
[name],
[physical_name],
(size*8/1024),
(FILEPROPERTY(name, "SpaceUsed")*8/1024),
((size*8 - FILEPROPERTY(name, "SpaceUsed")*8)/1024)
from [?].sys.database_files
end
'

set @sql = 'select * from #dbinfo'

if (@order is not null) and (@order in ('1', '2', '3', '4', '5','6'))
begin
	set @sql = @sql + ' order by ' + @order + ' asc'
end
else set @sql = @sql + ' order by FreeMB desc'

exec (@sql)
select SUM(FreeMB) as SumFreeMB from #dbinfo

drop table #dbinfo

end

GO


