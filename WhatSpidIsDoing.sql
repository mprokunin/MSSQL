select @@SERVERNAME, @@VERSION
DBCC FREESYSTEMCACHE ('SQL Plans')
select * from sys.databases
select top 500 db_name(dbid) as 'DB',loginame, * from sys.sysprocesses where loginame <> 'sa' and cmd <> 'AWAITING COMMAND' order by physical_io desc
select top 500 db_name(dbid) as 'DB',loginame, * from sys.sysprocesses where loginame <> 'sa' and cmd <> 'AWAITING COMMAND' order by cpu desc
select top 500 db_name(dbid) as 'DB',loginame, * from sys.sysprocesses where loginame <> 'sa' and cmd <> 'AWAITING COMMAND' order by spid
select top 500 db_name(dbid) as 'DB',loginame, hostname, count(*) as 'Qty' from sys.sysprocesses where loginame <> 'sa' and cmd <> 'AWAITING COMMAND' group by dbid, loginame, hostname order by count(*) desc
select top 500 db_name(dbid) as 'DB',loginame, * from sys.sysprocesses where spid  = 1554

dbcc inputbuffer(284)
(@programID nvarchar(5))SELECT DISTINCT EndDate AS EndDate, status AS status FROM             programs with(nolock)           WHERE programid = @programID
dbcc inputbuffer(856)
SELECT   [t1].[CounterID],   [t1].[Phone],   [t1].[IsCorrect],   [t1].[Client],   [t1].[PolicyNumber],   [t1].[CreatedBy],   [t1].[PartnerID],   [t1].[CreatedDate],   [t1].[ClientType],   [t1].[DivisionID],   [t1].[ProgramID]  FROM   [PhonesCounter] [t1]  
sp_whoisactive

--kill  304
select top 100 logical_reads, * from  sys.dm_exec_sessions  order by 1 desc
select top 100 * from  sys.dm_exec_sessions where login_name = 'rimos_nt_01\mprokunin' order by logical_reads desc
select top 10 * from  sys.dm_exec_sessions where session_id = 83 order by logical_reads desc
select top 500 db_name(dbid) as 'DB',loginame,* from sys.sysprocesses where loginame <> 'sa' and cmd <> 'AWAITING COMMAND' order by spid
select top 500 db_name(dbid) as 'DB', loginame,* from sys.sysprocesses where loginame <> 'sa' and cmd <> 'AWAITING COMMAND' and lastwaittype  like 'CX%' order by spid
select top 500 db_name(dbid) as 'DB', loginame,last_batch,* from sys.sysprocesses where loginame <> 'sa' and cmd <> 'AWAITING COMMAND' order by 3
select top 100 db_name(dbid) as 'DB', loginame,* from sys.sysprocesses where loginame <> 'sa' and hostname like 'DMSK050%'
select top 100 db_name(dbid) as 'DB', loginame,* from sys.sysprocesses where loginame <> 'sa' and program_name like '%824685C5%'
select top 100 db_name(dbid) as 'DB', loginame,* from sys.sysprocesses where loginame <> 'sa' and dbid = DB_ID('RsaStat') 
select top 500 db_name(dbid) as 'DB',loginame, * from sys.sysprocesses where program_name like 'SQLAgent%' order by physical_io desc
select top 500 db_name(dbid) as 'DB',loginame, * from sys.sysprocesses where loginame like 'db_pps%' order by physical_io desc
select top 500 db_name(dbid) as 'DB',loginame, * from sys.sysprocesses where loginame <> 'sa' and dbid=db_id('LigthDemo') and cmd <> 'AWAITING COMMAND' order by physical_io desc

select top 100 req.*  from sys.dm_exec_requests req join sys.dm_exec_connections con on con.session_id = req.session_id join sys.sysprocesses spr on spr.spid = req.session_id 
	where spr.loginame = 'iris-temporary'
	and req.start_time < dateadd (ss, -10, getdate())
sp_who 725

dbcc inputbuffer(467) 
SELECT   [t1].[CounterID],   [t1].[Phone],   [t1].[IsCorrect],   [t1].[Client],   [t1].[PolicyNumber],   [t1].[CreatedBy],   [t1].[PartnerID],   [t1].[CreatedDate],   [t1].[ClientType],   [t1].[DivisionID],   [t1].[ProgramID]  
SELECT   [t1].[CounterID],   [t1].[Phone],   [t1].[IsCorrect],   [t1].[Client],   [t1].[PolicyNumber],   [t1].[CreatedBy],   [t1].[PartnerID],   [t1].[CreatedDate],   [t1].[ClientType],   [t1].[DivisionID],   [t1].[ProgramID]  FROM   [PhonesCounter] [t1]  
FROM   [PhonesCounter] [t1]  
--kill 446
sp_whoisactive
-- (@p1 int)SELECT   [pr].[PermissionRequestUrlsRolesId],   [pr].[PermissionRequestUrlsId],   [pr].[RoleId],   [pr].[Permissions] as [PermissionsInt]  
 -- FROM   [PermissionRequestUrlsRoles_NEW] [pr]  WHERE   [pr].[PermissionRequestUrlsId] = @p1  
select top 100 * from sys.dm_exec_requests where user_id = suser_id('iris-temporary')
select top 100 * from sys.dm_exec_requests where start_time < dateadd (ss, -15, getdate()) and user_id = suser_name('iris-temporary')

