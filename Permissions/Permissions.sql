select  princ.name
,       princ.type_desc
,       perm.permission_name
,       perm.state_desc
,       perm.class_desc
,       object_name(perm.major_id)
from    sys.database_principals princ
left join
        sys.database_permissions perm
on      perm.grantee_principal_id = princ.principal_id
where princ.name like '%SERG%'

--sp_help EventLogArchive

-------------- Check role members
sp_helprolemember MainEventLogUsers



-------------- Find all database users and their role memberships
DECLARE @dbname nvarchar(123)
, @id int
, @max int
, @cmdDBUsersRoles nvarchar(max)

-- temp table to stored the databases
IF OBJECT_ID('tempdb..#db_list') IS NOT NULL
    DROP TABLE #db_list

CREATE TABLE #db_list
(
    id int identity (1,1)
    , dbname nvarchar(123)
);

-- temp table to store the databases, users, roles that users belong to
IF OBJECT_ID('tempdb..#dbs_users_roles') IS NOT NULL
	DROP TABLE #dbs_users_roles

CREATE TABLE #dbs_users_roles
(
	dbname nvarchar(123),
	dbuser nvarchar(123),
	dbrole nvarchar(123),
	account_type nvarchar(123),
	create_date datetime,
	modify_date datetime
);

-- load the database list into the temp table
INSERT INTO #db_list
SELECT db.name
FROM sys.databases db
WHERE db.state = 0 
and name='AB_Hist';

-- initialize the counters 
SELECT @id = 1, @max = max(id)
FROM #db_list

-- loop to process 
WHILE (@id <= @max)
BEGIN
    SELECT @dbname = dbname
    FROM #db_list
    WHERE id = @id;

	SET @cmdDBUsersRoles = 'USE ' +@dbname+
		' SELECT DB_NAME(), 
			dp.name,
			rp.name,
			dp.type_desc,
			dp.create_date,
			dp.modify_date
		FROM sys.database_role_members drm JOIN sys.database_principals rp
				ON drm.role_principal_id = rp.principal_id
			JOIN sys.database_principals dp
				ON drm.member_principal_id = dp.principal_id';

	INSERT INTO #dbs_users_roles
	EXEC (@cmdDBUsersRoles);

	SET @id = @id + 1;
END


SELECT dsr.dbname AS [Database Name],
	dsr.dbuser AS [Database User],
	dsr.dbrole AS [Database Role],
	dsr.account_type AS [Account Type],
	dsr.create_date,
	dsr.modify_date
FROM #dbs_users_roles AS dsr
where dsr.dbname = 'AB_Hist' --and dsr.dbrole = 'MainEventLogUsers';
and dsr.dbuser = 'MDA'

select 'alter role MainEventLogUsers  add member ' + dsr.dbuser
FROM #dbs_users_roles AS dsr
where dsr.dbname = 'ABCBase' and dsr.dbrole = 'MainEventLogUsers';

-----------------------------

