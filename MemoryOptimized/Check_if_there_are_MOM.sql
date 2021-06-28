EXEC sp_MSforeachdb 'USE [?] IF EXISTS (SELECT 1 FROM sys.filegroups FG 
               JOIN sys.database_files F
			     ON FG.data_space_id = F.data_space_id
     WHERE FG.type = ''FX'' AND F.type = 2) SELECT ''?'' AS ''Can contain memory-optimized tables'' ';