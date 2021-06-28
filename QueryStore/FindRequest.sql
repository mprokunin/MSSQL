use [DI_STAT]
go
-- Get SQL Text
select top 100 txt.query_sql_text, qsq.query_id, stat.avg_logical_io_reads, stat.avg_duration/1000000 as 'duration_sec' from Sys.query_store_query_text txt
	join Sys.query_store_query qsq 	on qsq.query_text_id=txt.query_text_id	
		--and txt.query_text_id=5776
		and txt.query_sql_text like '%UPDAT%'
	join Sys.query_store_plan  pln 	on pln.query_id=qsq.query_id 
--		and qsq.query_id=267
	join Sys.query_store_runtime_stats stat on stat.plan_id= pln.plan_id
	where stat.last_execution_time > '2019-11-05' --and stat.last_execution_time <= '2019-03-14' 
	order by stat.last_execution_time desc
	--order by stat.last_duration desc
go
-- Get Plan
SELECT
  plan_id,
  query_id,
  CAST(query_plan AS XML) AS 'Execution Plan'
FROM sys.query_store_plan
where plan_id = 38185
go

---------

select top 10 * from Sys.query_store_query_text where query_sql_text like '%recep_info%'
select top 10 * from Sys.query_store_query_text where query_sql_text like '%FROM dbo._InfoRg8251%'

select top 10 * from Sys.query_store_runtime_stats
select top 10 * from Sys.query_store_plan
select top 10 * from Sys.query_store_query qsq 

