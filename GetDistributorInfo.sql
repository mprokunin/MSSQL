--********** Execute at the Distributor in the master database **********--  
  
USE master;  
go  
  
--Is the current server a Distributor?  
--Is the distribution database installed?  
--Are there other Publishers using this Distributor?  
EXEC sp_get_distributor  
  
--Is the current server a Distributor?  

SELECT is_distributor FROM sys.servers WHERE name='repl_distributor' AND data_source=@@servername;  
SELECT * FROM sys.servers WHERE name='repl_distributor'

use AtonBase;  
--Which databases on the Distributor are distribution databases?  
SELECT name FROM sys.databases WHERE is_distributor = 1  
  
--What are the Distributor and distribution database properties?  
EXEC sp_helpdistributor;  
EXEC distribution..sp_helpdistributiondb;  
EXEC distribution..sp_helpdistpublisher;  

--- change workng directory
--sp_changedistpublisher @publisher = 'PLAYSERV01' , @property = 'working_directory', @value = '\\playserv01\e$\data\repldata'

--********** Execute at the Publisher in the master database **********--  
  
--Which databases are published for replication and what type of replication?  
EXEC sp_helpreplicationdboption;  
  
--Which databases are published using snapshot replication or transactional replication?  
SELECT name as tran_published_db FROM sys.databases WHERE is_published = 1;  
--Which databases are published using merge replication?  
SELECT name as merge_published_db FROM sys.databases WHERE is_merge_published = 1;  
  
--What are the properties for Subscribers that subscribe to publications at this Publisher?  
EXEC sp_helpsubscriberinfo;  

-- Published Articles (Run at Publisher)

SELECT name AS published_object, schema_id, is_published AS is_tran_published, is_merge_published, is_schema_published 
FROM sys.tables WHERE is_published = 1 or is_merge_published = 1 or is_schema_published = 1 
UNION 
SELECT name AS published_object, schema_id, 0, 0, is_schema_published 
FROM sys.procedures WHERE is_schema_published = 1 
UNION 
SELECT name AS published_object, schema_id, 0, 0, is_schema_published 
FROM sys.views WHERE is_schema_published = 1;

EXEC Test_1112..sp_helparticle @publication='Test_1112_Pub', @article = 'Counterparty';  
EXEC Test_1112..sp_helparticlecolumns @publication='Test_1112_Pub', @article = 'Counterparty';  


-- Published Articles (Run at Distributor)
SELECT
Pub.[publication] [PublicationName]
,Art.[publisher_db] [DatabaseName]
,Art.[article] [Article Name]
,Art.[source_owner] [Schema]
,Art.[source_object] [Object]
,Art.[article_id]
FROM
[distribution].[dbo].[MSarticles] Art
INNER JOIN [distribution].[dbo].[MSpublications] Pub
ON Art.[publication_id] = Pub.[publication_id]
--where Pub.[publication] = 'Test_1112_Pub'
ORDER BY
Pub.[publication], Art.[article]

-- Browse hanged commands 
exec [distribution].[dbo].sp_browsereplcmds
go


select top 100 * from MSrepl_backup_lsns
select top 1 *       from          MSrepl_transactions  where publisher_database_id in () order by xact_seqno desc


        select top 1 @max_xact_id = rt.xact_id, @max_xact_seqno = rt.xact_seqno
          from
          MSrepl_transactions rt
          where
             rt.publisher_database_id = @publisher_database_id and
             not xact_id = 0x0

             order by xact_seqno desc