SELECT session_id as SPID, command, a.text AS Query, start_time, percent_complete, dateadd(second,estimated_completion_time/1000, getdate()) as estimated_completion_time 
	FROM sys.dm_exec_requests r CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) a WHERE session_id=803 -- r.command in ('BACKUP DATABASE','RESTORE DATABASE')

select top 100 * from sys.dm_exec_connections where net_transport = 'TCP' order by num_reads desc



select top 100 load_factor, * from sys.dm_os_schedulers 

select top 100 db_name(dbid) as 'DB', '"' + loginame + '"',* from sys.sysprocesses where loginame like  'www%'
select 'kill ' + convert(varchar(10), spid) from sys.sysprocesses where loginame like  '%ICABC\ServiceBroker_Rabbit%'
select 'kill ' + convert(varchar(10), spid) from sys.sysprocesses where lastwaittype  like  '%WRITELOG%' and loginame ='iris-temporary'

select 'dbcc inputbuffer(' + convert(varchar(10), spid)  + ')' from sys.sysprocesses where lastwaittype  like  '%WRITELOG%' and loginame ='iris-temporary'
select top 100 * from sys.dm_io_virtual_file_stats(DB_ID('IrisInsuranceDB'),NULL)
select top 100 * from sys.dm_io_pending_io_requests 

select @@SERVERNAME
sp_helpdb
exec sp_spaceused 'MANAGEMENT$G_L Entry'

select top 500 db_name(dbid) as 'DB',loginame, * from sys.sysprocesses where cmd like '%BACKUP%' 
exec sp_who [RIMOS_NT_01\backoper]
sp_who [RIMOS_NT_01\mprokunin]
sp_who 327
sp_whoisactive
dbcc inputbuffer(949)
exec sp__dbinfo 1
xp_fixeddrives

exec [Intraservice4]..sp_spaceused [EventLog]              -- 3398440             
exec [Intraservice4]..sp_spaceused [Notification]          -- 5409429             
exec [Intraservice4]..sp_spaceused [NotificationAttachment]-- 84             
exec [Intraservice4]..sp_spaceused [ImportMailMessageFile] -- 2750817             
select * from sys.server_triggers
select * from master..syslogins where loginname = 'www'
select top 100 db_name(dbid) as 'DB', loginame,* from sys.sysprocesses where cmd <> 'AWAITING COMMAND'
select top 100 db_name(dbid) as 'DB', loginame,* from sys.sysprocesses where spid in(676, 436)

select top 100 db_name(dbid) as 'DB', loginame,* from sys.sysprocesses where program_name like  'SQLAgent%' order by last_batch 
select top 100 db_name(dbid) as 'DB', loginame,* from sys.sysprocesses where (1=1) /* and hostname like  'REN-MSKCLNODE01%' */ order by last_batch 
--kill 355
sp_who 781

sp_lock 663
select object_name(905574810, 15) -- IdentityOwnerTable
select object_name(697574069, 15) -- LockOwnersTable
sp_helpdb
sp_who 327
select * from sys.sysprocesses where spid = 663


dbcc inputbuffer(355) -- IrisInsuranceDB.System.Activities.DurableInstancing.CreateLockOwner;1


dbcc inputbuffer(663) -- IrisInsuranceDB.System.Activities.DurableInstancing.CreateLockOwner;1
dbcc inputbuffer(442) -- sys.sp_releaseapplock;1
dbcc inputbuffer(182) -- sys.sp_getapplock;1
dbcc inputbuffer(327) -- sys.sp_getapplock;1

select top 1000 @@servername as 'Server', db_name(dbid) as 'DB', spid, blocked, loginame,* from sys.sysprocesses where blocked > 0 order by 5, 4
select top 300 blocked, count(spid) as 'Cnt' from sys.sysprocesses where blocked > 0 	group by blocked	order by 2 desc
select top 300 blocked, * from sys.sysprocesses where spid = 922


sp_whoisactive
sp_lock 688
sp_who [b2b-integr]
sp_who 922

dbcc inputbuffer(922)
--KEY: 14:72057594045857792 (7740a82ae648) 
sp_helpdb -- 14 = Integr
sp_spaceused '[dbo].[DwhJob]'
select top 100 * from [dbo].[DwhJob]
go
USE Integr;
GO
SELECT 
    sc.name as schema_name, 
    so.name as object_name, 
    si.name as index_name
FROM sys.partitions AS p
JOIN sys.objects as so on 
    p.object_id=so.object_id
JOIN sys.indexes as si on 
    p.index_id=si.index_id and 
    p.object_id=si.object_id
JOIN sys.schemas AS sc on 
    so.schema_id=sc.schema_id
WHERE hobt_id = 72057594045857792;
GO
SELECT
    *
FROM DwhJob (NOLOCK)
WHERE %%lockres%% = '(7740a82ae648)';
GO
s
----------------------

SELECT open_tran, * FROM master.sys.sysprocesses where open_tran > 0 order by 1 desc


select * from msdb..sysjobs where job_id = 0x514F910DCEBAB64E91F65BC21DC62042 
USE [master]
GO
dbcc inputbuffer(106)
sp_who  sfa 

