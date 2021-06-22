-------------- Plan
SELECT EQP.query_plan, ER.*
FROM sys.dm_exec_requests AS ER
   CROSS APPLY sys.dm_exec_query_plan(ER.plan_handle) AS EQP
WHERE ER.session_id = 64


SELECT cp.plan_handle, sql_handle, st.text, objtype   
FROM sys.dm_exec_cached_plans AS cp  
JOIN sys.dm_exec_query_stats AS qs ON cp.plan_handle = qs.plan_handle  
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS st;

SELECT * FROM sys.dm_exec_query_stats AS qs  
CROSS APPLY sys.dm_exec_sql_text(sql_handle)  
CROSS APPLY sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) AS qp  
WHERE text LIKE N'%T5._Fld6814,%'
and plan_handle = 0x02000000B977931BC60EE80BB6E5BCC0179A7D66939FFE880000000000000000000000000000000000000000
GO  

-- Create a plan guide for the query by specifying the query plan in the plan cache.  
DECLARE @plan_handle varbinary(64);  
DECLARE @offset int;  
SELECT @plan_handle = plan_handle, @offset = qs.statement_start_offset  
FROM sys.dm_exec_query_stats AS qs  
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS st  
CROSS APPLY sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) AS qp  
WHERE text LIKE N'%(@P1 varbinary(16),@P2 varbinary(16),@P3 datetime2(3),@P4 varbinary(16),@P5 varbinary(16),@P6 varbinary(16),@P7 numeric(10),@P8 numeric(10),@P9 numeric(10),%';  

select @plan_handle, @offset 


EXECUTE sp_create_plan_guide_from_handle   
    @name =  N'Guide1',  
    @plan_handle = @plan_handle,  
    @statement_start_offset = @offset;  
GO  


EXECUTE sp_create_plan_guide_from_handle   
    @name =  N'Guide1',  
    @plan_handle = 0x06000700B977931B50DABFF7ED00000001000000000000000000000000000000000000000000000000000000,  
    @statement_start_offset = 1114;  
GO  
-- Verify that the plan guide is created.  
SELECT * FROM sys.plan_guides  
WHERE scope_batch LIKE N'%(@P1 varbinary(16),@P2 varbinary(16),@P3 datetime2(3),@P4 varbinary(16),@P5 varbinary(16),@P6 varbinary(16),@P7 numeric(10),@P8 numeric(10),@P9 numeric(10),%';  
GO  

EXEC sp_control_plan_guide N'DROP', N'Guide1'

-------------- Plan
SELECT EQP.query_plan, ER.*
FROM sys.dm_exec_requests AS ER
   CROSS APPLY sys.dm_exec_query_plan(ER.plan_handle) AS EQP
WHERE ER.session_id = 53

