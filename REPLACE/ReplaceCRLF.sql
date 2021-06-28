declare @string varchar (max)= 'abc' + char(10) + ' def' + char(13) + ' ghj'
select @string
SELECT REPLACE(REPLACE(cast(@string as varchar(max)), CHAR(13), ''), CHAR(10), '')
select @string as 'Fixed'
