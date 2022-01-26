use BP
go
EXECUTE AS user = 'StockRobot'  
GO  
SELECT HAS_PERMS_BY_NAME (QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name),  'OBJECT', 'SELECT') AS have_update, * FROM sys.tables  
where name='CompanyContacts'
GO  
REVERT;  
GO  

SELECT HAS_PERMS_BY_NAME (QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name),  'OBJECT', 'EXEC') AS have_update, * FROM sys.objects
where type='P' --and name like 'mware4_set_oper_f2m'
order by name
go


-- Check permission to Schema
DECLARE @username nvarchar(128) = 'MainTicketUsers';
SELECT COUNT(*) FROM sys.database_permissions 
    WHERE grantee_principal_id = (SELECT UID FROM sysusers WHERE name = @username) 
        AND class_desc = 'DATABASE'
        AND type='EX' 
        AND permission_name='EXECUTE' 
        AND state = 'G';





sp_helprotect CompanyContacts

select OBJECT_NAME(major_id),* from sys.database_permissions where grantee_principal_id = USER_ID('StockRobot') 
and OBJECT_NAME(major_id) like 'mware4_set_o%'
order by OBJECT_NAME(major_id)

SELECT * FROM sys.fn_builtin_permissions('dbo');  

sp_helpuser InternAPI