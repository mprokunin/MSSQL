----------- Index creation dates for a table
select i.name, i.object_id, o.create_date, o.object_id, o.name
from sys.indexes i 
join sys.objects o on i.object_id=o.object_id 
--where o.name = 'Operation'
order by create_date desc

sp_spaceused 'rpt.creators4change'
select object_name(1027131050) --creators4change
select user_name(uid),* from sysobjects where name like 'creators4change'
sp_help '[ICATON\Rumyantseva].[creators4change]'
sp_helpdb
select OBJECT_SCHEMA_NAME ( 1027131050 , 5 )