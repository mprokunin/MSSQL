USE master
go
IF object_id('dbo.view_exceptions') IS NULL
   EXEC('CREATE VIEW dbo.view_exceptions AS SELECT 1 AS dummy')
go
ALTER VIEW dbo.view_exceptions AS 
 WITH CTE AS (
   SELECT cast(event_data AS xml) AS xml, 
          row_number() OVER(ORDER BY file_name, file_offset) AS eventno
   FROM   sys.fn_xe_file_target_read_file('Exceptions*.xel', DEFAULT, NULL, NULL)
), extracted AS (
   SELECT eventno, 
          dateadd(HOUR, 
              datediff(HOUR, getutcdate(), getdate()), E.e.value('@timestamp', 'datetime2(3)')) AS when_,
                 D.d.value('@name', 'nvarchar(128)') AS name, 
                 D.d.value('(value/text())[1]', 'nvarchar(MAX)') AS value,
                 convert(varbinary(85), 
                       F.f.value('@handle', 'varchar(200)'), 1) AS sql_handle,
                 F.f.value('@line', 'int') AS linenum,
                 F.f.value('@offsetStart', 'int') AS stmt_start,
                 F.f.value('@offsetEnd', 'int') AS stmt_end
   FROM   CTE
   CROSS  APPLY CTE.xml.nodes('/event') AS E(e)
   CROSS  APPLY CTE.xml.nodes('/event/*') AS D(d)
   OUTER  APPLY D.d.nodes('value/frame') AS F(f)
), pivoted AS (
   SELECT eventno, when_,
          MIN(CASE name WHEN 'client_app_name' THEN value END) AS appname,
          MIN(CASE name WHEN 'client_hostname' THEN value END) AS hostname,
          MIN(CASE name WHEN 'session_server_principal_name' THEN value END) AS username,
          MIN(CASE name WHEN 'error_number' THEN CAST(value AS int) END) AS errno,
          MIN(CASE name WHEN 'message' THEN value END) AS errmsg,
          MIN(CASE name WHEN 'database_name' THEN value END) AS DB,
          MIN(CASE name WHEN 'sql_text' THEN value END) AS batch_text,
          MIN(CASE name WHEN 'tsql_frame' THEN sql_handle END) AS sql_handle,
          MIN(CASE name WHEN 'tsql_frame' THEN linenum END) AS linenum,
          MIN(CASE name WHEN 'tsql_frame' THEN stmt_start / 2 END) AS stmt_start,
          MIN(CASE name WHEN 'tsql_frame' THEN IIF(stmt_end = -1, 1000000000, 
               (stmt_end - stmt_start) / 2 + 1) END) AS stmt_len,
          MIN(CASE name WHEN 'severity' THEN value END) AS severity
   FROM   extracted
   GROUP BY eventno, when_
)
SELECT p.when_, p.username, p.hostname, p.appname, p.errno, p.errmsg, p.DB, 
       CASE WHEN est.dbid = 32767 THEN object_name(est.objectid)
            ELSE object_schema_name(coalesce(est.objectid,0), est.dbid) + '.' + 
                 object_name(coalesce(est.objectid, 0), est.dbid) 
       END AS SPname,
       p.linenum,  p.batch_text, substring(est.text, stmt_start + 1, stmt_len) AS statement,
	   p.severity
FROM   pivoted p
OUTER  APPLY sys.dm_exec_sql_text(p.sql_handle) est
GO