--plan handle 0x06000700B617220DD0AF21A3EF00000001000000000000000000000000000000000000000000000000000000
(@P1 varbinary(16),@P2 varbinary(16),@P3 datetime2(3),@P4 varbinary(16),@P5 varbinary(16),@P6 varbinary(16),@P7 numeric(10),@P8 numeric(10),@P9 numeric(10),@P10 numeric(10),@P11 numeric(10),@P12 numeric(10),@P13 datetime2(3),@P14 datetime2(3),@P15 varbinary(16),@P16 varbinary(16),@P17 varbinary(16),@P18 numeric(10),@P19 varbinary(16),@P20 varbinary(16),@P21 datetime2(3),@P22 varbinary(16),@P23 varbinary(16),@P24 varbinary(16),@P25 numeric(10),@P26 numeric(10),@P27 numeric(10),@P28 numeric(10),@P29 numeric(10),@P30 numeric(10),@P31 datetime2(3),@P32 datetime2(3),@P33 varbinary(16),@P34 varbinary(16),@P35 varbinary(16))SELECT T5._Fld6814, T1.Fld9307RRef, T1.Fld9308Balance_, T1.Fld9309Balance_, T1.Fld10145Balance_, CASE WHEN (T5._Fld6778RRef IN (@P1, @P2)) THEN T5._Fld6790RRef ELSE T5._Fld6787RRef END FROM (SELECT T2.Fld9307RRef AS Fld9307RRef, CAST(SUM(T2.Fld9309Balance_) AS NUMERIC(38, 8)) AS Fld9309Balance_, CAST(SUM(T2.Fld9308Balance_) AS NUMERIC(38, 8)) AS Fld9308Balance_, CAST(SUM(T2.Fld10145Balance_) AS NUMERIC(38, 8)) AS Fld10145Balance_ FROM (SELECT T3._Fld9307RRef AS Fld9307RRef, CAST(SUM(T3._Fld9309) AS NUMERIC(33, 8)) AS Fld9309Balance_, CAST(SUM(T3._Fld9308) AS NUMERIC(35, 8)) AS Fld9308Balance_, CAST(SUM(T3._Fld10145) AS NUMERIC(33, 8)) AS Fld10145Balance_ FROM dbo._AccumRgT9315 T3 WHERE T3._Period = @P3 AND ((((T3._Fld9304RRef = @P4) AND (T3._Fld9306RRef = @P5)) AND (T3._Fld9305_TYPE = 0x08 AND T3._Fld9305_RTRef = 0x0000005C AND T3._Fld9305_RRRef = @P6))) AND (T3._Fld9309 <> @P7 OR T3._Fld9308 <> @P8 OR T3._Fld10145 <> @P9) AND (T3._Fld9309 <> @P10 OR T3._Fld9308 <> @P11 OR T3._Fld10145 <> @P12) GROUP BY T3._Fld9307RRef HAVING (CAST(SUM(T3._Fld9309) AS NUMERIC(33, 8))) <> 0.0 OR (CAST(SUM(T3._Fld9308) AS NUMERIC(35, 8))) <> 0.0 OR (CAST(SUM(T3._Fld10145) AS NUMERIC(33, 8))) <> 0.0 UNION ALL SELECT T4._Fld9307RRef AS Fld9307RRef, CAST(CAST(SUM(CASE WHEN T4._RecordKind = 0.0 THEN -T4._Fld9309 ELSE T4._Fld9309 END) AS NUMERIC(27, 8)) AS NUMERIC(27, 2)) AS Fld9309Balance_, CAST(CAST(SUM(CASE WHEN T4._RecordKind = 0.0 THEN -T4._Fld9308 ELSE T4._Fld9308 END) AS NUMERIC(29, 8)) AS NUMERIC(30, 3)) AS Fld9308Balance_, CAST(CAST(SUM(CASE WHEN T4._RecordKind = 0.0 THEN -T4._Fld10145 ELSE T4._Fld10145 END) AS NUMERIC(27, 8)) AS NUMERIC(27, 2)) AS Fld10145Balance_ FROM dbo._AccumRg9303 T4 WHERE T4._Period >= @P13 AND T4._Period < @P14 AND T4._Active = 0x01 AND ((((T4._Fld9304RRef = @P15) AND (T4._Fld9306RRef = @P16)) AND (T4._Fld9305_TYPE = 0x08 AND T4._Fld9305_RTRef = 0x0000005C AND T4._Fld9305_RRRef = @P17))) GROUP BY T4._Fld9307RRef HAVING (CAST(CAST(SUM(CASE WHEN T4._RecordKind = 0.0 THEN -T4._Fld9309 ELSE T4._Fld9309 END) AS NUMERIC(27, 8)) AS NUMERIC(27, 2))) <> 0.0 OR (CAST(CAST(SUM(CASE WHEN T4._RecordKind = 0.0 THEN -T4._Fld9308 ELSE T4._Fld9308 END) AS NUMERIC(29, 8)) AS NUMERIC(30, 3))) <> 0.0 OR (CAST(CAST(SUM(CASE WHEN T4._RecordKind = 0.0 THEN -T4._Fld10145 ELSE T4._Fld10145 END) AS NUMERIC(27, 8)) AS NUMERIC(27, 2))) <> 0.0) T2 GROUP BY T2.Fld9307RRef HAVING (CAST(SUM(T2.Fld9309Balance_) AS NUMERIC(38, 8))) <> 0.0 OR (CAST(SUM(T2.Fld9308Balance_) AS NUMERIC(38, 8))) <> 0.0 OR (CAST(SUM(T2.Fld10145Balance_) AS NUMERIC(38, 8))) <> 0.0) T1 LEFT OUTER JOIN dbo._Document237 T5 ON (T1.Fld9307RRef = T5._IDRRef) WHERE (T1.Fld9308Balance_ < @P18) UNION SELECT T10._Fld6814, T6.Fld9294RRef, T6.Fld9295Balance_, T6.Fld9296Balance_, T6.Fld10144Balance_, CASE WHEN (T10._Fld6778RRef IN (@P19, @P20)) THEN T10._Fld6790RRef ELSE T10._Fld6787RRef END FROM (SELECT T7.Fld9294RRef AS Fld9294RRef, CAST(SUM(T7.Fld9296Balance_) AS NUMERIC(38, 8)) AS Fld9296Balance_, CAST(SUM(T7.Fld9295Balance_) AS NUMERIC(38, 8)) AS Fld9295Balance_, CAST(SUM(T7.Fld10144Balance_) AS NUMERIC(38, 8)) AS Fld10144Balance_ FROM (SELECT T8._Fld9294RRef AS Fld9294RRef, CAST(SUM(T8._Fld9296) AS NUMERIC(33, 8)) AS Fld9296Balance_, CAST(SUM(T8._Fld9295) AS NUMERIC(35, 8)) AS Fld9295Balance_, CAST(SUM(T8._Fld10144) AS NUMERIC(33, 8)) AS Fld10144Balance_ FROM dbo._AccumRgT9302 T8 WHERE T8._Period = @P21 AND ((((T8._Fld9291RRef = @P22) AND (T8._Fld9293RRef = @P23)) AND (T8._Fld9292_TYPE = 0x08 AND T8._Fld9292_RTRef = 0x0000005C AND T8._Fld9292_RRRef = @P24))) AND (T8._Fld9296 <> @P25 OR T8._Fld9295 <> @P26 OR T8._Fld10144 <> @P27) AND (T8._Fld9296 <> @P28 OR T8._Fld9295 <> @P29 OR T8._Fld10144 <> @P30) GROUP BY T8._Fld9294RRef HAVING (CAST(SUM(T8._Fld9296) AS NUMERIC(33, 8))) <> 0.0 OR (CAST(SUM(T8._Fld9295) AS NUMERIC(35, 8))) <> 0.0 OR (CAST(SUM(T8._Fld10144) AS NUMERIC(33, 8))) <> 0.0 UNION ALL SELECT T9._Fld9294RRef AS Fld9294RRef, CAST(CAST(SUM(CASE WHEN T9._RecordKind = 0.0 THEN -T9._Fld9296 ELSE T9._Fld9296 END) AS NUMERIC(27, 8)) AS NUMERIC(27, 2)) AS Fld9296Balance_, CAST(CAST(SUM(CASE WHEN T9._RecordKind = 0.0 THEN -T9._Fld9295 ELSE T9._Fld9295 END) AS NUMERIC(29, 8)) AS NUMERIC(30, 3)) AS Fld9295Balance_, CAST(CAST(SUM(CASE WHEN T9._RecordKind = 0.0 THEN -T9._Fld10144 ELSE T9._Fld10144 END) AS NUMERIC(27, 8)) AS NUMERIC(27, 2)) AS Fld10144Balance_ FROM dbo._AccumRg9290 T9 WHERE T9._Period >= @P31 AND T9._Period < @P32 AND T9._Active = 0x01 AND ((((T9._Fld9291RRef = @P33) AND (T9._Fld9293RRef = @P34)) AND (T9._Fld9292_TYPE = 0x08 AND T9._Fld9292_RTRef = 0x0000005C AND T9._Fld9292_RRRef = @P35))) GROUP BY T9._Fld9294RRef HAVING (CAST(CAST(SUM(CASE WHEN T9._RecordKind = 0.0 THEN -T9._Fld9296 ELSE T9._Fld9296 END) AS NUMERIC(27, 8)) AS NUMERIC(27, 2))) <> 0.0 OR (CAST(CAST(SUM(CASE WHEN T9._RecordKind = 0.0 THEN -T9._Fld9295 ELSE T9._Fld9295 END) AS NUMERIC(29, 8)) AS NUMERIC(30, 3))) <> 0.0 OR (CAST(CAST(SUM(CASE WHEN T9._RecordKind = 0.0 THEN -T9._Fld10144 ELSE T9._Fld10144 END) AS NUMERIC(27, 8)) AS NUMERIC(27, 2))) <> 0.0) T7 GROUP BY T7.Fld9294RRef HAVING (CAST(SUM(T7.Fld9296Balance_) AS NUMERIC(38, 8))) <> 0.0 OR (CAST(SUM(T7.Fld9295Balance_) AS NUMERIC(38, 8))) <> 0.0 OR (CAST(SUM(T7.Fld10144Balance_) AS NUMERIC(38, 8))) <> 0.0) T6 LEFT OUTER JOIN dbo._Document237 T10 ON (T6.Fld9294RRef = T10._IDRRef) ORDER BY 1, 2


SELECT top 10 Pl.query_id, Txt.query_sql_text, Pl.plan_id, Pl.Query_plan_hash, convert(numeric(10,0),max(Stat.avg_logical_io_reads)) as max_avg_logical_io_reads--, Qry.*  
FROM sys.query_store_plan AS Pl  
INNER JOIN sys.query_store_query AS Qry  
    ON Pl.query_id = Qry.query_id  
INNER JOIN sys.query_store_query_text AS Txt  
    ON Qry.query_text_id = Txt.query_text_id 
INNER JOIN sys.query_store_runtime_stats Stat on Stat.plan_id = Pl.plan_id
and Stat.last_execution_time > dateadd(hh, -4, getdate())
where --Pl.plan_id = 687414
Pl.query_id = 567028
group by Pl.query_id, Txt.query_sql_text, Pl.plan_id, Pl.query_plan_hash
order by max(Stat.avg_logical_io_reads) desc
