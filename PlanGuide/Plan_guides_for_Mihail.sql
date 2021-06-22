--use DB
go
set QUOTED_IDENTIFIER off

IF (sys.fn_hadr_is_primary_replica('OMS'))=1
print 1
begin


declare @ErrorMessage NVARCHAR(4000),
@ErrorSeverity INT,
@ErrorState INT


declare @tmxml nvarchar(max),
@planname nvarchar(255)



set @tmxml = ''
set @planname = ''
 IF (select object_id('tempdb..#t11')) is not null 
drop table #t11
--set @tmxml=	 (

select 

 	--st.text  ,  



'EXEC sp_create_plan_guide @name =''[PlanGuide-REF147_2607' + master.dbo.fn_varbintohexstr(qs.sql_handle )+']'' , @stmt = N'''+ replace(substring( st.text, charindex('SELECT',st.text ) ,len(st.text ) ) ,"'","''")
+''', @type = N''SQL'''+ ', @module_or_batch = N'''+replace(substring( st.text , charindex('SELECT',st.text ) ,len(st.text ) ),"'","''") +
+''', @params = N'''+replace(replace(replace(substring( st.text ,0, charindex('SELECT',st.text  )),'(@','@') ,'))',')'),'t)','t') +''','
+' @hints = N''option(loop join,querytraceon 8690, optimize for unknown,maxdop 1)'''


																											  
 	as [createtext],
'PlanGuide-REF147_2607'+master.dbo.fn_varbintohexstr   (qs.sql_handle ) as planguidename,
   qs.sql_handle ,
   0 as isprocessed ,

   query_sql_text = SUBSTRING (st.text,qs.statement_start_offset/2, 
         (CASE
            WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), st.text)) * 2 
            ELSE qs.statement_end_offset
         END - qs.statement_start_offset)/2)
   
   ,st.text 

	into #t11
	from  sys.dm_exec_query_stats as qs
         CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as st
	