select top 200 * from sysobjects with (readpast) where type = 'U' and name like 'B2B%'
select top 100 * from B2B_QUOTATION with (readpast) 
select top 100 * from B2B_INSURANCE_OBJECT

select object_name(1972202076)
dbcc inputbuffer(118)

exec master..sp_help sp_whoisactive
sp_whoisactive @filter = 'sfa', @filter_type = 'login'
sp_whoisactive @help = 1

--To enable Service Broker:
ALTER DATABASE [Database_name] SET ENABLE_BROKER;
--To disable Service Broker:
ALTER DATABASE [DI_STAT] SET DISABLE_BROKER;

SELECT is_broker_enabled, name FROM sys.databases WHERE name = 'DI_STAT';


--kill 64
select @@servername, @@VERSION
sp_helpdb mif

EXEC sp_configure 'network packet size'


sp_who [RIMOS_NT_01\mprokunin] --401
sp_who [dwh_reader] --401

exec sp__dbinfo 1
exec xp_fixeddrives
sp_who db_pps
sp_whoisactive 106
sp_whoisactive 39
sp_whoisactive 40


dbcc inputbuffer(69)


select * from master..sysprocesses where spid in (149, 47)
select top 100 * from sys.dm_exec_query_stats

dbcc inputbuffer(71) --(@P1 numeric(10),@P2 varbinary(16),@P3 numeric(10),@P4 numeric(10),@P5 numeric(10))INSERT INTO #tt32 WITH(TABLOCK) (_Q_001_F_000RRef, _Q_001_F_001RRef, _Q_001_F_002RRef, _Q_001_F_003RRef, _Q_001_F_004, _Q_001_F_005, _Q_001_F_006RRef, _Q_001_F_007, _Q_001_F_008, _Q_001_F_009, _Q_001_F_010RRef, _Q_001_F_011, _Q_001_F_012RRef) SELECT T1._Q_000_F_001RRef, T1._Q_000_F_000RRef, T1._Q_000_F_002RRef, T1._Q_000_F_003RRef, T1._Q_000_F_004, T1._Q_000_F_005, T1._Q_000_F_006RRef, T1._Q_000_F_007, T2._Fld43944, T2._Fld44055, T1._Q_000_F_008RRef, CASE WHEN (T5._IDRRef IS NULL) THEN 0x01 ELSE 0x00 END, T3._Fld43734RRef FROM #tt31 T1 WITH(NOLOCK) INNER JOIN dbo._InfoRg43942 T2 ON (T1._Q_000_F_007 = T2._Fld43943) LEFT OUTER JOIN dbo._InfoRg43726 T3 LEFT OUTER JOIN dbo._Reference464 T4 ON (T3._Fld43729RRef = T4._IDRRef) AND (T4._Fld1513 = @P1) ON ((T1._Q_000_F_000RRef = T3._Fld43728RRef) AND (T4._Fld9340RRef = @P2)) AND (T3._Fld1513 = @P3) LEFT OUTER JOIN dbo._Document43643 T5 ON (T3._Fld43728RRef = T5._IDRRef) AND (T5._Fld1513 = @P4) WHERE (T2._Fld1513 = @P5)
--kill 69

