-- Stop Distrubution agents
-- Rename Subcriber Database

:Connect Distributor


:Connect Subscriber

select @@SERVERNAME

ALTER DATABASE [AtonBase] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
ALTER DATABASE [AtonBase] MODIFY NAME = [AB] ;
GO  
ALTER DATABASE [AB] SET MULTI_USER
GO

:Connect Publisher (AL-SQL05\BO)

use [AtonBase]
go
update syssubscriptions 
set dest_db = 'AB' where srvname='SQL206' and dest_db = 'AtonBase' 
go

/*
use TDB
go
update syssubscriptions 
set dest_db = 'Test_10' where srvname='BROWN' and dest_db = 'Test_1112' 
go
*/
--select * from syssubscriptions 

:Connect Distributor (AL-SQL03\REPL)

use distribution
go
update MSsubscriptions
set subscriber_db = 'AB' where subscriber_id = 7 and subscriber_db = 'AtonBase' -- subscriber_id = 7 -> SQL206 
go

--select top 200 * from subscribers where subscriber_db = 'Test_1112'
--select top 200 * from MSsubscriptions where subscriber_id = 7  subscriber_db = 'Test_10'

use distribution
go

update MSdistribution_agents 
set subscriber_db = 'AB' where subscriber_id = 7 and subscriber_db = 'AtonBase' 
go
--select * from MSdistribution_agents 
go
--------------
--Change  step 2 params on distribution agent
-Subscriber [SQL206] -SubscriberDB [AB] -Publisher [AL-SQL05\BO] -Distributor [REPHADR] -DistributorSecurityMode 1 -Publication [AtonBase_Pub] -PublisherDB [AtonBase]    -Continuous
