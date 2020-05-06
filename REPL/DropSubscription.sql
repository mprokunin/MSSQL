-- Dropping the transactional subscriptions
use [TDB]
sp_helpsubscription
go
exec sp_dropsubscription @publication = N'TDB_Pub', @subscriber = N'tsql05\bo', @destination_db = N'TDB', @article = N'all'
GO

-- Dropping the transactional articles
use [TDB]
exec sp_dropsubscription @publication = N'TDB_Pub', @article = N'Table_1', @subscriber = N'all', @destination_db = N'all'
GO
use [TDB]
exec sp_droparticle @publication = N'TDB_Pub', @article = N'Table_1', @force_invalidate_snapshot = 1
GO

-- Dropping the transactional publication
use [TDB]
exec sp_droppublication @publication = N'TDB_Pub'
GO

