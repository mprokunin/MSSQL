USE [master]
GO

/****** Object:  StoredProcedure [dbo].[sp__dbinfo]    Script Date: 25.11.2019 16:15:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

--use msdb
--drop procedure [dbo].[sp__dbinfo] 
--go
create procedure [dbo].[sp__dbinfo] @order nvarchar(1) = NULL as
begin
declare @sql nvarchar(255)

create table #dbinfo (
	DBName nvarchar(255),
	[FileName] nvarchar(255),
	PhysicalName nvarchar(255),
	CurrentSizeMB bigint,
	SpaceUsedMB bigint,
	FreeMB bigint
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
(convert(bigint,size)*8/1024),
(FILEPROPERTY(name, "SpaceUsed")*convert(bigint,8)/1024),
((convert(bigint,size)*8 - FILEPROPERTY(name, "SpaceUsed")*convert(bigint,8))/1024)
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

EXEC sp_ms_marksystemobject [sp__dbinfo] 
GO
grant exec on [sp__dbinfo] to [public]
GO