sp_lock 1135
dbcc opentran()
exec msdb..sp__dbinfo 1
exec xp_fixeddrives
sp_who 344
dbcc inputbuffer(37) --    (@P1 varbinary(16))SELECT T1._Period, T1._RecorderRRef, T1._LineNo, T1._Active, T1._Fld11630RRef, T1._Fld11631RRef, T1._Fld11632RRef, T1._Fld11633RRef, T1._Fld11634RRef, T1._Fld11635RRef, T1._Fld11636RRef, T1._Fld11637, T1._Fld11638, T1._Fld11639 FROM dbo._AccumRg11629 T1 WHERE T1._RecorderRRef = @P1 ORDER BY T1._LineNo
dbcc inputbuffer(69) --    EXECUTE [dbo].[IndexOptimize]  @Databases = 'ABCBase',  @TimeLimit=100500,  @LogToTable = 'Y'
dbcc inputbuffer(74) --     (@P1 varbinary(16),@P2 numeric(10),@P3 numeric(10),@P4 varbinary(16),@P5 varbinary(16),@P6 varbinary(16),@P7 varbinary(16),@P8 varbinary(16),@P9 varbinary(16),@P10 varbinary(16),@P11 varbinary(16),@P12 varbinary(16),@P13 varbinary(16),@P14 varbinary(16),@P15 varbinary(16),@P16 datetime2(3),@P17 numeric(10),@P18 numeric(10),@P19 numeric(10),@P20 numeric(10),@P21 numeric(10),@P22 numeric(10),@P23 numeric(10),@P24 datetime2(3),@P25 datetime2(3),@P26 numeric(10),@P27 numeric(10),@P28 varbinary(16),@P29 varbinary(16),@P30 varbinary(16),@P31 varbinary(16),@P32 varbinary(16),@P33 varbinary(16),@P34 varbinary(16),@P35 varbinary(16),@P36 varbinary(16),@P37 varbinary(16),@P38 varbinary(16),@P39 varbinary(16),@P40 varbinary(16),@P41 varbinary(16),@P42 varbinary(16),@P43 datetime2(3),@P44 datetime2(3),@P45 numeric(10),@P46 numeric(10),@P47 numeric(10),@P48 datetime2(3),@P49 datetime2(3),@P50 numeric(10),@P51 numeric(10),@P52 varbinary(16),@P53 varbinary(16),@P54 varbinary(16),@P55 varbinary(16),@P56 varbinary(16),@P57 varbinary(16),@P58 varbinary(16),@P59 varbinary(16),@P60 varbinary(16),@P61 varbinary(16),@P62 varbinary(16),@P63 varbinary(16),@P64 varbinary(16),@P65 varbinary(16),@P66 varbinary(16),@P67 datetime2(3),@P68 datetime2(3),@P69 numeric(10),@P70 numeric(10))INSERT INTO #tt3 WITH(TABLOCK) (_Q_000_F_000RRef, _Q_000_F_001_TYPE, _Q_000_F_001_RTRef, _Q_000_F_001_RRRef, _Q_000_F_002RRef, _Q_000_F_003_TYPE, _Q_000_F_003_RTRef, _Q_000_F_003_RRRef, _Q_000_F_004RRef, _Q_000_F_005, _Q_000_F_006, _Q_000_F_007, _Q_000_F_008, _Q_000_F_009, _Q_000_F_010, _Q_000_F_011, _Q_000_F_012, _Q_000_F_013, _Q_000_F_014, _Q_000_F_015, _Q_000_F_016, _Q_000_F_017) SELECT T1.Fld28629RRef, CASE WHEN T1.Fld28631_TYPE IS NULL THEN 0x08 ELSE T1.Fld28631_TYPE END, CASE WHEN T1.Fld28631_TYPE IS NULL THEN 0x000072CD ELSE T1.Fld28631_RTRef END, CASE WHEN T1.Fld28631_TYPE IS NULL THEN @P1 ELSE T1.Fld28631_RRRef END, T1.AccountRRef, T1.Value1_TYPE, T1.Value1_RTRef, T1.Value1_RRRef, T1.Fld28632RRef, T12._Fld28702, T1.Fld28633Balance_, T1.Fld28633BalanceDt_, T1.Fld28633BalanceCt_, T1.Fld28636BalanceDt_, T1.Fld28636Balance_, T1.Fld28636BalanceCt_, T1.Fld28637Balance_, T1.Fld28637BalanceDt_, T1.Fld28637BalanceCt_, T1.Fld28638Balance_, T1.Fld28638BalanceDt_, T1.Fld28638BalanceCt_ FROM (SELECT T2.Fld28631_TYPE AS Fld28631_TYPE, T2.Fld28631_RTRef AS Fld28631_RTRef, T2.Fld28631_RRRef AS Fld28631_RRRef, T2.AccountRRef AS AccountRRef, T2.Value1_TYPE AS Value1_TYPE, T2.Value1_RTRef AS Value1_RTRef, T2.Value1_RRRef AS Value1_RRRef, T2.Fld28629RRef AS Fld28629RRef, T2.Fld28632RRef AS Fld28632RRef, CASE WHEN CAST(SUM(T2.Fld28633Balance_) AS NUMERIC(27, 2)) IS NULL THEN 0.0 ELSE CAST(SUM(T2.Fld28633Balance_) AS NUMERIC(27, 2)) END AS Fld28633Balance_, CASE WHEN CAST(SUM(T2.Fld28633Balance_) AS NUMERIC(27, 2)) IS NULL THEN 0.0 WHEN MAX(T11._Kind) = 0.0 OR MAX(T11._Kind) = 2.0 AND CAST(SUM(T2.Fld28633Balance_) AS NUMERIC(27, 2)) > 0.0 THEN CAST(SUM(T2.Fld28633Balance_) AS NUMERIC(27, 2)) ELSE 0.0 END AS Fld28633BalanceDt_, CASE WHEN CAST(SUM(T2.Fld28633Balance_) AS NUMERIC(27, 2)) IS NULL THEN 0.0 WHEN MAX(T11._Kind) = 1.0 OR MAX(T11._Kind) = 2.0 AND CAST(SUM(T2.Fld28633Balance_) AS NUMERIC(27, 2)) < 0.0 THEN -CAST(SUM(T2.Fld28633Balance_) AS NUMERIC(27, 2)) ELSE 0.0 END AS Fld28633BalanceCt_, CASE WHEN CAST(SUM(T2.Fld28637Balance_) AS NUMERIC(27, 2)) IS NULL THEN 0.0 ELSE CAST(SUM(T2.Fld28637Balance_) AS NUMERIC(27, 2)) END AS Fld28637Balance_, CASE WHEN CAST(SUM(T2.Fld28637Balance_) AS NUMERIC(27, 2)) IS NULL THEN 0.0 WHEN MAX(T11._Kind) = 0.0 OR MAX(T11._Kind) = 2.0 AND CAST(SUM(T2.Fld28637Balance_) AS NUMERIC(27, 2)) > 0.0 THEN CAST(SUM(T2.Fld28637Balance_) AS NUMERIC(27, 2)) ELSE 0.0 END AS Fld28637BalanceDt_, CASE WHEN CAST(SUM(T2.Fld28637Balance_) AS NUMERIC(27, 2)) IS NULL THEN 0.0 WHEN MAX(T11._Kind) = 1.0 OR MAX(T11._Kind) = 2.0 AND CAST(SUM(T2.Fld28637Balance_) AS NUMERIC(27, 2)) < 0.0 THEN -CAST(SUM(T2.Fld28637Balance_) AS NUMERIC(27, 2)) ELSE 0.0 END AS Fld28637BalanceCt
dbcc inputbuffer(57) --     (@P1 varbinary(16),@P2 numeric(10),@P3 numeric(10),@P4 varbinary(16),@P5 varbinary(16),@P6 varbinary(16),@P7 varbinary(16),@P8 varbinary(16),@P9 varbinary(16),@P10 varbinary(16),@P11 varbinary(16),@P12 varbinary(16),@P13 varbinary(16),@P14 varbinary(16),@P15 varbinary(16),@P16 datetime2(3),@P17 numeric(10),@P18 numeric(10),@P19 numeric(10),@P20 numeric(10),@P21 numeric(10),@P22 numeric(10),@P23 numeric(10),@P24 datetime2(3),@P25 datetime2(3),@P26 numeric(10),@P27 numeric(10),@P28 varbinary(16),@P29 varbinary(16),@P30 varbinary(16),@P31 varbinary(16),@P32 varbinary(16),@P33 varbinary(16),@P34 varbinary(16),@P35 varbinary(16),@P36 varbinary(16),@P37 varbinary(16),@P38 varbinary(16),@P39 varbinary(16),@P40 varbinary(16),@P41 varbinary(16),@P42 varbinary(16),@P43 datetime2(3),@P44 datetime2(3),@P45 numeric(10),@P46 numeric(10),@P47 numeric(10),@P48 datetime2(3),@P49 datetime2(3),@P50 numeric(10),@P51 numeric(10),@P52 varbinary(16),@P53 varbinary(16),@P54 varbinary(16),@P55 varbinary(16),@P56 varbinary(16),@P57 varbinary(16),@P58 varbinary(16),@P59 varbinary(16),@P60 varbinary(16),@P61 varbinary(16),@P62 varbinary(16),@P63 varbinary(16),@P64 varbinary(16),@P65 varbinary(16),@P66 varbinary(16),@P67 datetime2(3),@P68 datetime2(3),@P69 numeric(10),@P70 numeric(10))INSERT INTO #tt3 WITH(TABLOCK) (_Q_000_F_000RRef, _Q_000_F_001_TYPE, _Q_000_F_001_RTRef, _Q_000_F_001_RRRef, _Q_000_F_002RRef, _Q_000_F_003_TYPE, _Q_000_F_003_RTRef, _Q_000_F_003_RRRef, _Q_000_F_004RRef, _Q_000_F_005, _Q_000_F_006, _Q_000_F_007, _Q_000_F_008, _Q_000_F_009, _Q_000_F_010, _Q_000_F_011, _Q_000_F_012, _Q_000_F_013, _Q_000_F_014, _Q_000_F_015, _Q_000_F_016, _Q_000_F_017) SELECT T1.Fld28629RRef, CASE WHEN T1.Fld28631_TYPE IS NULL THEN 0x08 ELSE T1.Fld28631_TYPE END, CASE WHEN T1.Fld28631_TYPE IS NULL THEN 0x000072CD ELSE T1.Fld28631_RTRef END, CASE WHEN T1.Fld28631_TYPE IS NULL THEN @P1 ELSE T1.Fld28631_RRRef END, T1.AccountRRef, T1.Value1_TYPE, T1.Value1_RTRef, T1.Value1_RRRef, T1.Fld28632RRef, T12._Fld28702, T1.Fld28633Balance_, T1.Fld28633BalanceDt_, T1.Fld28633BalanceCt_, T1.Fld28636BalanceDt_, T1.Fld28636Balance_, T1.Fld28636BalanceCt_, T1.Fld28637Balance_, T1.Fld28637BalanceDt_, T1.Fld28637BalanceCt_, T1.Fld28638Balance_, T1.Fld28638BalanceDt_, T1.Fld28638BalanceCt_ FROM (SELECT T2.Fld28631_TYPE AS Fld28631_TYPE, T2.Fld28631_RTRef AS Fld28631_RTRef, T2.Fld28631_RRRef AS Fld28631_RRRef, T2.AccountRRef AS AccountRRef, T2.Value1_TYPE AS Value1_TYPE, T2.Value1_RTRef AS Value1_RTRef, T2.Value1_RRRef AS Value1_RRRef, T2.Fld28629RRef AS Fld28629RRef, T2.Fld28632RRef AS Fld28632RRef, CASE WHEN CAST(SUM(T2.Fld28633Balance_) AS NUMERIC(27, 2)) IS NULL THEN 0.0 ELSE CAST(SUM(T2.Fld28633Balance_) AS NUMERIC(27, 2)) END AS Fld28633Balance_, CASE WHEN CAST(SUM(T2.Fld28633Balance_) AS NUMERIC(27, 2)) IS NULL THEN 0.0 WHEN MAX(T11._Kind) = 0.0 OR MAX(T11._Kind) = 2.0 AND CAST(SUM(T2.Fld28633Balance_) AS NUMERIC(27, 2)) > 0.0 THEN CAST(SUM(T2.Fld28633Balance_) AS NUMERIC(27, 2)) ELSE 0.0 END AS Fld28633BalanceDt_, CASE WHEN CAST(SUM(T2.Fld28633Balance_) AS NUMERIC(27, 2)) IS NULL THEN 0.0 WHEN MAX(T11._Kind) = 1.0 OR MAX(T11._Kind) = 2.0 AND CAST(SUM(T2.Fld28633Balance_) AS NUMERIC(27, 2)) < 0.0 THEN -CAST(SUM(T2.Fld28633Balance_) AS NUMERIC(27, 2)) ELSE 0.0 END AS Fld28633BalanceCt_, CASE WHEN CAST(SUM(T2.Fld28637Balance_) AS NUMERIC(27, 2)) IS NULL THEN 0.0 ELSE CAST(SUM(T2.Fld28637Balance_) AS NUMERIC(27, 2)) END AS Fld28637Balance_, CASE WHEN CAST(SUM(T2.Fld28637Balance_) AS NUMERIC(27, 2)) IS NULL THEN 0.0 WHEN MAX(T11._Kind) = 0.0 OR MAX(T11._Kind) = 2.0 AND CAST(SUM(T2.Fld28637Balance_) AS NUMERIC(27, 2)) > 0.0 THEN CAST(SUM(T2.Fld28637Balance_) AS NUMERIC(27, 2)) ELSE 0.0 END AS Fld28637BalanceDt_, CASE WHEN CAST(SUM(T2.Fld28637Balance_) AS NUMERIC(27, 2)) IS NULL THEN 0.0 WHEN MAX(T11._Kind) = 1.0 OR MAX(T11._Kind) = 2.0 AND CAST(SUM(T2.Fld28637Balance_) AS NUMERIC(27, 2)) < 0.0 THEN -CAST(SUM(T2.Fld28637Balance_) AS NUMERIC(27, 2)) ELSE 0.0 END AS Fld28637BalanceCt
							
