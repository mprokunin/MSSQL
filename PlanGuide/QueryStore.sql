use P_AST

SELECT top 10 Pl.query_id, Txt.query_sql_text, Pl.plan_id, Pl.Query_plan_hash, convert(numeric(10,0),max(Stat.avg_logical_io_reads)) as max_avg_logical_io_reads--, Qry.*  
FROM sys.query_store_plan AS Pl  
INNER JOIN sys.query_store_query AS Qry  
    ON Pl.query_id = Qry.query_id  
INNER JOIN sys.query_store_query_text AS Txt  
    ON Qry.query_text_id = Txt.query_text_id 
INNER JOIN sys.query_store_runtime_stats Stat on Stat.plan_id = Pl.plan_id
and Stat.last_execution_time > dateadd(hh, -4, getdate())
where --Pl.plan_id = 687414
--Pl.query_id = 567028
group by Pl.query_id, Txt.query_sql_text, Pl.plan_id, Pl.query_plan_hash
order by max(Stat.avg_logical_io_reads) desc


0x06000700B977931B50DABFF7ED00000001000000000000000000000000000000000000000000000000000000

select top 100 query_hash, * FROM sys.query_store_query where query_id = 567028
select top 100 * FROM sys.dm_exec_query_stats where query_hash = 0x3051D293F16C72B2
select top 100 * FROM sys.dm_exec_query_stats where sql_handle = 0x03000400DBB2524FE759470181A7000001000000000000000000000000000000000000000000000000000000
select top 100 * FROM sys.query_store_plan AS Pl  
select top 100 * FROM sys.dm_exec_query_stats where plan_handle = 0x06000700B977931B50DABFF7ED00000001000000000000000000000000000000000000000000000000000000
select top 100 sql_handle, * FROM sys.sysprocesses where spid = 64
sp_create_plan_guide_from_handle @name = N'Fifo_PlanGuide1',  @plan_handle = 0xA48D91769C1D15BA
--plan hash 0x7A1047CA8222D1A3


SELECT cp.plan_handle, sql_handle, st.text, objtype   
FROM sys.dm_exec_cached_plans AS cp  
JOIN sys.dm_exec_query_stats AS qs ON cp.plan_handle = qs.plan_handle  
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS st;
