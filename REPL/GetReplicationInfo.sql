USE distribution 
GO 
exec distribution..sp_replmonitorhelppublisher
-- General Info, Latency
exec distribution..sp_replmonitorhelppublication


exec distribution..sp_replmonitorhelpsubscription @publication_type=0

-- Check errors
select top 100 * from distribution.dbo.msrepl_errors (nolock) order by time desc
--where id = 0
--The row was not found at the Subscriber when applying the replicated DELETE command for Table '[dbo].[Dividend]' with Primary Key(s): [DividendID] = 39788

SELECT * FROM dbo.MSpublisher_databases
--publisher_id	publisher_db	id	publisher_engine_edition
--1				ABCBase		1	30
--4	`			mif				6	30


SELECT * FROM dbo.MSpublications  --where publisher_db = 'Test_1112'
--publisher_id	publisher_db	publication		publication_id	publication_type	thirdparty_flag	independent_agent	immediate_sync	allow_push	allow_pull	allow_anonymous	description	vendor_name	retention	sync_method	allow_subscription_copy	thirdparty_options	allow_queued_tran	options	retention_period_unit	allow_initialize_from_backup	min_autonosync_lsn
--1				ABCBase		ABCBase_Pub	1				0					0				1					0	1	1	0	Transactional publication of database 'ABCBase' from Publisher 'SQL105\AB'.	Microsoft SQL Server	0	3	0	NULL	0	0	0	1	0x003DADBB0023812B0024
--1				ABCBase		PSM_Pub			2				0					0				1					0	1	1	0	Transactional publication of  'ABCBase' for PSM from Publisher 'SQL105\AB'.	Microsoft SQL Server	0	3	0	NULL	0	0	0	1	0x003DACF5005E283C0002
--4				mif				mif_Pub			5				0					0				1					0	1	1	0	Transactional publication of database 'mif' from Publisher 'SQL205\MIF'.	Microsoft SQL Server	0	3	0	NULL	0	0	0	0	NULL

SELECT top 100 * FROM dbo.MSlogreader_agents
--id	name					publisher_id	publisher_db	publication	local_job	job_id								profile_id	publisher_security_mode	publisher_login	publisher_password	job_step_uid
--6		SQL105\AB-ABCBase-6	1				ABCBase		ALL			1			0xF5C27A9268229948B1E086255272E79E	17			1						
--7		SQL205\MIF-mif-7		4				mif				ALL			1			0xF46EBF2E1DEB384597B8A569945737FE	2			1						


SELECT top 100 * FROM distribution.dbo.MSlogreader_history order by start_time desc
--publisher_id	publisher_db	id	publisher_engine_edition
--4				ABCBase		7	30
--4				Test_1112		9	30

--12			mif				11	30


SELECT * FROM dbo.MSsubscriptions
select distinct publisher_database_id, publisher_id, publisher_db, publication_id, subscriber_id, subscriber_db FROM dbo.MSsubscriptions
go
--publisher_database_id	publisher_id	publisher_db	publication_id	subscriber_id	subscriber_db
--1						1				ABCBase		1				6				AB
--1						1				ABCBase		2				6				AB
--6						4				mif				5				5				ABCBase_copy
--6						4				mif				5				6				AB
--12					1				Test_1112		11				6				Test_10


select top 100 * from MSrepl_backup_lsns
-- Last Ternasaction LSN
select top 2 *       from          MSrepl_transactions  where publisher_database_id = 12 order by xact_seqno desc  -- ABCBase
select top 2 *       from          MSrepl_transactions  where publisher_database_id = 13 order by xact_seqno desc  -- mif
--


--Log Reader Agent Performance
SELECT top 300 
convert(numeric(10,1), delivery_latency / ( 1000.0 )) AS LatencySec, time, 
CAST(comments AS XML) AS comments, 
runstatus, 
duration, 
xact_seqno, 
delivered_transactions, 
delivered_commands, 
average_commands, 
delivery_time, 
delivery_rate
FROM mslogreader_history WITH (nolock) 
WHERE time > '2019-10-31 00:00:00.000' 
ORDER BY time DESC 


-- Run At Publisher
select top 100 * from master..replcounters order by dt desc


-- Distribution Agent Performance
USE distribution 
go 
SELECT TOP 100 
convert(numeric(10,1), delivery_latency/1000.0) as delivery_latency_sec,
time, 
Cast(comments AS XML) AS comments, 
runstatus, 
duration, 
xact_seqno, 
delivered_commands, 
average_commands, 
current_delivery_rate, 
delivered_transactions, 
error_id
FROM msdistribution_history WITH (nolock) 
ORDER BY time DESC 

select * from distribution.dbo.sysobjects where type='U' and name like 'MSRepl%' 
select top 100 * from distribution.dbo.MSrepl_errors order by time desc
select top 100 * from MSsnapshot_history
select top 100 * from MSlogreader_history order by start_time desc
delete from MSsnapshot_history -- Remove Snapshot Agent history

EXEC dbo.sp_MShistory_cleanup @history_retention = 1

-- See replicated commands
USE distribution 
go 


EXEC Sp_browsereplcmds 
@xact_seqno_start = '0x003DA4970039EDAA0025000000000000', 
--@xact_seqno_end = '0x003D95210003342E0015',
@publisher_database_id = 7 -- ABCBase

select top 100 * from distribution.dbo.MSdistribution_agents
select top 100 * from distribution.dbo.MSlogreader_agents


use ABCBase
go
-- Relication latecy report
exec sp_replcounters 
go

--select  convert(bigint, 0x003D95210003346B0012) - convert(bigint, 0x003D952100031BB1000E)

-- General Info for all Publications and Subscriptions
use distribution
go
SELECT 
(CASE  
    WHEN mdh.runstatus =  '1' THEN 'Start - '+cast(mdh.runstatus as varchar)
    WHEN mdh.runstatus =  '2' THEN 'Succeed - '+cast(mdh.runstatus as varchar)
    WHEN mdh.runstatus =  '3' THEN 'InProgress - '+cast(mdh.runstatus as varchar)
    WHEN mdh.runstatus =  '4' THEN 'Idle - '+cast(mdh.runstatus as varchar)
    WHEN mdh.runstatus =  '5' THEN 'Retry - '+cast(mdh.runstatus as varchar)
    WHEN mdh.runstatus =  '6' THEN 'Fail - '+cast(mdh.runstatus as varchar)
    ELSE CAST(mdh.runstatus AS VARCHAR)
END) 'Run Status', 
mda.subscriber_db 'Subscriber DB', 
mda.publication 'PUB Name',
right(left(mda.name,LEN(mda.name)-(len(mda.id)+1)), LEN(left(mda.name,LEN(mda.name)-(len(mda.id)+1)))-(10+len(mda.publisher_db)+(case when mda.publisher_db='ALL' then 1 else LEN(mda.publication)+2 end))) 'SUBSCRIBER',
CONVERT(VARCHAR(25),mdh.[time]) 'LastSynchronized',
und.UndelivCmdsInDistDB 'UndistCom', 
mdh.comments 'Comments', 
'select * from distribution.dbo.msrepl_errors (nolock) where id = ' + CAST(mdh.error_id AS VARCHAR(8)) 'Query More Info',
mdh.xact_seqno 'SEQ_NO',
(CASE  
    WHEN mda.subscription_type =  '0' THEN 'Push' 
    WHEN mda.subscription_type =  '1' THEN 'Pull' 
    WHEN mda.subscription_type =  '2' THEN 'Anonymous' 
    ELSE CAST(mda.subscription_type AS VARCHAR)
END) 'SUB Type',
mda.publisher_db+' - '+CAST(mda.publisher_database_id as varchar) 'Publisher DB',
mda.name 'Pub - DB - Publication - SUB - AgentID'
FROM distribution.dbo.MSdistribution_agents mda 
LEFT JOIN distribution.dbo.MSdistribution_history mdh ON mdh.agent_id = mda.id 
JOIN 
    (SELECT s.agent_id, MaxAgentValue.[time], SUM(CASE WHEN xact_seqno > MaxAgentValue.maxseq THEN 1 ELSE 0 END) AS UndelivCmdsInDistDB 
    FROM distribution.dbo.MSrepl_commands t (NOLOCK)  
    JOIN distribution.dbo.MSsubscriptions AS s (NOLOCK) ON (t.article_id = s.article_id AND t.publisher_database_id=s.publisher_database_id ) 
    JOIN 
        (SELECT hist.agent_id, MAX(hist.[time]) AS [time], h.maxseq  
        FROM distribution.dbo.MSdistribution_history hist (NOLOCK) 
        JOIN (SELECT agent_id,ISNULL(MAX(xact_seqno),0x0) AS maxseq 
        FROM distribution.dbo.MSdistribution_history (NOLOCK)  
        GROUP BY agent_id) AS h  
        ON (hist.agent_id=h.agent_id AND h.maxseq=hist.xact_seqno) 
        GROUP BY hist.agent_id, h.maxseq 
        ) AS MaxAgentValue 
    ON MaxAgentValue.agent_id = s.agent_id 
    GROUP BY s.agent_id, MaxAgentValue.[time]
    ) und 
ON mda.id = und.agent_id AND und.[time] = mdh.[time] 
where mda.subscriber_db<>'virtual' -- created when your publication has the immediate_sync property set to true. This property dictates whether snapshot is available all the time for new subscriptions to be initialized. This affects the cleanup behavior of transactional replication. If this property is set to true, the transactions will be retained for max retention period instead of it getting cleaned up as soon as all the subscriptions got the change.
--and mdh.runstatus='6' --Fail
--and mdh.runstatus<>'2' --Succeed
order by mdh.[time]


select top 100 * from distribution.dbo.msrepl_errors (nolock) 
--where id = 0
order by id desc


--- Run at Distributor
-- Get Current Replication Commands Info
SELECT  top 100 MSrepl_commands.xact_seqno , MSarticles.article, 
        MSrepl_commands.article_id , 
        MSrepl_commands.command_id , 
        MSsubscriptions.subscriber_id--, MSrepl_commands.*
FROM    distribution.dbo.MSrepl_commands AS [MSrepl_commands] with (nolock)
        INNER JOIN distribution.dbo.MSsubscriptions AS [MSsubscriptions] ON MSrepl_commands.publisher_database_id = MSsubscriptions.publisher_database_id 
                                                              AND MSrepl_commands.article_id = MSsubscriptions.article_id 
        INNER JOIN distribution.dbo.MSarticles AS [MSarticles] ON MSsubscriptions.publisher_id = MSarticles.publisher_id 
                                                              AND MSsubscriptions.publication_id = MSarticles.publication_id 
                                                              AND MSsubscriptions.article_id = MSarticles.article_id 
--WHERE   MSarticles.article in ('RepDem1','RepDem2','RepDem3')
ORDER BY MSrepl_commands.xact_seqno , 
        MSrepl_commands.article_id , 
        MSrepl_commands.command_id


select top 100 * from distribution.dbo.MSsubscriptions






use ABCBase
exec sp_helpsubscription_properties 
	@publisher = 'SQL105\AB'
	, @publisher_db = 'ABCBase'
	, @publication = 'ABCBase_Pub'
	, @publication_type =  0

SELECT name as tran_published_db FROM sys.databases WHERE is_published = 1;  
--Which databases are published using merge replication?  
SELECT name as merge_published_db FROM sys.databases WHERE is_merge_published = 1;

sp_helplogreader_agent
--select * from msdb..sysjobs where job_id='1A198E57-1C6D-42AC-8489-F48B8AF9FBA6'

use distribution
sp_helpsubscriptionerrors @publisher = 'SQL105\AB'
	, @publisher_db = 'ABCBase'
	, @publication = 'ABCBase_Pub'
	, @subscriber = 'SQL206'
	, @subscriber_db = 'AB'

sp_helpsubscriptionerrors @publisher = 'SQL105\AB'
	, @publisher_db = 'ABCBase'
	, @publication = 'PSM_Pub'
	, @subscriber = 'SQL206'
	, @subscriber_db = 'AB'

sp_helpsubscriptionerrors @publisher = 'SQL205\MIF'
	, @publisher_db = 'mif'
	, @publication = 'mif_Pub'
	, @subscriber = 'SQL206'
	, @subscriber_db = 'AB'

sp_helpsubscriptionerrors @publisher = 'SQL205\MIF'
	, @publisher_db = 'mif'
	, @publication = 'mif_Pub'
	, @subscriber = 'BROWN'
	, @subscriber_db = 'ABCBase_copy'

sp_helpsubscriptionerrors @publisher = 'SQL105\AB'
	, @publisher_db = 'Test_1112'
	, @publication = 'Test_Pub'
	, @subscriber = 'SQL206'
	, @subscriber_db = 'AB'

  
USE ABCBase;  
go  
-- View subscription details  
sp_helpsubscription @publication = 'ABCBase_Pub'
	, @article = 'Asset'
sp_helpdistributor

select top 1000 * from master..replcounters order by dt desc 

-- How Large are the Replication Specific Tables
USE distribution 
GO 
SELECT Getdate() AS CaptureTime, 
Object_name(t.object_id) AS TableName, 
st.row_count, 
s.NAME 
FROM sys.dm_db_partition_stats st WITH (nolock) 
INNER JOIN sys.tables t WITH (nolock) 
ON st.object_id = t.object_id 
INNER JOIN sys.schemas s WITH (nolock) 
ON t.schema_id = s.schema_id 
WHERE index_id < 2 
AND Object_name(t.object_id) 
IN ('MSsubscriptions', 
'MSdistribution_history', 
'MSrepl_commands', 
'MSrepl_transactions'
) 
ORDER BY st.row_count DESC 


--What are the snapshot and transactional publications in this database?   
EXEC sp_helppublication;  
--What are the articles in snapshot and transactional publications in this database?  
--REMOVE COMMENTS FROM NEXT LINE AND REPLACE <PublicationName> with the name of a publication  
EXEC sp_helparticle @publication='ABCBase_pub';  
EXEC sp_helparticlecolumns @publication='ABCBase_pub', @article = 'TransType'
EXEC sp_helparticlecolumns @publication='PSM_pub', @article = 'CpOnOperPlace'

EXEC Test_1112..sp_helparticle @publication='Test_1112';  
  
--What are the merge publications in this database?   
EXEC sp_helpmergepublication;  
--What are the articles in merge publications in this database?  
EXEC sp_helpmergearticle; -- to return information on articles for a single publication, specify @publication='<PublicationName>'  

use ABCBase;
--Which objects in the database are published?  (Run at Publisher)
SELECT name AS published_object, schema_id, is_published AS is_tran_published, is_merge_published, is_schema_published  
FROM sys.tables WHERE is_published = 1 or is_merge_published = 1 or is_schema_published = 1  
UNION  
SELECT name AS published_object, schema_id, 0, 0, is_schema_published  
FROM sys.procedures WHERE is_schema_published = 1  
UNION  
SELECT name AS published_object, schema_id, 0, 0, is_schema_published  
FROM sys.views WHERE is_schema_published = 1;  


USE ABCBase
go
--Get detailed info for published articles (Run at Publisher)
DECLARE @publication AS sysname;
SET @publication = N'PSM_Pub';

EXEC sp_helparticle
  @publication = @publication-- , @article = 'Client'
GO

-- Published Articles (Run at Distributor) -- for Confluence
SELECT
     Pub.[publication]    'PublicationName'
    ,Art.[publisher_db]   'DatabaseName'
    ,Art.[article]        'Article Name'
    ,Art.[source_owner]   'Schema'
    ,Art.[source_object]  'Object'
	,Pub.publication_id	  'Publication ID'
	,Art.[article_id]	  'Article ID'
FROM
    [distribution].[dbo].[MSarticles]  Art
    INNER JOIN [distribution].[dbo].[MSpublications] Pub
        ON Art.[publication_id] = Pub.[publication_id]
--where Pub.[publication] = 'ABCBase_Pub'
--where Pub.[publication] = 'mif_Pub'
--where Pub.[publication] = 'PSM_Pub'
where Pub.[publication] = 'RISK_Pub'
--where [Art].[article] = 'TransType'
ORDER BY
    Pub.[publication], Art.[article]

-- Which Articles are published right now 
-- See "Published Articles (Run at Distributor)"
SELECT top 100 * FROM distribution.dbo.MSdistribution_status


use ABCBase;

--Which columns in the database are published?  (Run at Publisher) -- for Confluence
SELECT schema_name(tab.schema_id) as 'Schema', tab.name AS PublishedObject, col.name as 'ColName', type_name(col.user_type_id) as 'ColType', col.is_replicated as 'IsReplicated'
FROM sys.tables tab with (nolock) join sys.columns col with (nolock)
on col.object_id = tab.object_id
WHERE tab.is_published = 1 
--and tab.name like 'CounterP%'
--and col.name like 'rev_stamp%'
and col.is_replicated = 1
order by schema_name(tab.schema_id), tab.name, col.name

--Which columns in the database are published?  (Run at Publisher) 
SELECT 'insert into #cols values(''' + col.name + ''');' as 'ColName' 
FROM sys.tables tab with (nolock) join sys.columns col with (nolock)
on col.object_id = tab.object_id
WHERE tab.is_published = 1 
and tab.name like 'CounterP%'
--and col.name like 'CtpT%'
and col.is_replicated = 1
order by col.name





--Which columns are published in snapshot or transactional publications in this database?  
SELECT object_name(object_id) AS tran_published_table, name AS published_column FROM sys.columns WHERE is_replicated = 1;  
  
--Which columns are published in merge publications in this database?  
SELECT object_name(object_id) AS merge_published_table, name AS published_column FROM sys.columns WHERE is_merge_published = 1;  

-- Get datails for an article in Publisher
USE ABCBase
go
DECLARE @publication AS sysname;
SET @publication = N'ABCBase_Pub';

EXEC sp_helparticle
  @publication = @publication;
GO

USE ABCBase
GO
sp_helparticlecolumns  @publication = N'ABCBase_Pub' ,  @article =  '$Operation'

select top 100 * from [distribution].[dbo].[MSsubscriber_info]
SELECT TOP (1000) [publisher_id], [publisher_db], [id], [publisher_engine_edition]  FROM [distribution].[dbo].[MSpublisher_databases]
select top 100 * from [distribution].[dbo].[MSpublications]
select top 100 * from [distribution].[dbo].[MSrepl_errors] order by time desc

select top 1000 * from [distribution].[dbo].[MSrepl_transactions]
select top 1000 * from [distribution].[dbo].[MSrepl_commands]
exec [distribution].[dbo].sp_browsereplcmds

exec msdb..sp__dbinfo

EXEC sp_helpdistributor;  

--------------- 
-- Commands to distribute
use distribution;
exec sp_browsereplcmds;
-- Get Subcription Status
 exec distribution..sp_replmonitorhelpsubscription @publication_type=0 -- 0 = Transactional replication
	---------
-- Get number of pending commands for a subscription to a transactional publication
use distribution;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
exec sp_replmonitorsubscriptionpendingcmds @publisher=N'SQL105\AB',@publisher_db='ABCBase', @publication='ABCBase_Pub', @subscriber = 'SQL206', 
	@subscriber_db='AB', @subscription_type=1 -- 0 = Push subscription, 1 -Pull

exec sp_replmonitorsubscriptionpendingcmds @publisher=N'SQL105\AB',@publisher_db='ABCBase', @publication='PSM_Pub', @subscriber = 'SQL206', 
	@subscriber_db='AB', @subscription_type=1 -- 0 = Push subscription, 1 -Pull

exec sp_replmonitorsubscriptionpendingcmds @publisher = 'SQL205\MIF', @publisher_db='mif', @publication='mif_Pub', @subscriber = 'SQL206', 
	@subscriber_db='AB', @subscription_type = 1 -- 0 = Push subscription, 1 -Pull

exec sp_replmonitorsubscriptionpendingcmds @publisher = 'SQL105\AB', @publisher_db='Test_1112', @publication='Test_1112',
	@subscriber = 'SQL206', @subscriber_db='Test_1112', @subscription_type = 1

exec AB..sp_helppullsubscription
exec AB..sp_helpsubscription_properties

--sp_help sp_replmonitorsubscriptionpendingcmds
---
use ABCBase
go
exec sp_showpendingchanges
exec sp_replcmds;
exec sp_replshowcmds;
sp_changePublication 'ABCBase_Pub',status,active
exec ABCBase..sp_showpendingchanges  --merge replication



--EXEC sp_configure 'remote proc trans'
-- Get publiser, articles and subscribers list
use Distribution
go
set transaction isolation level read uncommitted
go
select distinct srv.srvname pub_server, a.publisher_db, p.publication publication_name, a.article, 
	a.destination_object, ss.srvname as subscription_server, s.subscriber_db, da.name as distribution_job_name
from MSArticles a
JOIN MSPublications p on a.publication_id = p.publication_id
JOIN MSsubscriptions s on p.publication_id = s.publication_id
JOIN master..sysservers ss on s.subscriber_id = ss.srvid
JOIN master..sysservers srv on srv.srvid = p.publisher_id
join MSdistribution_agents da on da.publisher_id = p.publisher_id
	and da.subscriber_id = s.subscriber_id
--order by 1,2,3
order by distribution_job_name

select * from MSPublications p
JOIN MSsubscriptions s on p.publication_id = s.publication_id

select immediate_sync,allow_anonymous,* from distribution.dbo.MSpublications

select * from Distribution.dbo.MSpublications
 select top 100 * from MSdistribution_agents
 select top 100 * from msdb..MSdistributiondbs

 -- Connect Distributor and Remove orphant jobs
:CONNECT SQL205\REPL
go
exec Distribution.dbo.sp_MSremove_published_jobs @server = 'SQL105\AB', @database = 'Test_1112'
go


USE ABCBase




-- Steps to Add article without snapshot
EXEC sp_changepublication
@publication = 'ABCBase_Pub',
@property = N'allow_anonymous',
@value = 'False'
GO

EXEC sp_changepublication
@publication = 'ABCBase_Pub',
@property = N'immediate_sync',
@value = 'False'
GO


--Insert new token on Primary Replica in the Published database
use ABCBase
EXEC sys.sp_posttracertoken @publication ='ABCBase_Pub'
Go

use distribution
--View Tracer Token History from Distributor in the Distribution database
SELECT Top 20 tt.tracer_id, tt.publication_id, tt.publisher_commit, tt.distributor_commit, th.agent_id, th.subscriber_commit
FROM MStracer_tokens tt
JOIN MStracer_history th ON tt.tracer_id = th.parent_tracer_id
Order by tt.publisher_commit desc


--- General info
USE Distribution 
GO 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
-- Get the publication name based on article 
SELECT DISTINCT  
srv.srvname publication_server  
, a.publisher_db 
, p.publication publication_name 
, a.article 
, a.destination_object 
, ss.srvname subscription_server 
, s.subscriber_db 
, da.name AS distribution_agent_job_name 
FROM MSArticles a  
JOIN MSpublications p ON a.publication_id = p.publication_id 
JOIN MSsubscriptions s ON p.publication_id = s.publication_id 
JOIN master..sysservers ss ON s.subscriber_id = ss.srvid 
JOIN master..sysservers srv ON srv.srvid = p.publisher_id 
JOIN MSdistribution_agents da ON da.publisher_id = p.publisher_id  
     AND da.subscriber_id = s.subscriber_id 
ORDER BY 1,2,3  

-- Run from Publisher Database  
-- Get information for all databases 
DECLARE @Detail CHAR(1) 
SET @Detail = 'Y' 
CREATE TABLE #tmp_replcationInfo ( 
PublisherDB VARCHAR(128),  
PublisherName VARCHAR(128), 
TableName VARCHAR(128), 
SubscriberServerName VARCHAR(128), 
) 
EXEC sp_msforeachdb  
'use ?; 
IF DATABASEPROPERTYEX ( db_name() , ''IsPublished'' ) = 1 
insert into #tmp_replcationInfo 
select  
db_name() PublisherDB 
, sp.name as PublisherName 
, sa.name as TableName 
, UPPER(srv.srvname) as SubscriberServerName 
from dbo.syspublications sp  
join dbo.sysarticles sa on sp.pubid = sa.pubid 
join dbo.syssubscriptions s on sa.artid = s.artid 
join master.dbo.sysservers srv on s.srvid = srv.srvid 
' 
IF @Detail = 'Y' 
   SELECT * FROM #tmp_replcationInfo 
ELSE 
SELECT DISTINCT  
PublisherDB 
,PublisherName 
,SubscriberServerName  
FROM #tmp_replcationInfo 
DROP TABLE #tmp_replcationInfo 

-- Run from Subscriber Database 
SELECT distinct publisher, publisher_db, publication
FROM dbo.MSreplication_subscriptions
ORDER BY 1,2,3


-- Get Redirected Publisgers Run At SQL205\REPL
exec distribution..sp_get_redirected_publisher @original_publisher = 'SQL205\MIF',  
    @publisher_db = 'mif',  
	@bypass_publisher_validation = 1;

exec distribution..sp_get_redirected_publisher @original_publisher = 'SQL105\AB',  
    @publisher_db = 'ABCBase',  
	@bypass_publisher_validation = 0;

use distribution
select top 100 * from MSsubscription_properties


sp_
