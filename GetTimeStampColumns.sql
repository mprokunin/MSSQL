-- Get Timestamp cols from publicated tables
select tab.is_published, tab.name, col.COLUMN_NAME, col.DATA_TYPE 
from sys.tables tab
left outer join INFORMATION_SCHEMA.COLUMNS col
on col.TABLE_NAME = tab.name and col.DATA_TYPE = 'timestamp' 
	where tab.is_published = 1 
	order by tab.name, col.COLUMN_NAME


	-- Get Timestamp cols from publicated tables
select tab.is_published, tab.name, col.COLUMN_NAME, col.DATA_TYPE 
from sys.tables tab
left outer join INFORMATION_SCHEMA.COLUMNS col
on col.TABLE_NAME = tab.name and col.COLUMN_NAME like 'MDMReconcilationCompleted'
	where tab.is_published = 1 
	order by tab.name, col.COLUMN_NAME

sp_help OperLinkType