dbcc inputbuffer(55) -- exec [dbo].[fill_ua_for_dwh_archive] null, null;
dbcc inputbuffer(60) 
select @@servername, @@VERSION
select object_name(1443000788, 11)
--SQLAgent - TSQL JobStep (Job 0x20FB4EC9E6C0FD4F86507056B723D6F3 : Step 1)                                                       
sp_whoisactive 344
sp_who [rimos_nt_01\mprokunin]

                                                                                                                                                              
select * from msdb..sysjobs	a where a.job_id in (0xBDA0BE29889BD345B7167D0C5139F265) -- ADM.SendLongLockInfo
select * from msdb..sysjobsteps	a where a.job_id in (0x00EC07B17FCDEE4D98F19428B66A8B1C) -- exec dbo.DWH_REFRESH_POLICIES
select * from msdb..sysjobs	a where a.job_id ='7DA8FF29-46FD-4117-9242-13E64B43EE43'
SQLAgent - TSQL JobStep (Job 0x9C897A8A9457C5428E6915ACCF830CE6 : Step 1)                                                       
-------------- SQL Text
DECLARE @sqltext VARBINARY(1024)
SELECT @sqltext = sql_handle FROM sys.sysprocesses WHERE spid = 454
SELECT TEXT FROM sys.dm_exec_sql_text(@sqltext)

