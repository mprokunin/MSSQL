USE [monitoring]
GO
/****** Object:  StoredProcedure [dbo].[GetFailedJobsFromServers]    Script Date: 24.03.2019 8:39:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetFailedJobsFromServers]   
  
AS  
  
begin  
  
-- пройтись по всем серверам и  
-- и вызвать сделать запросы по бэкапам  
  
   
 declare @servername varchar(100),@SQL varchar(max)  
   
   
  
 DECLARE server_cursor CURSOR FOR  
   
 select   
   name  
 from master.sys.servers srv with(nolock)  
  inner join monitoring.dbo.Server s on (s.server = srv.name)  
 where is_linked =1 and name not in ('AL-MAILEXTENDER', 'AOLSITE02', 'AOLWEBDB01', 'QUIK_SQL01', 'AOLNAVIGATORSQL','ABSSQL','EARCHIVESRV\SQL2005','QUIKTEST_APP','AOLESIGNSQL01','QUIK_SQL_COD') --and server_id =1   
  
  
OPEN server_cursor  
  
FETCH NEXT FROM server_cursor  
INTO @serverName  
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
  
set @SQL = 'INSERT INTO FailedJobsInfo (server,JobName, StepName, RunTime, Message, RunStatus, Processed)  
SELECT * from openquery(['+@servername+'],''select  
  '''''+@servername+''''',   
       j.Name,   
  jh.Step_name,   
  dateadd(hh, run_time / 10000,   
   dateadd(mi, (run_time % 10000)/100,   
   dateadd(ss, run_time %100,  
   cast(cast(run_date as char(8)) as datetime)))),  
  jh.message,  
  jh.run_status,  
  0  
FROM msdb..sysjobhistory jh   
JOIN msdb..sysjobs j on jh.job_id=j.job_id  
WHERE (jh.step_name NOT LIKE ''''%(Job outcome)%'''' AND jh.step_name NOT LIKE ''''%Process2012%'''' AND jh.run_status = 0)   
  AND (dateadd(hh, run_time / 10000,   
  dateadd(mi, (run_time % 10000)/100,   
  dateadd(ss, run_time %100,  
  cast(cast(run_date as char(8)) as datetime)))) >= DATEADD(mi,-62, GETDATE()))'')'   
    
--print @SQL      
begin try   
  
exec(@SQL)  
   
end try  
begin catch  
select 1  
end catch   
   FETCH NEXT FROM server_cursor  
   INTO @serverName  
  
END  
  
CLOSE server_cursor  
DEALLOCATE server_cursor  
   
   
  
end