WHERE qs.last_execution_time > DATEADD(hour, -12, GETDATE())  
and st.text like '(@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000))SELECT DISTINCT
@P1,
0.0,
T1._Code,
T1._Fld155
FROM dbo.%'
and st.text not like '%SELECT top 100%'
--and st.text like '% ASC' 
--and st.text like '(@p%' 


  			
   
	while exists(select 1 from 	#t11 where   isprocessed=0)
	begin
		
		select top 1 @tmxml=[createtext],@planname =planguidename from  #t11 where isprocessed=0
		if not exists (select 1 from sys.plan_guides where [name] =@planname)
		begin
				begin try
				exec (@tmxml)
				update #t11 set 	 isprocessed=1 where planguidename	=@planname
				end try 
				begin catch
				
				select				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
				PRINT 'DATE : ' + CONVERT(VARCHAR, GETDATE()) 
				PRINT 'ERROR CODE : ' + CONVERT(VARCHAR, ERROR_NUMBER())  
				PRINT 'ERROR MESSAGE : ' + @ErrorMessage
				RAISERROR (@ErrorMessage, -- Message id.
           1, -- Severity,
           @ErrorState );
		   
		  		     rollback
		   update #t11 set 	 isprocessed=2 where planguidename	=@planname
				end catch
		
		end
		else 
		begin
				--exec sp_control_plan_guide  	@operation  = N'DROP', @name = 	@planname
				begin try
				--exec (@tmxml)
				update #t11 set 	 isprocessed=3 where planguidename	=@planname
				end try 
				begin catch
				
				select				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
				PRINT 'DATE : ' + CONVERT(VARCHAR, GETDATE()) 
				PRINT 'ERROR CODE : ' + CONVERT(VARCHAR, ERROR_NUMBER())  
				PRINT 'ERROR MESSAGE : ' + @ErrorMessage
				RAISERROR (@ErrorMessage, -- Message id.
           1, -- Severity,
           @ErrorState );
		   rollback
		   update #t11 set 	 isprocessed=2 where planguidename	=@planname
				end catch
				
		
		

	end

	end
	

	---------------------------------------------------------


	
--declare @tmxml nvarchar(max),
--		@planname nvarchar(255)

set @tmxml = ''
set @planname = ''


IF (select object_id('tempdb..#t1')) is not null 
drop table #t1
--set @tmxml=	 (

select 

distinct top 1000	--qt.query_sql_text ,  
REPLACE(

REPLACE(REPLACE(
'EXEC sp_create_plan_guide @name =''[PlanGuide-Ref126-'+cast(q.query_id as varchar)+']'' , @stmt = N'''+ substring( qt.query_sql_text, charindex('SELECT',qt.query_sql_text) ,len(qt.query_sql_text) ) 
+''', @type = N''SQL'''+ ', @module_or_batch = N'''+substring( qt.query_sql_text, charindex('SELECT',qt.query_sql_text) ,len(qt.query_sql_text) ) +''', @params = N'''+ substring( qt.query_sql_text, 2,charindex('SELECT',qt.query_sql_text)-3  ) +''','
+' @hints = N''option (loop join,fast 10,querytraceon 8690,querytraceon 9481, optimize for unknown, maxdop 1)''',char(13),''+char(13)+''),char(10),''+char(10)+''), 
'@P7 datetime2(3),@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 varbinary(16),@P4 varbinary(16),@P5 varbinary(16),@P6 datetime2(3)'
,'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 varbinary(16),@P4 varbinary(16),@P5 varbinary(16),@P6 datetime2(3),@P7 datetime2(3)')
																											  
 	as [createtext],
'PlanGuide-Ref126-'+cast(q.query_id as varchar) as planguidename,
   q.query_id, 
   0 as isprocessed 
--,	q.last_compile_batch_sql_handle,q.last_compile_batch_offset_start,q.last_compile_batch_offset_end,
   --qt.query_sql_text,
 --substring( qt.query_sql_text, charindex('SELECT',qt.query_sql_text) ,len(qt.query_sql_text) ) as querytext,
 --substring( qt.query_sql_text, 2,charindex('SELECT',qt.query_sql_text)-3  ) as paramtext,
 
 --q.query_id,  
    --qt.query_text_id, p.plan_id
	--,    max(rs.last_execution_time   )
	into #t1

FROM sys.query_store_query_text AS qt   
JOIN sys.query_store_query AS q   
    ON qt.query_text_id = q.query_text_id   
JOIN sys.query_store_plan AS p   
    ON q.query_id = p.query_id   
JOIN sys.query_store_runtime_stats AS rs   
    ON p.plan_id = rs.plan_id  
WHERE rs.last_execution_time > DATEADD(hour, -2, GETUTCDATE())  
and  qt.query_sql_text like '(@P7 datetime2(3),@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 varbinary(16),@P4 varbinary(16),@P5 varbinary(16),@P6 datetime2(3)%'
group by  qt.query_sql_text, q.query_id,  
    qt.query_text_id, p.plan_id	,
	q.last_compile_batch_sql_handle,q.last_compile_batch_offset_start,q.last_compile_batch_offset_end
   order by query_id desc



   			
   
	while exists(select 1 from 	#t1 where   isprocessed=0)
	begin
		
		select top 1 @tmxml=[createtext],@planname =planguidename from  #t1 where isprocessed=0
		if not exists (select 1 from sys.plan_guides where [name] =@planname)
		begin
				begin try
				exec (@tmxml)
				update #t1 set 	 isprocessed=1 where planguidename	=@planname
				end try 
				begin catch
				
				select				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
				PRINT 'DATE : ' + CONVERT(VARCHAR, GETDATE()) 
				PRINT 'ERROR CODE : ' + CONVERT(VARCHAR, ERROR_NUMBER())  
				PRINT 'ERROR MESSAGE : ' + @ErrorMessage
				RAISERROR (@ErrorMessage, -- Message id.
           1, -- Severity,
           @ErrorState );
		   
		  		     rollback
		   update #t1 set 	 isprocessed=2 where planguidename	=@planname
				end catch
		
		end
		else 
		begin
				--exec sp_control_plan_guide  	@operation  = N'DROP', @name = 	@planname
				begin try
				--exec (@tmxml)
				update #t1 set 	 isprocessed=3 where planguidename	=@planname
				end try 
				begin catch
				
				select				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
				PRINT 'DATE : ' + CONVERT(VARCHAR, GETDATE()) 
				PRINT 'ERROR CODE : ' + CONVERT(VARCHAR, ERROR_NUMBER())  
				PRINT 'ERROR MESSAGE : ' + @ErrorMessage
				RAISERROR (@ErrorMessage, -- Message id.
           1, -- Severity,
           @ErrorState );
		   rollback
		   update #t1 set 	 isprocessed=2 where planguidename	=@planname
				end catch

				
		end
		

	end


-------	 	PlanGuide-Ref329

	
set @tmxml = ''
set @planname = ''
 IF (select object_id('tempdb..#t4')) is not null 
drop table #t4
--set @tmxml=	 (

select 

distinct top 1000	--qt.query_sql_text ,  



'EXEC sp_create_plan_guide @name =''[PlanGuide-Ref329-'+cast(q.query_id as varchar)+']'' , @stmt = N'''+ substring( qt.query_sql_text, charindex('SELECT',qt.query_sql_text) ,len(qt.query_sql_text) ) 
+''', @type = N''SQL'''+ ', @module_or_batch = N'''+substring( qt.query_sql_text, charindex('SELECT',qt.query_sql_text) ,len(qt.query_sql_text) ) +''','
+' @hints = N''option (loop join)'''


																											  
 	as [createtext],
'PlanGuide-Ref329-'+cast(q.query_id as varchar) as planguidename,
   q.query_id, 
   0 as isprocessed 
--,	q.last_compile_batch_sql_handle,q.last_compile_batch_offset_start,q.last_compile_batch_offset_end,
   --qt.query_sql_text,
 --substring( qt.query_sql_text, charindex('SELECT',qt.query_sql_text) ,len(qt.query_sql_text) ) as querytext,
 --substring( qt.query_sql_text, 2,charindex('SELECT',qt.query_sql_text)-3  ) as paramtext,
 
 --q.query_id,  
    --qt.query_text_id, p.plan_id
	--,    max(rs.last_execution_time   )
	into #t4

FROM sys.query_store_query_text AS qt   
JOIN sys.query_store_query AS q   
    ON qt.query_text_id = q.query_text_id   
JOIN sys.query_store_plan AS p   
    ON q.query_id = p.query_id   
JOIN sys.query_store_runtime_stats AS rs   
    ON p.plan_id = rs.plan_id  
WHERE rs.last_execution_time > DATEADD(hour, -12, GETUTCDATE())  
and  (qt.query_sql_text like 'SELECT
T1._Fld330RRef,
T1._Fld331RRef,
T1._IDRRef,%'

or qt.query_sql_text like 'SELECT
T2._Fld330RRef,
T2._Fld331RRef,
T2._IDRRef,%')
group by  qt.query_sql_text, q.query_id,  
    qt.query_text_id, p.plan_id	,
	q.last_compile_batch_sql_handle,q.last_compile_batch_offset_start,q.last_compile_batch_offset_end
   order by query_id desc



   			
   
	while exists(select 1 from 	#t4 where   isprocessed=0)
	begin
		
		select top 1 @tmxml=[createtext],@planname =planguidename from  #t4 where isprocessed=0
		if not exists (select 1 from sys.plan_guides where [name] =@planname)
		begin
				begin try
				exec (@tmxml)
				update #t4 set 	 isprocessed=1 where planguidename	=@planname
				end try 
				begin catch
				
				select				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
				PRINT 'DATE : ' + CONVERT(VARCHAR, GETDATE()) 
				PRINT 'ERROR CODE : ' + CONVERT(VARCHAR, ERROR_NUMBER())  
				PRINT 'ERROR MESSAGE : ' + @ErrorMessage
				RAISERROR (@ErrorMessage, -- Message id.
           1, -- Severity,
           @ErrorState );
		   
		  		     rollback
		   update #t4 set 	 isprocessed=2 where planguidename	=@planname
				end catch
		
		end
		else 
		begin
				--exec sp_control_plan_guide  	@operation  = N'DROP', @name = 	@planname
				begin try
			--	exec (@tmxml)
				update #t4 set 	 isprocessed=3 where planguidename	=@planname
				end try 
				begin catch
				
				select				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
				PRINT 'DATE : ' + CONVERT(VARCHAR, GETDATE()) 
				PRINT 'ERROR CODE : ' + CONVERT(VARCHAR, ERROR_NUMBER())  
				PRINT 'ERROR MESSAGE : ' + @ErrorMessage
				RAISERROR (@ErrorMessage, -- Message id.
           1, -- Severity,
           @ErrorState );
		   rollback
		   update #t4 set 	 isprocessed=2 where planguidename	=@planname
				end catch
				
		
		

	end

	end
--------------------------------------------

 --	PlanGuide-Ref709


set @tmxml = ''
set @planname = ''
 IF (select object_id('tempdb..#t5')) is not null 
drop table #t5
--set @tmxml=	 (

select 

distinct top 1000	--qt.query_sql_text ,  



'EXEC sp_create_plan_guide @name =''[PlanGuide-Ref709-'+cast(q.query_id as varchar)+']'' , @stmt = N'''+ substring( qt.query_sql_text, charindex('INSERT',qt.query_sql_text) ,len(qt.query_sql_text) ) 
+''', @type = N''SQL'''+ ', @module_or_batch = N'''+substring( qt.query_sql_text, charindex('INSERT',qt.query_sql_text) ,len(qt.query_sql_text) ) 
+''', @params = N''@P1 nvarchar(4000),@P2 numeric(10),@P3 datetime2(3),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000),@P7 nvarchar(4000),@P8 nvarchar(4000),@P9 nvarchar(4000),@P10 nvarchar(4000),@P11 nvarchar(4000)'','
+' @hints = N''option (loop join)'''


																											  
 	as [createtext],
'PlanGuide-Ref709-'+cast(q.query_id as varchar) as planguidename,
   q.query_id, 
   0 as isprocessed 
--,	q.last_compile_batch_sql_handle,q.last_compile_batch_offset_start,q.last_compile_batch_offset_end,
   --qt.query_sql_text,
 --substring( qt.query_sql_text, charindex('SELECT',qt.query_sql_text) ,len(qt.query_sql_text) ) as querytext,
 --substring( qt.query_sql_text, 2,charindex('SELECT',qt.query_sql_text)-3  ) as paramtext,
 
 --q.query_id,  
    --qt.query_text_id, p.plan_id
	--,    max(rs.last_execution_time   )

	into #t5
FROM sys.query_store_query_text AS qt   
JOIN sys.query_store_query AS q   
    ON qt.query_text_id = q.query_text_id   
JOIN sys.query_store_plan AS p   
    ON q.query_id = p.query_id   
JOIN sys.query_store_runtime_stats AS rs   
    ON p.plan_id = rs.plan_id  
WHERE rs.last_execution_time > DATEADD(hour, -12, GETUTCDATE())  
and  qt.query_sql_text like '%ON (CASE WHEN T4._IDRRef IS NOT NULL THEN 0x08 END = T3._Fld718_TYPE AND CASE WHEN T4._IDRRef IS NOT NULL THEN 0x00 END = T3._Fld718_L AND CASE WHEN T4._IDRRef IS NOT NULL THEN @P2 END = T3._Fld718_N AND CASE WHEN T4._IDRRef IS NOT NULL THEN @P3 END = T3._Fld718_T AND CASE WHEN T4._IDRRef IS NOT NULL THEN @P4 END = T3._Fld718_S AND CASE WHEN T4._IDRRef IS NOT NULL THEN 0x000002AA END = T3._Fld718_RTRef AND T4._IDRRef = T3._Fld718_RRRef)
WHERE (T2._Description IN (@P5, @P6, @P7, @P8, @P9, @P10, @P11))'

group by  qt.query_sql_text, q.query_id,  
    qt.query_text_id, p.plan_id	,
	q.last_compile_batch_sql_handle,q.last_compile_batch_offset_start,q.last_compile_batch_offset_end
   order by query_id desc
      


   			
   
	while exists(select 1 from 	#t5 where   isprocessed=0)
	begin
		
		select top 1 @tmxml=[createtext],@planname =planguidename from  #t5 where isprocessed=0
		if not exists (select 1 from sys.plan_guides where [name] =@planname)
		begin
				begin try
				exec (@tmxml)
				update #t5 set 	 isprocessed=1 where planguidename	=@planname
				end try 
				begin catch
				
				select				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
				PRINT 'DATE : ' + CONVERT(VARCHAR, GETDATE()) 
				PRINT 'ERROR CODE : ' + CONVERT(VARCHAR, ERROR_NUMBER())  
				PRINT 'ERROR MESSAGE : ' + @ErrorMessage
				RAISERROR (@ErrorMessage, -- Message id.
           1, -- Severity,
           @ErrorState );
		   
		  		     rollback
		   update #t5 set 	 isprocessed=2 where planguidename	=@planname
				end catch
		
		end
		else 
		begin
				--exec sp_control_plan_guide  	@operation  = N'DROP', @name = 	@planname
				begin try
				--exec (@tmxml)
				update #t5 set 	 isprocessed=3 where planguidename	=@planname
				end try 
				begin catch
				
				select				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
				PRINT 'DATE : ' + CONVERT(VARCHAR, GETDATE()) 
				PRINT 'ERROR CODE : ' + CONVERT(VARCHAR, ERROR_NUMBER())  
				PRINT 'ERROR MESSAGE : ' + @ErrorMessage
				RAISERROR (@ErrorMessage, -- Message id.
           1, -- Severity,
           @ErrorState );
		   rollback
		   update #t5 set 	 isprocessed=2 where planguidename	=@planname
				end catch
				
		
		

	end

	end






end