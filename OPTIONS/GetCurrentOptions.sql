SELECT @@OPTIONS AS [user_options],
       CASE WHEN @@OPTIONS & 2 = 2 THEN 'ON' ELSE 'OFF' END AS [implicit_transactions],
       CASE WHEN @@OPTIONS & 4 = 4 THEN 'ON' ELSE 'OFF' END AS [cursor_close_on_commit],
       CASE WHEN @@OPTIONS & 8 = 8 THEN 'ON' ELSE 'OFF' END AS [ansi_warnings],
       CASE WHEN @@OPTIONS & 16 = 16 THEN 'ON' ELSE 'OFF' END AS [ansi_padding],
       CASE WHEN @@OPTIONS & 32 = 32 THEN 'ON' ELSE 'OFF' END AS [ansi_nulls],
       CASE WHEN @@OPTIONS & 256 = 256 THEN 'ON' ELSE 'OFF' END AS [quoted_identifier],
       CASE WHEN @@OPTIONS & 1024 = 1024 THEN 'ON' ELSE 'OFF' END AS [ansi_null_dflt_on],
       -- all above options combined
       CASE WHEN @@OPTIONS & 1342 = 1342 THEN 'ON' ELSE 'OFF' END AS [ansi_defaults]
------------- or
DBCC USEROPTIONS;  
-------------- For active sessions

SELECT
   session_id Session_Id,
   login_name LoginName,
   host_name HostName,
   login_time LoginTime,
   DB_NAME(database_id) DatabaseName,
   program_name ProgramName,
   [status] Status,
   text_size,
   language,
   date_format,
   date_first,
   quoted_identifier,
   arithabort,
   ansi_null_dflt_on,
   ansi_defaults,
   ansi_warnings,
   ansi_padding,
   ansi_nulls,
   concat_null_yields_null
FROM
   sys.dm_exec_sessions
WHERE
   is_user_process = 1
   
