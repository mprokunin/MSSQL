use TDB
go

-- Prepare table for publication (add primary key)
alter table Table_1 alter column col2 int not null
go
ALTER TABLE dbo.Table_1   
ADD CONSTRAINT PK_Table_1 PRIMARY KEY CLUSTERED (Col2);  
GO  