select top 100 req.*  from sys.dm_exec_requests req join sys.dm_exec_connections con on con.session_id = req.session_id join sys.sysprocesses spr on spr.spid = req.session_id 
	where spr.loginame = 'iris-temporary'
	and req.start_time < dateadd (ss, -10, getdate())

sp_helpindex [User]


sp_spacesued User
SELECT EQT.text, ER.*
FROM sys.dm_exec_requests AS ER
--   CROSS APPLY sys.dm_exec_query_plan(ER.plan_handle) AS EQP
   CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS EQT
WHERE EQT.text like '%FROM	[PhonesCounter] [t1]%'

--DB	loginame	spid	kpid	blocked	waittype	waittime	lastwaittype	waitresource	dbid	uid	cpu	physical_io	memusage	login_time	last_batch	ecid	open_tran	status	sid	hostname	program_name	hostprocess	cmd	nt_domain	nt_username	net_address	net_library	loginame	context_info	sql_handle	stmt_start	stmt_end	request_id
--AUTO	db_pps                                                                                                                          	718	25728	0	0x0063	2	ASYNC_NETWORK_IO                	                                                                                                                                                                                                                                                                	5	131	2891	221549	6	2020-03-17 13:39:20.283	2020-03-17 13:39:20.283	0	0	suspended                     	0xABACE0B91B36E746B22E82EEEDC7722F00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000	REN-MSKWEBSVC01                                                                                                                 	.Net SqlClient Data Provider                                                                                                    	76024     	SELECT          	                                                                                                                                	                                                                                                                                	7FF08F5554D6	TCP/IP      	db_pps                                                                                                                          	0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000	0x01000500EEFEBC322014BBADD202000000000000	0	506	2--SELECT   [t1].[CounterID],   [t1].[Phone],   [t1].[IsCorrect],   [t1].[Client],   [t1].[PolicyNumber],   [t1].[CreatedBy],   [t1].[PartnerID],   [t1].[CreatedDate],   [t1].[ClientType],   [t1].[DivisionID],   [t1].[ProgramID]  FROM   [PhonesCounter] [t1]  


sp_whoisactive
sp_who  [rimos_nt_01\kotovRu]

