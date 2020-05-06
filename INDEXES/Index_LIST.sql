use QUIK_DB
go

SELECT 
    IndexName = QUOTENAME(I.name), 
    TableName =
        QUOTENAME(SCHEMA_NAME(T.[schema_id])) + 
        N'.' + QUOTENAME(T.name), 
    IsPrimaryKey = I.is_primary_key
FROM sys.indexes AS I
INNER JOIN sys.tables AS T
    ON I.[object_id] = T.[object_id]
WHERE
    I.type_desc <> N'HEAP'
ORDER BY 
    TableName ASC, 
    IndexName ASC;
go

------------------------------------------------------------------------------




select s.name, t.name, i.name, c.name from sys.tables t
inner join sys.schemas s on t.schema_id = s.schema_id
inner join sys.indexes i on i.object_id = t.object_id
inner join sys.index_columns ic on ic.object_id = t.object_id
inner join sys.columns c on c.object_id = t.object_id and
        ic.column_id = c.column_id

where i.index_id > 0    
 and i.type in (1, 2) -- clustered & nonclustered only
 and i.is_primary_key = 0 -- do not include PK indexes
 and i.is_unique_constraint = 0 -- do not include UQ
 and i.is_disabled = 0
 and i.is_hypothetical = 0
 and ic.key_ordinal > 0

order by ic.key_ordinal

