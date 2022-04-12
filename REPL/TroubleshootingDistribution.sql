-- Get list of publishers
exec distribution..sp_replmonitorhelppublication
exec distribution..sp_replshowcmds


-- Show transactions currently not distributed (those transactions remaining in the transaction log that have not been sent to the Distributor).
EXECUTE mif..sp_repltrans 
EXECUTE mif..sp_replflush; -- Always run it to free cache

exec distribution.dbo.sp_helpsubscriptionerrors @publisher = 'SQL105\AB', @publisher_db = 'ABCBase', @publication = 'ABCBase_Pub', @subscriber = 'BROWN', @subscriber_db = 'ABCBase_copy'
exec distribution.dbo.sp_helpsubscriptionerrors @publisher = 'SQL105\AB', @publisher_db = 'ABCBase', @publication = 'PSM_Pub', @subscriber = 'BROWN', @subscriber_db = 'ABCBase_copy'
exec distribution.dbo.sp_helpsubscriptionerrors @publisher = 'SQL205\MIF', @publisher_db = 'mif', @publication = 'mif_Pub', @subscriber = 'BROWN', @subscriber_db = 'ABCBase_copy'

exec distribution.dbo.sp_helpsubscriptionerrors @publisher = 'SQL105\AB', @publisher_db = 'ABCBase', @publication = 'ABCBase_Pub', @subscriber = 'SQL206', @subscriber_db = 'ABCBase_copy'
exec distribution.dbo.sp_helpsubscriptionerrors @publisher = 'SQL105\AB', @publisher_db = 'ABCBase', @publication = 'PSM_Pub', @subscriber = 'SQL206', @subscriber_db = 'ABCBase_copy'
exec distribution.dbo.sp_helpsubscriptionerrors @publisher = 'SQL205\MIF', @publisher_db = 'mif', @publication = 'mif_Pub', @subscriber = 'SQL206', @subscriber_db = 'ABCBase_copy'
go
select top 10 * from distribution.dbo.msrepl_errors (nolock) order by time desc
--Violation of PRIMARY KEY constraint 'PK_tblOperationSign'. Cannot insert duplicate key in object 'dbo.tblOperationSign'. The duplicate key value is (232781519, 13).

--View Tracer Token History from Distributor in the Distribution database
SELECT Top 20 tt.tracer_id, tt.publication_id, tt.publisher_commit, tt.distributor_commit, th.agent_id, th.subscriber_commit
FROM MStracer_tokens tt
JOIN MStracer_history th ON tt.tracer_id = th.parent_tracer_id
Order by tt.publisher_commit desc

SELECT time,
       CAST(comments AS XML) AS comments,
       runstatus,
       duration,
       xact_seqno,
       delivered_transactions,
       delivered_commands,
       average_commands,
       delivery_time,
       delivery_rate,
       delivery_latency / (1000 * 60) AS delivery_latency_Min,
       agent_id
FROM dbo.MSlogreader_history WITH (NOLOCK)
--WHERE agent_id = 5
ORDER BY time DESC;

SELECT *
FROM dbo.MSdistribution_history
--WHERE agent_id = 125
ORDER BY time DESC;


-- Run at Subcriber
--Get the LSN that is causing the problem from one of the subscribers:
SELECT 
        publication, 
        '0x' + CONVERT(VARCHAR(32),MAX(transaction_timestamp),2) as LastPubLSN 
    FROM --dbo.MSreplication_monitordata
        dbo.MSreplication_subscriptions 
    GROUP BY publication

--publication	LastPubLSN
--ABCBase_Pub	0x003DABFB00884E780002000000000000
--mif_Pub		0x00ADE3CC000014E40001000000000000