-------------- Plan
SELECT EQP.query_plan, ER.*
FROM sys.dm_exec_requests AS ER
   CROSS APPLY sys.dm_exec_query_plan(ER.plan_handle) AS EQP
WHERE ER.session_id = 1201



-- Sql text
DECLARE @Handle binary(20)
SELECT @Handle = sql_handle FROM sysprocesses WHERE spid = 1201
SELECT * FROM ::fn_get_sql(@Handle)

-------------- Cached SQL text
SELECT t.[text]
FROM sys.dm_exec_cached_plans AS p
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS t
WHERE t.[text] LIKE N'%mware4_set_RequireInstruction_b2m%';

--(@ownerId1 bigint,@Value2 int)SELECT   [t1].[Id],   [t1].[Name],   [t1].[Comment] as [Comment1],   [t1].[DefaultValue],   [t1].[OrderIndex],   [t1].[Alias],   [a].[AttributeId],   [a].[Value] as [Value1],   [a].[Id] as [Id1],   [a].[OwnerId],   [a].[OwnerType],   [a].[EndDate]  FROM   [AttributeValues] [a] WITH (NOLOCK)    INNER JOIN [Attributes] [t1] ON [a].[AttributeId] = [t1].[Id]  WHERE   [a].[OwnerId] = @ownerId1 AND [a].[OwnerType] = @Value2  

SELECT top 100 t.[text], s.last_execution_time
FROM sys.dm_exec_cached_plans AS p
INNER JOIN sys.dm_exec_query_stats AS s
   ON p.plan_handle = s.plan_handle
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS t
WHERE t.[text] LIKE N'%mware4_set_RequireInstruction_b2m%'
ORDER BY s.last_execution_time DESC;

sp_who [rimos_nt_01\backoper]
sp_who [rimos_nt_01\mprokunin]
sp_who 82
dbcc inputbuffer(82)
--select AGR_PURPOSE_CODE,POLICY_NUMBER,AGR_BEGIN_DATE,AGR_END_DATE,ENTRY_DATE,ENTRY_RUB,ENTRY_COM_RUB,ENTRY_COMMENT,AGR_CANCEL_DATE,AGR_PURPOSE_NAME,AGR_RNP_RUB,AGR_BRANCH_NAME,AGR_DIVISION_NAME,REPORT_DATE,ACCOUNTING_GROUP_NAME,REINS_BORDERO_NAME,REINS_AGR_TYPE,REINS_BROKER_NAME,REINS_REINSURER_NAME,REINS_REINSURER_TYPE,AGR_CANCEL_SIGN,REINS_NOTE,REINS_RECOV_PREM_SIGN,REINS_OBLIG_BEGIN_DATE,REINS_OBLIG_END_DATE,SECTION,REINS_AGR_KIND,REINS_PERIODE_NAME,ADDENDUM,AGR_ADD_DATE,AGR_UPR_RUB_FIX,AGR_DAC_RUB_FIX from dwh_archive.dbo.JOURN_INC_REINS_AGR_R_2020_05M (nolock) where ENTRY_DATE between '2018-01-01' and '2020-05-31'

-- Estimate completion
SELECT R.session_id, 
R.percent_complete, R.total_elapsed_time/1000 AS elapsed_secs, R.wait_type,R.wait_time,R.last_wait_type,
DATEADD(s,100/((R.percent_complete)/ (R.total_elapsed_time/1000)), R.start_time) estim_completion_time,
ST.text, SUBSTRING(ST.text, R.statement_start_offset / 2, 
 (
 CASE WHEN R.statement_end_offset = -1 THEN DATALENGTH(ST.text)
 ELSE R.statement_end_offset
 END - R.statement_start_offset 
 ) / 2
) AS statement_executing
FROM sys.dm_exec_requests R
CROSS APPLY sys.dm_exec_sql_text(R.sql_handle) ST
WHERE  R.percent_complete > 0
--R.command = 'KILLED/ROLLBACK'
--AND R.session_id <> @@spid
--AND R.session_id = 57
AND R.session_id <> @@spid
OPTION(RECOMPILE);


exec msdb..sp__Dbinfo 1


select  T.text, R.Status, R.Command, DatabaseName = db_name(R.database_id)
        , R.cpu_time, R.total_elapsed_time, R.percent_complete
from    sys.dm_exec_requests R
        cross apply sys.dm_exec_sql_text(R.sql_handle) T
sp_who '57'
select R.percent_complete,R.logical_reads, R.writes, * from sys.dm_exec_requests R where session_id = 57


