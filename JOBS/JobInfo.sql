USE [msdb]
GO
ALTER ROLE [SQLAgentOperatorRole] DROP MEMBER [RIMOS_NT_01\TkachSe]
GO
sp_who [RIMOS_NT_01\TkachSe]
sp_helplogins [RIMOS_NT_01\TkachSe]
select @@SERVERNAME, @@VERSION
select top 100 * from msdb..sysjobs
sp_helprotect sysjobs
use [msdb]
setuser 'RIMOS_NT_01\TkachSe'



select
(case when D.is_read_only = 1 then '-- Remove ReadOnly State' when D.state_desc = 'ONLINE' then 'ALTER AUTHORIZATION on DATABASE::['+D.name+'] to [SA];' else '-- Turn On ' end) as CommandToRun
,D.name as Database_Name
, D.database_id as Database_ID
,L.Name as Login_Name
,D.state_desc as Current_State
,D.is_read_only as [ReadOnly]
from master.sys.databases D
inner join master.sys.syslogins L on D.owner_sid = L.sid
where L.Name <> 'sa'
order by D.Name;

--Agent Jobs


--Agent Jobs
select
J.name as SQL_Agent_Job_Name
,msdb.dbo.SQLAGENT_SUSER_SNAME(j.owner_sid) as Job_Owner
,J.description
,C.name
,'EXEC msdb.dbo.sp_update_job @job_id=N'''+cast(job_id as varchar(150))+''', @owner_login_name=N''sa'' ' as RunCode
from msdb.dbo.sysjobs j
--inner join master.sys.syslogins L on J.owner_sid = L.sid
inner join msdb.dbo.syscategories C on C.category_id = J.category_id
where msdb.dbo.SQLAGENT_SUSER_SNAME(j.owner_sid) <> 'sa';