-- Run at Distributor
--Find a valid LSN to start from:
DECLARE @Publisher sysname = N'SQL105\AB',
            @PubDB sysname = N'ABCBase',
            @Publication sysname = N'ABCBase_Pub';
    SELECT TOP 1000 trans.entry_time, trans.publisher_database_id, trans.xact_seqno, p.publisher_db, srv.srvname
        FROM dbo.MSpublications AS p
            JOIN master..sysservers AS srv
                ON srv.srvid = p.publisher_id
            JOIN dbo.MSpublisher_databases AS d
                ON d.publisher_id = p.publisher_id
                AND d.publisher_db = p.publisher_db
            JOIN dbo.MSrepl_transactions AS trans
                ON trans.publisher_database_id = d.id
        WHERE p.publication = @Publication
              AND p.publisher_db = @PubDB
              AND srv.srvname = @Publisher
              AND trans.xact_seqno >= p.min_autonosync_lsn
    ORDER BY trans.entry_time DESC



exec ABCBase..sp_helpsubscription 



use distribution
EXEC sp_helpsubscriptionerrors
    @publisher='AL-SQL05\BO',@publisher_db='ABCBase',@publication='ABCBase_Pub',
    @subscriber='BROWN',@subscriber_db='ABCBase_Copy'

-- Get Errors
SELECT msre.*   
  FROM MSrepl_errors msre  
  WHERE msre.id IN (SELECT error_id  
       FROM MSdistribution_history  
)--       WHERE agent_id = @agent_id)  
  ORDER by msre.time desc  



select * from    MSreplservers  
delete from MSreplservers  where srvid=11
update MSreplservers   set srvname='SQL205\MIF' where srvname='AL-SQL03\AOLFRONT'


update MSreplservers   set srvid=12 where srvname='AL-SQL03\AOLFRONT'
update MSreplservers   set srvname='AL-SQL03\AOLFRONT' where srvid=12
insert into MSreplservers   values (11 ,'SQL205\MIF')

srvid	srvname
1	TSQL03\SQL2008
2	TSQL05\SQL2008
3	BROWN
4	AL-SQL05\BO
5	AL-SQL03\SQL02
6	TSQL03\BO
7	SQL206
8	SQL105\AB
9	SQL205\AB
10	SQL105\MIF
11	SQL205\MIF
12	AL-SQL03\AOLFRONT
13	AL-SQL05
14	AL-SQL03\AOLFRONT\MIF


select *  FROM MSdistribution_agents  


sp_helpsubscriptionerrors @publisher = 'AL-SQL05\BO'
	, @publisher_db = 'ABCBase'
	, @publication = 'PSM_Pub'
	, @subscriber = 'BROWN'
	, @subscriber_db = 'ABCBase_copy'

sp_helpsubscriptionerrors @publisher = 'AL-SQL03\AOLFRONT'
	, @publisher_db = 'mif'
	, @publication = 'mif_Pub'
	, @subscriber = 'BROWN'
	, @subscriber_db = 'ABCBase_copy'


-- Âûïîëíÿòü íà publisher
-- Show transactions currently not distributed (those transactions remaining in the transaction log that have not been sent to the Distributor).
exec mif..sp_repltrans 
exec mif..sp_replshowcmds @maxtrans = 100

-- Î÷èñòèòü ëîã â Publisher
EXECUTE mif..sp_repldone @xactid = NULL, @xact_segno = NULL, @numtrans = 0, @time = 0, @reset = 1;
EXECUTE mif..sp_replflush; -- Always run it to free cache

execute mif..sp_replrestart

SELECT name, log_reuse_wait, log_reuse_wait_desc, is_cdc_enabled FROM sys.databases 
--WHERE name = 'ABCBAse'
order by name
exec msdb..sp__dbinfo 1
use mif
checkpoint

--The required parameters xactid and xact_seqno can be obtained by using sp_repltrans or sp_replcmds 
--see details here: https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-repldone-transact-sql?view=sql-server-2017


exec msdb..sp__dbinfo 1


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


-- Get Redirected Publisgers
exec distribution..sp_get_redirected_publisher @original_publisher = 'SQL205\MIF',  
    @publisher_db = 'mif',  
	@bypass_publisher_validation = 1;

exec distribution..exec sp_get_redirected_publisher @original_publisher = 'SQL105\AB',  
    @publisher_db = 'ABCBase',  
	@bypass_publisher_validation = 0;