--- What is running
SELECT r.session_id, 
s.program_name, 
s.login_name, 
r.start_time, 
r.status, 
r.command, 
Object_name(sqltxt.objectid, sqltxt.dbid) AS ObjectName, 
Substring(sqltxt.text, ( r.statement_start_offset / 2 ) + 1, ( ( 
CASE r.statement_end_offset 
WHEN -1 THEN 
datalength(sqltxt.text) 
ELSE r.statement_end_offset 
END 
- r.statement_start_offset ) / 2 ) + 1) AS active_statement,
r.percent_complete, 
Db_name(r.database_id) AS DatabaseName, 
r.blocking_session_id, 
r.wait_time, 
r.wait_type, 
r.wait_resource, 
r.open_transaction_count, 
r.cpu_time,-- in milli sec 
r.reads, 
r.writes, 
r.logical_reads, 
r.row_count, 
r.prev_error, 
r.granted_query_memory, 
Cast(sqlplan.query_plan AS XML) AS QueryPlan, 
CASE r.transaction_isolation_level 
WHEN 0 THEN 'Unspecified' 
WHEN 1 THEN 'ReadUncomitted' 
WHEN 2 THEN 'ReadCommitted' 
WHEN 3 THEN 'Repeatable' 
WHEN 4 THEN 'Serializable' 
WHEN 5 THEN 'Snapshot' 
END AS Issolation_Level, 
r.sql_handle, 
r.plan_handle 
FROM sys.dm_exec_requests r WITH (nolock) 
INNER JOIN sys.dm_exec_sessions s WITH (nolock) 
ON r.session_id = s.session_id 
CROSS apply sys.Dm_exec_sql_text(r.sql_handle) sqltxt 
CROSS apply 
sys.Dm_exec_text_query_plan(r.plan_handle, r.statement_start_offset, r.statement_end_offset) sqlplan
WHERE r.status <> 'background' 
ORDER BY r.session_id 
go 



SELECT sqltext.TEXT,req.session_id,req.status,req.command,req.cpu_time,req.total_elapsed_time, req.logical_reads
FROM sys.dm_exec_requests req
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext
order by logical_reads desc

select * from master..syslogins where name like '%bobr%'
select * from sys.dm_exec_connections where session_id in (62, 399)
select * from sys.dm_exec_connections where connect_time < '2019-05-30'
select * from sys.dm_exec_requests
select * from sys.dm_exec_sessions
SELECT * FROM sys.dm_server_services;
select * from sys.dm_db_task_space_usage 
select * from msdb..sysjobs where name like 'service%'

select * from sys.dm_os_memory_clerks 
select * from sys.dm_exec_query_resource_semaphores

exec sp_MSforeachdb 'dbcc opentran()'
dbcc opentran(ABCBase)

sp_whoisactive 887


exec ABCBase_CDS..sp_help 'RISKWATCH.GetCounterpartyLimitData'

sp_who2
select @@servername, @@spid
sp_helpdb

select suser_id('Istomina')
sp_who [ICABC\Prokunin]
sp_lock 564
--SQLAgent - TSQL JobStep (Job 0x00EC07B17FCDEE4D98F19428B66A8B1C : Step 1)
select * from msdb..sysjobs where job_id=0x00EC07B17FCDEE4D98F19428B66A8B1C -- DWH__IMPORT_POLICIES_AND_PARSING__DI


select top 100 R.percent_complete,* FROM sys.dm_exec_requests R where R.session_id=71
select @@SERVERNAME

select * from [dbo].[vw_dba_procmon2]
sp_whoisactive 835
sp_helpdb tempdb



--- system processes 
SELECT  s.session_id, r.command, r.status,  
r.wait_type, r.scheduler_id, w.worker_address,  
w.is_preemptive, w.state, t.task_state,  
t.session_id, t.exec_context_id, t.request_id  
FROM sys.dm_exec_sessions AS s  
INNER JOIN sys.dm_exec_requests AS r  
ON s.session_id = r.session_id  
INNER JOIN sys.dm_os_tasks AS t  
ON r.task_address = t.task_address  
INNER JOIN sys.dm_os_workers AS w  
ON t.worker_address = w.worker_address  
WHERE s.is_user_process = 0;  


select SERVERPROPERTY('EngineEdition') --IN (3,5,8)

select @@version
select distinct(databaseName) from [master].[dbo].[CommandLog]


select @@SERVERNAME


select
--top 1
  nt_username,
  nt_domain,
  sid,
  net_transport,
  client_net_address,
  connect_time, 
  hostname,
  program_name
from master.sys.dm_exec_connections  ec
inner join master.dbo.sysprocesses sp 
  on sp.spid = ec.session_id
--where sp.spid = @@spid
order by client_net_address



SELECT   *,wait_time_ms/waiting_tasks_count AS 'Avg Wait in ms'
FROM
   sys.dm_os_wait_stats 
WHERE
   waiting_tasks_count > 0
ORDER BY
   wait_time_ms DESC


 dbcc inputbuffer (835)

 sp_helpdb
sp_helplogins Porutchikov1

use P_HRM3
exec sp_spaceused _AccRG28628
sp_spaceused _AccRgED28667

select top 100 * from master..CommandLog where DatabaseName='P_HRM3' 
and ObjectName='_AccRG28628' 
order by StartTime desc

EXECUTE [dbo].[IndexOptimize]
@Databases = 'P_HRM3, P_HRM3, P_HRN',
@TimeLimit = 10500,
@LogToTable = 'Y'
--, @Execute = 'N'






exec msdb..sp__dbinfo 1

sp_helptext sp_whoisactive

sp_cycle_errorlog




use Transitional

sp_help  '[dbo].[Receipts]'
sp_spaceused '[dbo].[Receipts]'
sp_helpindex '[dbo].[Receipts]'

sp_help
sp_who 1820
select * from sys.sysprocesses where dbid = db_id('Transitional')
create index ADM_Receipts_idx1 on [dbo].[Receipts] ([TransactionId], [Operation]) with (online = on)


select top 300 [TransactionId], [Operation],* from [dbo].[Receipts] 
