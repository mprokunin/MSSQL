IF OBJECT_ID('dbo.sp_serverinfo') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_serverinfo
    IF OBJECT_ID('dbo.sp_serverinfo') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_serverinfo >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_serverinfo >>>'
END
go
create procedure dbo.sp_serverinfo
    @request	varchar(30) = NULL
    as
    declare @db_collation_name	char(30)
    
    select @db_collation_name = (SELECT CONVERT (varchar(256), SERVERPROPERTY('collation')) )
    if (@db_collation_name is null)
        begin
	    select @db_collation_name = 'internal'
	end
	
    -- If the collation information does not exist, use the default
/*
    if not exists ( select * from SYS.SYSCOLLATIONMAPPINGS
                    where collation_label = @db_collation_name )
	begin
	    select @db_collation_name = 'internal'
	end

    if (@request = 'server_soname')
	if( (select case_sensitivity from SYS.SYSINFO) = 'N' )
	    -- Case insensitive sort order
	    select so_caseless_label from SYS.SYSCOLLATIONMAPPINGS
	        where collation_label = @db_collation_name
	else 
            -- Case sensitive sort order
	    select so_case_label from SYS.SYSCOLLATIONMAPPINGS
	        where collation_label = @db_collation_name
    else if (@request = 'server_csname')
		SELECT CONVERT (varchar(256), SERVERPROPERTY('collation'));  
	select cs_label from SYS.SYSCOLLATIONMAPPINGS
	    where collation_label = @db_collation_name
*/
		SELECT CONVERT (varchar(256), SERVERPROPERTY('collation'));  
go
/*
CREATE procedure dbo.sp_server_info( 
	       in @attribute_id	    int		default NULL 
	       ) 
    begin 
	call sp_tsql_feature_not_supported() 
    end 

go
*/

grant exec on dbo.sp_serverinfo to public
--grant exec on dbo.sp_server_info to public
go

CREATE TABLE sys.SYSINFO (
	page_size	 INTEGER NOT NULL,
	encryption	 CHAR(1) NOT NULL,
	blank_padding	 CHAR(1) NOT NULL,
	case_sensitivity	 CHAR(1) NOT NULL,
	default_collation	 CHAR(10) NOT NULL,
	database_version	 SMALLINT NOT NULL,
	classes_version	 CHAR(10)
)

exec sp_serverinfo server_csname

--SELECT CONVERT (varchar(256), SERVERPROPERTY('collation'));  