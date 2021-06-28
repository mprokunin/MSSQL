exec msdb..sp_msforeachdb '
select ''?''
dbcc opentran(?)
'

sp_who 65
dbcc inputbuffer(65)

select convert(nvarchar(50),(SERVERPROPERTY('instancename')))
sp_who [icaton\prokunin]