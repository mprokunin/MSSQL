
with users as
(select 'user1' as name
union all
select 'user2'
union all
select 'userN')
 
select 'grant execute on ' + ss.name + '.' + so.name + ' to ' + users.name as script from sys.objects so 
inner join sys.schemas ss on so.schema_id = ss.schema_id
cross join users
where so.type_desc = 'SQL_SCALAR_FUNCTION'
union all
select 'grant select on ' + ss.name + '.' + so.name + ' to ' + users.name as script from sys.objects so 
inner join sys.schemas ss on so.schema_id = ss.schema_id
cross join users 
where so.type_desc = 'SQL_INLINE_TABLE_VALUED_FUNCTION'