sp_spaceused EventLog 
sp_spaceused '[dbo].[tblAssetOnOperPlaceChangeHistory]'
sp_spaceused '[dbo].[tblAssetOnOperPlaceChangeHistoryStamp]'
-------------------
/*
Security Audit Report
1) List all access provisioned to a SQL user or Windows user/group directly
2) List all access provisioned to a SQL user or Windows user/group through a database or application role
3) List all access provisioned to the public role

Columns Returned:
UserType        : Value will be either 'SQL User', 'Windows User', or 'Windows Group'.
                  This reflects the type of user/group defined for the SQL Server account.
DatabaseUserName: Name of the associated user as defined in the database user account.  The database user may not be the
                  same as the server user.
LoginName       : SQL or Windows/Active Directory user account.  This could also be an Active Directory group.
Role            : The role name.  This will be null if the associated permissions to the object are defined at directly
                  on the user account, otherwise this will be the name of the role that the user is a member of.
PermissionType  : Type of permissions the user/role has on an object. Examples could include CONNECT, EXECUTE, SELECT
                  DELETE, INSERT, ALTER, CONTROL, TAKE OWNERSHIP, VIEW DEFINITION, etc.
                  This value may not be populated for all roles.  Some built in roles have implicit permission
                  definitions.
PermissionState : Reflects the state of the permission type, examples could include GRANT, DENY, etc.
                  This value may not be populated for all roles.  Some built in roles have implicit permission
                  definitions.
ObjectType      : Type of object the user/role is assigned permissions on.  Examples could include USER_TABLE,
                  SQL_SCALAR_FUNCTION, SQL_INLINE_TABLE_VALUED_FUNCTION, SQL_STORED_PROCEDURE, VIEW, etc.
                  This value may not be populated for all roles.  Some built in roles have implicit permission
                  definitions.
Schema          : Name of the schema the object is in.
ObjectName      : Name of the object that the user/role is assigned permissions on.
                  This value may not be populated for all roles.  Some built in roles have implicit permission
                  definitions.
ColumnName      : Name of the column of the object that the user/role is assigned permissions on. This value
                  is only populated if the object is a table, view or a table value function.
*/

    --1) List all access provisioned to a SQL user or Windows user/group directly
    SELECT
        [UserType] = CASE princ.[type]
                         WHEN 'S' THEN 'SQL User'
                         WHEN 'U' THEN 'Windows User'
                         WHEN 'G' THEN 'Windows Group'
                     END,
        [DatabaseUserName] = princ.[name],
        [LoginName]        = ulogin.[name],
        [Role]             = NULL,
        [PermissionType]   = perm.[permission_name],
        [PermissionState]  = perm.[state_desc],
        [ObjectType] = CASE perm.[class]
                           WHEN 1 THEN obj.[type_desc]        -- Schema-contained objects
                           ELSE perm.[class_desc]             -- Higher-level objects
                       END,
        [Schema] = objschem.[name],
        [ObjectName] = CASE perm.[class]
                           WHEN 3 THEN permschem.[name]       -- Schemas
                           WHEN 4 THEN imp.[name]             -- Impersonations
                           ELSE OBJECT_NAME(perm.[major_id])  -- General objects
                       END,
        [ColumnName] = col.[name]
    FROM
        --Database user
        sys.database_principals            AS princ
        --Login accounts
        LEFT JOIN sys.server_principals    AS ulogin    ON ulogin.[sid] = princ.[sid]
        --Permissions
        LEFT JOIN sys.database_permissions AS perm      ON perm.[grantee_principal_id] = princ.[principal_id]
        LEFT JOIN sys.schemas              AS permschem ON permschem.[schema_id] = perm.[major_id]
        LEFT JOIN sys.objects              AS obj       ON obj.[object_id] = perm.[major_id]
        LEFT JOIN sys.schemas              AS objschem  ON objschem.[schema_id] = obj.[schema_id]
        --Table columns
        LEFT JOIN sys.columns              AS col       ON col.[object_id] = perm.[major_id]
                                                           AND col.[column_id] = perm.[minor_id]
        --Impersonations
        LEFT JOIN sys.database_principals  AS imp       ON imp.[principal_id] = perm.[major_id]
    WHERE
        princ.[type] IN ('S','U','G')
        -- No need for these system accounts
        AND princ.[name] NOT IN ('sys', 'INFORMATION_SCHEMA')

