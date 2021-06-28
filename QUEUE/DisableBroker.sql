select is_broker_enabled, * from sys.databases
ALTER DATABASE [DI_STAT] SET DISABLE_BROKER with rollback immediate

Nonqualified transactions are being rolled back. Estimated rollback completion: 0%.
Nonqualified transactions are being rolled back. Estimated rollback completion: 100%.
Msg 1468, Level 16, State 1, Line 1
The operation cannot be performed on database "Report" because it is involved in a database mirroring session or an availability group. Some operations are not allowed on a database that is participating in a database mirroring session or in an availability group.
Msg 5069, Level 16, State 1, Line 1
ALTER DATABASE statement failed.


ALTER DATABASE [DI_STAT] SET ENABLE_BROKER with rollback immediate


sp_whoisactive 68
sp_who 68
select top 1000 * from DI_STAT.dbo.sysobjects with (readpast) where type = 'U' and name like 'B2%' order by name
select top 1000 * from DI_STAT.dbo.syscomments with (readpast) where id = 1854629650
select top 100 * from DI_STAT.dbo.B2B_POLICY_LOGS
sp_helpdb
--kill 68

create view vw_plain_policies  
as    
SELECT [policyID]        
	,[creationDate]        
	,[InsuredSum]        
	,[Bonus]        
	,[StartDate]        
	,[EndDate]        
	,[LastEditDate]        
	,[programID]        
	,cast([content] as nvarchar(max)) as content        
	,[status]        
	,[Number]        
	,[creatorID]        
	,[lastUser]        
	,[integrationStatus]        
	,[printStatus]        
	,[currency]        
	,[exchangeRate]        
	,[signDate]        
	,[prevNumber]        
	,[InsuranceObject]        
	,cast([results] as nvarchar(max)) as results        
	,[insurant]        
	,cast([rescissionResult] as nvarchar(max)) as rescissionResult        
	,cast([rescissionInterview] as nvarchar(max)) as rescissionInterview        
	,[BackOfficeSystemID]        
	,[notificationID]        
	,[SiebelID]        
	,[AccountNumber]        
	,[SyncDate]        
	,[TSTAMP]    
FROM [DI_STAT].[dbo].[policies]
