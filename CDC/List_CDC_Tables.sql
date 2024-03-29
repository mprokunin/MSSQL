-- List CDC enabled databases

SELECT name, database_id, is_cdc_enabled FROM sys.databases
WHERE is_cdc_enabled = 1
go
USE AtonBase
GO
-- List CDC enabled tables

SELECT s.name AS Schema_Name, tb.name AS Table_Name
, tb.object_id, tb.type, tb.type_desc, tb.is_tracked_by_cdc
FROM sys.tables tb
INNER JOIN sys.schemas s on s.schema_id = tb.schema_id
WHERE tb.is_tracked_by_cdc = 1
go