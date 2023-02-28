Select CP.query_plan, 
      SQLText = SUBSTRING(st.text, (R.statement_start_offset/2)+1, 
        ((CASE R.statement_end_offset
          WHEN -1 THEN DATALENGTH(st.text)
         ELSE R.statement_end_offset
         END - R.statement_start_offset)/2) + 1),
      R.*
From sys.dm_exec_requests R
Cross Apply sys.dm_exec_query_plan (R.plan_handle) CP
Cross Apply sys.dm_exec_sql_text(R.sql_handle) st
Where R.status = 'suspended';
