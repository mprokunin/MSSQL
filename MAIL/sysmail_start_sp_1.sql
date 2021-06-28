use msdb
go
exec sysmail_start_sp
go
select * from sys.sysprocesses where dbid = DB_ID('DI_STAT_OLD')
alter database [DI_STAT_OLD] set offline with rollback immediate