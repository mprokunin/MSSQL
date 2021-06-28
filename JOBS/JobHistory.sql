select 
 j.name as 'JobName', h.step_name, run_status,
 --run_date, run_time,
 msdb.dbo.agent_datetime(run_date, run_time) as 'RunDateTime',
 run_duration
From msdb.dbo.sysjobs j 
INNER JOIN msdb.dbo.sysjobhistory h 
 ON j.job_id = h.job_id 
where j.enabled = 1  --Only Enabled Jobs
and h.step_id > 0
and j.name like 'ADM.IndexO%'
and msdb.dbo.agent_datetime(run_date, run_time) >= '2021-03-15 00:00:00' and msdb.dbo.agent_datetime(run_date, run_time) < '2021-03-15 04:00:00' 
order by RunDateTime desc, j.name 


select * from msdb.dbo.sysjobs where name = 'OTA activity' -- 5D9C7C83-FCA9-46BC-A185-DF9C991EE1C0

select top 10 * from msdb.dbo.sysjobhistory where job_id = '5D9C7C83-FCA9-46BC-A185-DF9C991EE1C0'

select @@VERSION