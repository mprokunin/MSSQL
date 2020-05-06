use master
go

create table master..replcounters
(
[dt] datetime default getdate(),
[database] sysname,
[Replicated transactions] int, 
[Replication rate trans/sec] float, 
[Replication latency] float,
[Replbeginlsn] binary(10),
[Replnextlsn] binary(10)
)
create clustered index replcounters_idx on replcounters (dt)
go
grant select on replcounters to public
go

declare @rc TABLE (
[database] sysname,
[Replicated transactions] int, 
[Replication rate trans/sec] float, 
[Replication latency] float,
[Replbeginlsn] binary(10),
[Replnextlsn] binary(10)
)
insert @rc exec sp_replcounters 
insert into master..replcounters (
[database],
[Replicated transactions], 
[Replication rate trans/sec], 
[Replication latency],
[Replbeginlsn],
[Replnextlsn]
) select * from @rc where [database] ='AtonBase'
delete from master..replcounters where dt < dateadd(dd, -30, getdate())

select * from master..replcounters 

truncate table master..replcounters 
