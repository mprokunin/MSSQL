USE [master]
GO

/****** Object:  StoredProcedure [dbo].[sp__helplogins]    Script Date: 30.07.2019 18:44:05 ******/
if exists(select 1 from master.dbo.sysobjects where name='sp__helplogins' and type ='P')
	DROP PROCEDURE [dbo].[sp__helplogins]
GO

/****** Object:  StoredProcedure [dbo].[sp__helplogins]    Script Date: 30.07.2019 18:44:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp__helplogins]  
-- v1.1 2019-07-30   
    @LoginNamePattern     sysname    = NULL  
AS  
  
set nocount on  
  
declare  
  @exec_stmt nvarchar(3550)  
  
declare  
       @RetCode                        int  
      ,@CountSkipPossUsers             int  
      ,@Int1                           int  
  
declare  
       @c10DBName                      sysname  
      ,@c10DBStatus                    int  
      ,@c10DBSID                       varbinary(85)  
  
declare  
       @charMaxLenLoginName            varchar(11)  
      ,@charMaxLenDBName               varchar(11)  
      ,@charMaxLenUserName             varchar(11)  
      ,@charMaxLenLangName             varchar(11)  
  
declare  
       @DBOptLoading                   int   --0x0020      32  "DoNotRecover"  
      ,@DBOptPreRecovery               int   --0x0040      64  
      ,@DBOptRecovering                int   --0x0080     128  
  
      ,@DBOptSuspect                   int   --0x0100     256  ("not recovered")  
      ,@DBOptOffline                   int   --0x0200     512  
      ,@DBOptDBOUseOnly                int   --0x0800    2048  
  
      ,@DBOptSingleUser                int   --0x1000    4096  
  
  
-------------  create work holding tables  ----------------  
-- Create temp tables before any DML to ensure dynamic  
  
CREATE TABLE #tb2_PlainLogins  
   (  
    LoginName                       sysname        NOT Null  
   ,IsDisabled						bit NOT NULL
   ,SID                             varchar(85)    NOT Null  
   ,DefDBName                       sysname        Null  
   ,DefLangName                     sysname        Null  
   ,AUser                           char(5)        Null  
   ,ARemote                         char(7)        Null  
   ,sysadmin						int NULL
   ,securityadmin					int NULL 
   ,serveradmin						int NULL
   ,setupadmin						int NULL
   ,processadmin					int NULL
   ,diskadmin						int NULL
   ,dbcreator						int NULL
   ,bulkadmin						int NULL
   )  

  
CREATE TABLE #tb1_UA  
   (  
    LoginName                       sysname  NOT Null  
   ,DBName                          sysname  NOT Null  
   ,UserName                        sysname  NOT Null  
   ,UserOrAlias                     char(8)  NOT Null  
   )  
  
----------------  Initial data values  -------------------  
  
select  
       @RetCode                        = 0  -- 0=good ,1=bad  
      ,@CountSkipPossUsers             = 0  
  
  
----------------  Only SA can run this  -------------------  
  
  
if (not (is_srvrolemember('securityadmin') = 1))  
   begin  
   raiserror(15247,-1,-1)  
   select @RetCode = 1  
   goto label_86return  
   end  
  
----------------------  spt_values  ----------------  
-------- 'D'  
  
select       @DBOptLoading       = number  
      from   master.dbo.spt_values  
      where  type                = 'D'  
      and    name                = 'loading'  
  
select       @DBOptPreRecovery   = number  
      from   master.dbo.spt_values  
      where  type                = 'D'  
      and    name                = 'pre recovery'  
  
select       @DBOptRecovering    = number  
      from   master.dbo.spt_values  
      where  type                = 'D'  
      and    name                = 'recovering'  
  
select       @DBOptSuspect       = number  
      from   master.dbo.spt_values  
      where  type                = 'D'  
      and    name                = 'not recovered'  
  
select       @DBOptOffline       = number  
      from   master.dbo.spt_values  
      where  type                = 'D'  
      and    name                = 'offline'  
  
select       @DBOptDBOUseOnly    = number  
      from   master.dbo.spt_values  
      where  type                = 'D'  
      and    name                = 'dbo use only'  
  
select       @DBOptSingleUser    = number  
      from   master.dbo.spt_values  
      where  type                = 'D'  
      and    name                = 'single user'  
  
  
  
---------------  Cursor, for DBNames  -------------------  
  
  
declare ms_crs_10_DB  
   Cursor local static For  
select  
             name ,status ,sid  
      from  
             master.dbo.sysdatabases  
  
  
  
OPEN ms_crs_10_DB  
  
  
-----------------  LOOP 10:  thru Databases  ------------------  
  
  
--------------  
WHILE (10 = 10)  
   begin    --LOOP 10: thru Databases  
  
  
   FETCH  
             next  
      from  
             ms_crs_10_DB  
      into  
             @c10DBName  
            ,@c10DBStatus  
            ,@c10DBSID  
  
  
   IF (@@fetch_status <> 0)  
      begin  
      deallocate ms_crs_10_DB  
      BREAK  
      end  
  
  
--------------------  Okay if we peek inside this DB now?  
  
  
   IF (     @c10DBStatus & @DBOptDBOUseOnly  > 0  
       AND  @c10DBSID                       <> suser_sid()  
      )  
      begin  
      select @CountSkipPossUsers = @CountSkipPossUsers + 1  
      CONTINUE  
      end  
  
  
   IF (@c10DBStatus & @DBOptSingleUser  > 0)  
      begin  
  
      select    @Int1 = count(*)  
         from   sys.dm_exec_requests  
         where  session_id <> @@spid  
         and    database_id = db_id(@c10DBName)  
  
      IF (@Int1 > 0)  
         begin  
         select @CountSkipPossUsers = @CountSkipPossUsers + 1  
         CONTINUE  
         end  
      end  
  
  
   IF (@c10DBStatus &  
         (  
           @DBOptLoading  
         | @DBOptRecovering  
         | @DBOptSuspect  
         | @DBOptPreRecovery  
         )  
               > 0  
      )  
      begin  
      select @CountSkipPossUsers = @CountSkipPossUsers + 1  
      CONTINUE  
      end  
  
  
   IF (@c10DBStatus &  
         (  
           @DBOptOffline  
         )  
               > 0  
      )  
      begin  
      --select @CountSkipPossUsers = @CountSkipPossUsers + 1  
      CONTINUE  
      end  
  
 IF (has_dbaccess(@c10DBName) <> 1)  
      begin  
   raiserror(15622,-1,-1, @c10DBName)  
      CONTINUE  
      end  
  
  
  
---------------------  Add the User info to holding table.  
 select @exec_stmt = '  
   INSERT    #tb1_UA  
            (  
             DBName  
            ,LoginName  
            ,UserName  
            ,UserOrAlias  
            )  
      select  
             N' + quotename(@c10DBName, '''') + '  
            ,l.name  
            ,u.name  
            ,''User''  
         from  
             ' + quotename(@c10DBName, '[') + '.sys.sysusers u  
            ,sys.server_principals l  
         where  
             u.sid  = l.sid' +  
   case   
   when @LoginNamePattern is null   
   then ''  
   else ' and ( l.name = N' + quotename(@LoginNamePattern , '''') + '  
    or l.name = N' + quotename(@LoginNamePattern , '''') + ')'  
   end  
   +  
'     UNION  
      select  
  
             N' + quotename(@c10DBName, '''') + '  
            ,l.name  
            ,u2.name  
            ,''MemberOf''  
         from  
             ' + quotename(@c10DBName, '[')+ '.sys.database_role_members m  
            ,' + quotename(@c10DBName, '[')+ '.sys.database_principals u1  
            ,' + quotename(@c10DBName, '[')+ '.sys.database_principals u2  
            ,sys.server_principals l  
         where  
             u1.sid = l.sid  
         and m.member_principal_id = u1.principal_id  
   and m.role_principal_id = u2.principal_id' +  
   case   
   when @LoginNamePattern is null  
   then ''  
   else ' and ( l.name = N' + quotename(@LoginNamePattern , '''') + '  
    or l.name = N' + quotename(@LoginNamePattern , '''') + ')'  
   end  
  
   EXECUTE(@exec_stmt)  
  
   end --loop 10  
  
---------------  Populate plain logins work table  ---------------  
  
  
INSERT       #tb2_PlainLogins  
            (  
             LoginName  
			,IsDisabled 
            ,SID  
            ,DefDBName  
            ,DefLangName  
            ,AUser  
            ,ARemote  
            ,sysadmin
            ,securityadmin
            ,serveradmin
            ,setupadmin
            ,processadmin
            ,diskadmin
            ,dbcreator
            ,bulkadmin
            )  
   select  
             sl.loginname  
			,sp.is_disabled
            ,convert(varchar(85), sl.sid)  
            ,sl.dbname  
            ,sl.language  
            ,Null  
            ,Null  
            ,sl.sysadmin
            ,sl.securityadmin
            ,sl.serveradmin
            ,sl.setupadmin
            ,sl.processadmin
            ,sl.diskadmin
            ,sl.dbcreator
            ,sl.bulkadmin
      from  
             master.dbo.syslogins sl join master.sys.server_principals sp on sl.sid=sp.sid
      where  
             @LoginNamePattern is null  
			 or sl.name = @LoginNamePattern  
             or sl.loginname = @LoginNamePattern  
  
  
-- AUser  
  
UPDATE       #tb2_PlainLogins --(1996/08/12)  
      set  
        AUser  = 'yes'  
      from  
             #tb2_PlainLogins  
            ,#tb1_UA             tb1  
      where  
             #tb2_PlainLogins.LoginName     = tb1.LoginName  
      and    #tb2_PlainLogins.AUser        IS Null  
  
  
  
UPDATE       #tb2_PlainLogins  
      set  
             AUser    =  
                  CASE @CountSkipPossUsers  
                     When  0  Then  'NO'  
                     Else           '?'  
                  END  
      where  
             AUser   IS Null  
  
  
-- ARemote  
  
UPDATE       #tb2_PlainLogins  
      set  
             ARemote   = 'YES'  
      from  
             #tb2_PlainLogins  
            ,master.dbo.sysremotelogins   rl  
      where  
             #tb2_PlainLogins.SID = rl.sid  
      and    #tb2_PlainLogins.ARemote                 IS Null  
  
  
  
UPDATE       #tb2_PlainLogins  
      set  
             ARemote  = 'no'  
      where  
             ARemote IS Null  
  
  
  
------------  Optimize widths for plain Logins report  ----------  
  
  
select  
             @charMaxLenLoginName      =  
                  convert ( varchar  
                           ,isnull ( max(datalength(LoginName)) ,9)  
                          )  
            ,@charMaxLenDBName         =  
                  convert ( varchar  
                           , isnull (max(isnull (datalength(DefDBName) ,9)) ,9)  
                          )  
            ,@charMaxLenLangName   =  
                  convert ( varchar  
                           , isnull (max(isnull (datalength(DefLangName) ,11)) ,11)  
                          )  
      from  
             #tb2_PlainLogins  
  
  
  
----------------  Print out plain Logins report  -------------  
  
EXEC(  
'  
set nocount off  
  
  
select  
          ''LoginName''       = substring (LoginName     ,1 ,'  
                                       + @charMaxLenLoginName   + ')  
  
         ,IsDisabled  
         ,''SID''             = convert(varbinary(85), SID)  
  
         ,''DefDBName''       = substring (DefDBName     ,1 ,'  
                                       + @charMaxLenDBName      + ')  
  
         ,''DefLangName''     = substring (DefLangName   ,1 ,'  
                                       + @charMaxLenLangName    + ')  
  
         ,AUser  
         ,ARemote  
         ,sysadmin
         ,securityadmin
         ,serveradmin
         ,setupadmin
         ,processadmin
         ,diskadmin
         ,dbcreator
         ,bulkadmin
   from  
          #tb2_PlainLogins  
   order by  
          LoginName  
  
  
Set nocount on  
'  
)  
  
  
  
------------  Optimize UA report column display widths  -----------  
  
  
select  
             @charMaxLenLoginName   =  
                  convert ( varchar  
                           ,isnull ( max(datalength(LoginName)) ,9)  
                          )  
            ,@charMaxLenDBName      =  
                  convert ( varchar  
                           ,isnull ( max(datalength(DBName)) ,6)  
                          )  
            ,@charMaxLenUserName    =  
                  convert ( varchar  
                           ,isnull ( max(datalength(UserName)) ,8)  
                          )  
      from  
             #tb1_UA  
  
  
  
------------  Print out the UserOrAlias report  ------------  
  
EXEC(  
'  
set nocount off  
  
  
select  
          ''LoginName''    = substring (LoginName  ,1 ,'  
                                       + @charMaxLenLoginName  + ')  

         ,''DBName''       = substring (DBName     ,1 ,'  
                                       + @charMaxLenDBName     + ')  
  
         ,''UserName''     = substring (UserName   ,1 ,'  
                                       + @charMaxLenUserName   + ')  
  
         ,UserOrAlias  
   from  
          #tb1_UA  
   order by  
          1 ,2 ,3  
  
  
Set nocount on  
'  
)  
  
  
-----------------------  Finalization  --------------------  
label_86return:  
  
IF (object_id('#tb2_PlainLogins') IS NOT Null)  
            DROP Table #tb2_PlainLogins  
  
IF (object_id('#tb1_UA') IS NOT Null)  
            DROP Table #tb1_UA  
  
Return @RetCode -- sp_helplogins  


EXEC sp_ms_marksystemobject [sp__helplogins] 
GO


