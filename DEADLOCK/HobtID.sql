use [DI_STAT]
go

SELECT 
    sc.name as schema_name, 
    so.name as object_name, 
    si.name as index_name
FROM sys.partitions AS p
JOIN sys.objects as so on 
    p.object_id=so.object_id
JOIN sys.indexes as si on 
    p.index_id=si.index_id and 
    p.object_id=si.object_id
JOIN sys.schemas AS sc on 
    so.schema_id=sc.schema_id
WHERE hobt_id = 72057594256031744;
GO


SELECT top 10 %%lockres%%, * FROM dbo.policies_incoming (NOLOCK)
WHERE %%lockres%% = '(f0263bef6ced)'; -- magic number



Use [DI_STAT]
GO
SELECT 
    sys.fn_PhysLocFormatter (%%physloc%%),
    *
FROM Sales.OrderLines (NOLOCK)
WHERE sys.fn_PhysLocFormatter (%%physloc%%) like '(3:70133%'
