-- check the endpoints authentication type and find the certificate used
select connection_auth_desc, certificate_id, * from sys.service_broker_endpoints -- CERTIFICATE, 258
-- check the certificate expiration date
--select expiry_date, thumbprint, * from master.sys.certificates where certificate_id = 258; -- 2029-01-01 00:00:00.000, 0xAB9ED3ADBD9B837E0A4BE9BF8967E111F4487DAE
select expiry_date, thumbprint, * from master.sys.certificates where certificate_id = 262; -- 2029-01-01 00:00:00.000, 0xAB9ED3ADBD9B837E0A4BE9BF8967E111F4487DAE
-- find user 
select principal_id, * from master.sys.certificates where thumbprint = 0xAB9ED3ADBD9B837E0A4BE9BF8967E111F4487DAE; -- 1
select principal_id, * from master.sys.certificates where thumbprint = 0x9296C21FE94D08DC6D42433BEBAA58FF620CAD8C; -- 1
sp_helpdb
select * from master.sys.database_principals	where principal_id = 1; -- dbo
-- 
select principal_name, peer_certificate_id, authentication_method, *
	from sys.dm_broker_connections

--select * from master.sys.server_principals where principal_id= 6911
--select * from master.sys.server_principals where principal_id= 1260
--select * from master.sys.server_principals where principal_id= 42

select is_broker_enabled,* from master.sys.databases where is_broker_enabled = 1 order by name
sp_helplogins ATDPNotificationFableBroker