UNION

    --2) List all access provisioned to a SQL user or Windows user/group through a database or application role
    SELECT
        [UserType] = CASE membprinc.[type]
                         WHEN 'S' THEN 'SQL User'
                         WHEN 'U' THEN 'Windows User'
                         WHEN 'G' THEN 'Windows Group'
                     END,
        [DatabaseUserName] = membprinc.[name],
        [LoginName]        = ulogin.[name],
        [Role]             = roleprinc.[name],
        [PermissionType]   = perm.[permission_name],
        [PermissionState]  = perm.[state_desc],
        [ObjectType] = CASE perm.[class]
                           WHEN 1 THEN obj.[type_desc]        -- Schema-contained objects
                           ELSE perm.[class_desc]             -- Higher-level objects
                       END,
        [Schema] = objschem.[name],
        [ObjectName] = CASE perm.[class]
                           WHEN 3 THEN permschem.[name]       -- Schemas
                           WHEN 4 THEN imp.[name]             -- Impersonations
                           ELSE OBJECT_NAME(perm.[major_id])  -- General objects
                       END,
        [ColumnName] = col.[name]
    FROM
        --Role/member associations
        sys.database_role_members          AS members
        --Roles
        JOIN      sys.database_principals  AS roleprinc ON roleprinc.[principal_id] = members.[role_principal_id]
        --Role members (database users)
        JOIN      sys.database_principals  AS membprinc ON membprinc.[principal_id] = members.[member_principal_id]
        --Login accounts
        LEFT JOIN sys.server_principals    AS ulogin    ON ulogin.[sid] = membprinc.[sid]
        --Permissions
        LEFT JOIN sys.database_permissions AS perm      ON perm.[grantee_principal_id] = roleprinc.[principal_id]
        LEFT JOIN sys.schemas              AS permschem ON permschem.[schema_id] = perm.[major_id]
        LEFT JOIN sys.objects              AS obj       ON obj.[object_id] = perm.[major_id]
        LEFT JOIN sys.schemas              AS objschem  ON objschem.[schema_id] = obj.[schema_id]
        --Table columns
        LEFT JOIN sys.columns              AS col       ON col.[object_id] = perm.[major_id]
                                                           AND col.[column_id] = perm.[minor_id]
        --Impersonations
        LEFT JOIN sys.database_principals  AS imp       ON imp.[principal_id] = perm.[major_id]
    WHERE
        membprinc.[type] IN ('S','U','G')
        -- No need for these system accounts
        AND membprinc.[name] NOT IN ('sys', 'INFORMATION_SCHEMA')

UNION

    --3) List all access provisioned to the public role, which everyone gets by default
    SELECT
        [UserType]         = '{All Users}',
        [DatabaseUserName] = '{All Users}',
        [LoginName]        = '{All Users}',
        [Role]             = roleprinc.[name],
        [PermissionType]   = perm.[permission_name],
        [PermissionState]  = perm.[state_desc],
        [ObjectType] = CASE perm.[class]
                           WHEN 1 THEN obj.[type_desc]        -- Schema-contained objects
                           ELSE perm.[class_desc]             -- Higher-level objects
                       END,
        [Schema] = objschem.[name],
        [ObjectName] = CASE perm.[class]
                           WHEN 3 THEN permschem.[name]       -- Schemas
                           WHEN 4 THEN imp.[name]             -- Impersonations
                           ELSE OBJECT_NAME(perm.[major_id])  -- General objects
                       END,
        [ColumnName] = col.[name]
    FROM
        --Roles
        sys.database_principals            AS roleprinc
        --Role permissions
        LEFT JOIN sys.database_permissions AS perm      ON perm.[grantee_principal_id] = roleprinc.[principal_id]
        LEFT JOIN sys.schemas              AS permschem ON permschem.[schema_id] = perm.[major_id]
        --All objects
        JOIN      sys.objects              AS obj       ON obj.[object_id] = perm.[major_id]
        LEFT JOIN sys.schemas              AS objschem  ON objschem.[schema_id] = obj.[schema_id]
        --Table columns
        LEFT JOIN sys.columns              AS col       ON col.[object_id] = perm.[major_id]
                                                           AND col.[column_id] = perm.[minor_id]
        --Impersonations
        LEFT JOIN sys.database_principals  AS imp       ON imp.[principal_id] = perm.[major_id]
    WHERE
        roleprinc.[type] = 'R'
        AND roleprinc.[name] = 'public'
        AND obj.[is_ms_shipped] = 0

ORDER BY
    [UserType],
    [DatabaseUserName],
    [LoginName],
    [Role],
    [Schema],
    [ObjectName],
    [ColumnName],
    [PermissionType],
    [PermissionState],
    [ObjectType]
