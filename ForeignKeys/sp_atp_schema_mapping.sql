-- https://www.sqlshack.com/mapping-schema-and-recursively-managing-data-part-2/
-- Delete rows from table referenced by foreign keys

CREATE PROCEDURE dbo.sp_atp_schema_mapping
       @schema_name SYSNAME,
       @table_name SYSNAME,
       @where_clause VARCHAR(MAX) = ''
AS
BEGIN
       SET NOCOUNT ON;
 
       DECLARE @sql_command VARCHAR(MAX) = ''; -- Used for many dynamic SQL statements
 
       SET @where_clause = ISNULL(LTRIM(RTRIM(@where_clause)), ''); -- Clean up WHERE clause, to simplify future SQL
 
       DECLARE @relationship_id INT; -- Will temporarily hold row ID for use in iterating through relationships
       DECLARE @count_sql_command VARCHAR(MAX) = ''; -- Used for dynamic SQL for count calculations
       DECLARE @row_count INT; -- Temporary holding place for relationship row count
       DECLARE @row_counts TABLE -- Temporary table to dump dynamic SQL output into
              (row_count INT);
 
       DECLARE @base_table_row_count INT; -- This will hold the row count of the base entity.
       SELECT @sql_command = 'SELECT COUNT(*) FROM [' + @schema_name + '].[' + @table_name + ']' + -- Build COUNT statement
              CASE
                     WHEN @where_clause <> '' -- Add WHERE clause, if provided
                           THEN CHAR(10) + 'WHERE ' + @where_clause
                     ELSE ''
              END;
 
       INSERT INTO @row_counts
              (row_count)
       EXEC (@sql_command);
      
       SELECT
              @base_table_row_count = row_count -- Extract count from temporary location.
       FROM @row_counts;
 
       -- If there are no matching rows to the input provided, exit immediately with an error message.
       IF @base_table_row_count = 0
       BEGIN
              PRINT '-- There are no rows to process based on the input table and where clause.  Execution aborted.';
              RETURN;
       END
 
       DELETE FROM @row_counts;
 
       -- This table will hold all foreign key relationships
       DECLARE @foreign_keys TABLE
       (   foreign_key_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY CLUSTERED,
              referencing_object_id INT NULL,
              referencing_schema_name SYSNAME NULL,
              referencing_table_name SYSNAME NULL,
              referencing_column_name SYSNAME NULL,
              primary_key_object_id INT NULL,
              primary_key_schema_name SYSNAME NULL,
              primary_key_table_name SYSNAME NULL,
              primary_key_column_name SYSNAME NULL,
              level INT NULL,
              object_id_hierarchy_rank VARCHAR(MAX) NULL,
              referencing_column_name_rank VARCHAR(MAX) NULL,
              row_count INT DEFAULT 0 NOT NULL,
              processed BIT DEFAULT 0 NOT NULL,
              join_condition_sql VARCHAR(MAX) DEFAULT ''); -- Save this after we complete the count calculations so we don't have to do it again later.
 
       -- Table to exclusively store self-referencing foreign key data
       DECLARE @self_referencing_keys TABLE
       (      self_referencing_keys_id INT NOT NULL IDENTITY(1,1),
              referencing_primary_key_name SYSNAME NULL,
              referencing_schema_name SYSNAME NULL,
              referencing_table_name SYSNAME NULL,
              referencing_column_name SYSNAME NULL,
              primary_key_schema_name SYSNAME NULL,
              primary_key_table_name SYSNAME NULL,
              primary_key_column_name SYSNAME NULL,
              row_count INT DEFAULT 0 NOT NULL,
              processed BIT DEFAULT 0 NOT NULL);
      
       -- Insert all foreign key relational data into the table variable using a recursive CTE over system tables.
       WITH fkey     (referencing_object_id,
                            referencing_schema_name,
                            referencing_table_name,
                            referencing_column_name,
                            primary_key_object_id,
                            primary_key_schema_name,
                            primary_key_table_name,
                            primary_key_column_name,
                            level,
                            object_id_hierarchy_rank,
                            referencing_column_name_rank) AS
       (      SELECT
                     parent_table.object_id AS referencing_object_id,
                     parent_schema.name AS referencing_schema_name,
                     parent_table.name AS referencing_table_name,
                     CONVERT(SYSNAME, NULL) AS referencing_column_name,
                     CONVERT(INT, NULL) AS referenced_table_object_id,
                     CONVERT(SYSNAME, NULL) AS referenced_schema_name,
                     CONVERT(SYSNAME, NULL) AS referenced_table_name,
                     CONVERT(SYSNAME, NULL) AS referenced_key_column_name,
                     0 AS level,
                     CONVERT(VARCHAR(MAX), parent_table.object_id) AS object_id_hierarchy_rank,
                     CAST('' AS VARCHAR(MAX)) AS referencing_column_name_rank
                     FROM sys.objects parent_table
                     INNER JOIN sys.schemas parent_schema
                     ON parent_schema.schema_id = parent_table.schema_id
                     WHERE parent_table.name = @table_name
                     AND parent_schema.name = @schema_name
              UNION ALL
              SELECT
                     child_object.object_id AS referencing_object_id,
                     child_schema.name AS referencing_schema_name,
                     child_object.name AS referencing_table_name,
                     referencing_column.name AS referencing_column_name,
                     referenced_table.object_id AS referenced_table_object_id,
                     referenced_schema.name AS referenced_schema_name,
                     referenced_table.name AS referenced_table_name,
                     referenced_key_column.name AS referenced_key_column_name,
                     f.level + 1 AS level,
                     f.object_id_hierarchy_rank + '-' + CONVERT(VARCHAR(MAX), child_object.object_id) AS object_id_hierarchy_rank,
                     f.referencing_column_name_rank + '-' + CAST(referencing_column.name AS VARCHAR(MAX)) AS referencing_column_name_rank
              FROM sys.foreign_key_columns sfc
              INNER JOIN sys.objects child_object
              ON sfc.parent_object_id = child_object.object_id
              INNER JOIN sys.schemas child_schema
              ON child_schema.schema_id = child_object.schema_id
              INNER JOIN sys.columns referencing_column
              ON referencing_column.object_id = child_object.object_id
              AND referencing_column.column_id = sfc.parent_column_id
              INNER JOIN sys.objects referenced_table
              ON sfc.referenced_object_id = referenced_table.object_id
              INNER JOIN sys.schemas referenced_schema
              ON referenced_schema.schema_id = referenced_table.schema_id
              INNER JOIN sys.columns AS referenced_key_column
              ON referenced_key_column.object_id = referenced_table.object_id
              AND referenced_key_column.column_id = sfc.referenced_column_id
              INNER JOIN fkey f
              ON f.referencing_object_id = sfc.referenced_object_id
              WHERE ISNULL(f.primary_key_object_id, 0) <> f.referencing_object_id -- Exclude self-referencing keys
              AND f.object_id_hierarchy_rank NOT LIKE '%' + CAST(child_object.object_id AS VARCHAR(MAX)) + '%'
       )
       INSERT INTO @foreign_keys
       (      referencing_object_id,
              referencing_schema_name,
              referencing_table_name,
              referencing_column_name,
              primary_key_object_id,
              primary_key_schema_name,
              primary_key_table_name,
              primary_key_column_name,
              level,
              object_id_hierarchy_rank,
              referencing_column_name_rank)
       SELECT DISTINCT
              referencing_object_id,
              referencing_schema_name,
              referencing_table_name,
              referencing_column_name,
              primary_key_object_id,
              primary_key_schema_name,
              primary_key_table_name,
              primary_key_column_name,
              level,
              object_id_hierarchy_rank,
              referencing_column_name_rank
       FROM fkey;
 
       UPDATE FKEYS
              SET referencing_column_name_rank = SUBSTRING(referencing_column_name_rank, 2, LEN(referencing_column_name_rank)) -- Remove extra leading dash leftover from the top-level column, which has no referencing column relationship.
       FROM @foreign_keys FKEYS
 
       -- Insert all data for self-referencing keys into a separate table variable.
       INSERT INTO @self_referencing_keys
               ( referencing_primary_key_name,
                       referencing_schema_name,
                       referencing_table_name,
                 referencing_column_name,
                       primary_key_schema_name,
                 primary_key_table_name,
                 primary_key_column_name)
       SELECT
              (SELECT COL_NAME(SIC.OBJECT_ID, SIC.column_id)
               FROM sys.indexes SI INNER JOIN sys.index_columns SIC
               ON SIC.index_id = SI.index_id AND SIC.object_id = SI.object_id
               WHERE SI.is_primary_key = 1
               AND OBJECT_NAME(SIC.OBJECT_ID) = child_object.name) AS referencing_primary_key_name,
              child_schema.name AS referencing_schema_name,
              child_object.name AS referencing_table_name,
              referencing_column.name AS referencing_column_name,
              referenced_schema.name AS primary_key_schema_name,
              referenced_table.name AS primary_key_table_name,
              referenced_key_column.name AS primary_key_column_name
       FROM sys.foreign_key_columns sfc
       INNER JOIN sys.objects child_object
       ON sfc.parent_object_id = child_object.object_id
       INNER JOIN sys.schemas child_schema
       ON child_schema.schema_id = child_object.schema_id
       INNER JOIN sys.columns referencing_column
       ON referencing_column.object_id = child_object.object_id
       AND referencing_column.column_id = sfc.parent_column_id
       INNER JOIN sys.objects referenced_table
       ON sfc.referenced_object_id = referenced_table.object_id
       INNER JOIN sys.schemas referenced_schema
       ON referenced_schema.schema_id = referenced_table.schema_id
       INNER JOIN sys.columns AS referenced_key_column
       ON referenced_key_column.object_id = referenced_table.object_id
       AND referenced_key_column.column_id = sfc.referenced_column_id
       WHERE child_object.name = referenced_table.name
       AND child_object.name IN -- Only consider self-referencing relationships for tables somehow already referenced above, otherwise they are irrelevant.
              (SELECT referencing_table_name FROM @foreign_keys);
 
       -------------------------------------------------------------------------------------------------------------------------------
       -- Generate the Delete script for self-referencing data
       -------------------------------------------------------------------------------------------------------------------------------
 
       WHILE EXISTS (SELECT * FROM @self_referencing_keys SRKEYS WHERE SRKEYS.processed = 0)
       BEGIN
              -- Get next self-referencing relationship to process
              SELECT TOP 1
                     @relationship_id = SRKEY.self_referencing_keys_id
              FROM @self_referencing_keys SRKEY
              WHERE processed = 0;
              -- Get row counts for the update statement
              SELECT
                     @count_sql_command = 'SELECT COUNT(*)' + CHAR(10) +
                     'FROM [' + SRKEY.referencing_schema_name + '].[' + SRKEY.referencing_table_name + ']' + CHAR(10) +
                     'WHERE [' + SRKEY.referencing_column_name + '] IN' + CHAR(10) +
                     '     (SELECT ' + SRKEY.primary_key_column_name + ' FROM [' + SRKEY.primary_key_schema_name + '].[' + SRKEY.primary_key_table_name + '])' + CHAR(10)
              FROM @self_referencing_keys SRKEY
              WHERE SRKEY.self_referencing_keys_id = @relationship_id;
 
              INSERT INTO @row_counts
                     (row_count)
              EXEC (@count_sql_command)
              SELECT @row_count = row_count FROM @row_counts;
 
              IF @row_count > 0
              BEGIN
                     SELECT
                           @sql_command =
                           '-- Rows to be updated: ' + CAST(@row_count AS VARCHAR(MAX)) + CHAR(10) +
                           'UPDATE [' + SRKEY.referencing_schema_name + '].[' + SRKEY.referencing_table_name + ']' + CHAR(10) +
                           '     SET ' + SRKEY.referencing_column_name + ' = NULL' + CHAR(10) +
                           'FROM [' + SRKEY.referencing_schema_name + '].[' + SRKEY.referencing_table_name + ']' + CHAR(10) +
                           'WHERE [' + SRKEY.referencing_column_name + '] IN' + CHAR(10) +
                           '     (SELECT ' + SRKEY.primary_key_column_name + ' FROM [' + SRKEY.primary_key_schema_name + '].[' + SRKEY.primary_key_table_name + ')' + CHAR(10)
                     FROM @self_referencing_keys SRKEY
                     WHERE SRKEY.self_referencing_keys_id = @relationship_id;
 
                     -- Print self-referencing data modification statements
                     PRINT @sql_command;
              END
              ELSE
              BEGIN
                     -- Remove any rows for which we have no data.
                     DELETE SRKEY
                     FROM @self_referencing_keys SRKEY
                     WHERE SRKEY.self_referencing_keys_id = @relationship_id;
              END
 
              UPDATE @self_referencing_keys
                     SET processed = 1,
                           row_count = @row_count
              WHERE self_referencing_keys_id = @relationship_id;
 
              DELETE FROM @row_counts;
       END
 
       -------------------------------------------------------------------------------------------------------------------------------
       -- Generate row counts for non-self-referencing data and delete any entries that have a zero row count
       -------------------------------------------------------------------------------------------------------------------------------
       DECLARE @object_id_hierarchy_sql VARCHAR(MAX);
     
       DECLARE @process_schema_name SYSNAME = '';
       DECLARE @process_table_name SYSNAME = '';
       DECLARE @referencing_column_name SYSNAME = '';
       DECLARE @join_sql VARCHAR(MAX) = '';
       DECLARE @object_id_hierarchy_rank VARCHAR(MAX) = '';
       DECLARE @referencing_column_name_rank VARCHAR(MAX) = '';
       DECLARE @old_schema_name SYSNAME = '';
       DECLARE @old_table_name SYSNAME = '';
       DECLARE @foreign_key_id INT;
       DECLARE @has_same_object_id_hierarchy BIT; -- Will be used if this foreign key happens to share a hierarchy with other keys
       DECLARE @level INT;
 
       WHILE EXISTS (SELECT * FROM @foreign_keys WHERE processed = 0 AND level > 0 )
       BEGIN
              SELECT @count_sql_command = '';
              SELECT @join_sql = '';
              SELECT @old_schema_name = '';
              SELECT @old_table_name = '';
 
              CREATE TABLE #inner_join_tables
                     (      id INT NOT NULL IDENTITY(1,1),
                           object_id INT);
             
              SELECT TOP 1
                     @process_schema_name = FKEYS.referencing_schema_name,
                     @process_table_name = FKEYS.referencing_table_name,
                     @object_id_hierarchy_rank = FKEYS.object_id_hierarchy_rank,
                     @referencing_column_name_rank = FKEYS.referencing_column_name_rank,
                     @foreign_key_id = FKEYS.foreign_key_id,
                     @referencing_column_name = FKEYS.referencing_column_name,
                     @has_same_object_id_hierarchy = CASE WHEN (SELECT COUNT(*) FROM @foreign_keys FKEYS2 WHERE FKEYS2.object_id_hierarchy_rank = FKEYS.object_id_hierarchy_rank) > 1 THEN 1 ELSE 0 END,
                     @level = FKEYS.level
              FROM @foreign_keys FKEYS
              WHERE FKEYS.processed = 0
              AND FKEYS.level > 0
              ORDER BY FKEYS.level ASC;
 
              SELECT @object_id_hierarchy_sql ='SELECT ' + REPLACE (@object_id_hierarchy_rank, '-', ' UNION ALL SELECT ');
 
              INSERT INTO #inner_join_tables
                     EXEC(@object_id_hierarchy_sql);
 
              SET @count_sql_command = 'SELECT COUNT(*) FROM [' + @process_schema_name + '].[' + @process_table_name + ']' + CHAR(10);
 
              SELECT
                     @join_sql = @join_sql +
                     CASE
                           WHEN (@old_table_name <> FKEYS.primary_key_table_name OR @old_schema_name <> FKEYS.primary_key_schema_name)
                                  THEN 'INNER JOIN [' + FKEYS.primary_key_schema_name + '].[' + FKEYS.primary_key_table_name + '] ' + CHAR(10) + ' ON ' +
                                  ' [' + FKEYS.primary_key_schema_name + '].[' + FKEYS.primary_key_table_name + '].[' + FKEYS.primary_key_column_name + '] =  [' + FKEYS.referencing_schema_name + '].[' + FKEYS.referencing_table_name + '].[' + FKEYS.referencing_column_name + ']' + CHAR(10)
                           ELSE ''
                     END
                     , @old_table_name = CASE
                                                              WHEN (@old_table_name <> FKEYS.primary_key_table_name OR @old_schema_name <> FKEYS.primary_key_schema_name)
                                                                     THEN FKEYS.primary_key_table_name
                                                              ELSE @old_table_name
                                                       END
                     , @old_schema_name = CASE
                                                              WHEN (@old_table_name <> FKEYS.primary_key_table_name OR @old_schema_name <> FKEYS.primary_key_schema_name)
                                                                     THEN FKEYS.primary_key_schema_name
                                                              ELSE @old_schema_name
                                                       END
              FROM @foreign_keys FKEYS
              INNER JOIN #inner_join_tables join_details
              ON FKEYS.referencing_object_id  = join_details.object_id
              WHERE CHARINDEX(FKEYS.object_id_hierarchy_rank + '-', @object_id_hierarchy_rank + '-') <> 0 -- Do not allow cyclical joins through the same table we are originating from
              AND FKEYS.level > 0
              AND ((@has_same_object_id_hierarchy = 0) OR (@has_same_object_id_hierarchy = 1 AND FKEYS.referencing_column_name = @referencing_column_name) OR (@has_same_object_id_hierarchy = 1 AND @level > FKEYS.level))
              ORDER BY join_details.ID DESC;
 
              SELECT @count_sql_command = @count_sql_command +  @join_sql;
 
              IF @where_clause <> ''
              BEGIN
                     SELECT @count_sql_command = @count_sql_command + ' WHERE (' + @where_clause + ')';
              END
 
              INSERT INTO @row_counts
                     (row_count)
              EXEC (@count_sql_command);
              SELECT @row_count = row_count FROM @row_counts;
 
              IF @row_count = 0
              BEGIN
                     DELETE FKEYS
                     FROM @foreign_keys FKEYS
                     WHERE FKEYS.object_id_hierarchy_rank LIKE @object_id_hierarchy_rank + '%' -- Remove all paths that share the same root as this one.
                     AND (FKEYS.object_id_hierarchy_rank <> @object_id_hierarchy_rank OR FKEYS.foreign_key_id = @foreign_key_id) -- Don't remove paths where there are multiple foreign keys from one table to another.
                     AND FKEYS.referencing_column_name_rank LIKE @referencing_column_name_rank + '%' -- Don't remove paths that have identical table relationships, but that occur through different FK columns.
              END
              ELSE
              BEGIN
                     UPDATE FKEYS
                           SET processed = 1,
                                  row_count = @row_count,
                                  join_condition_sql = @join_sql
                     FROM @foreign_keys FKEYS
                     WHERE FKEYS.foreign_key_id = @foreign_key_id;
              END
 
              DELETE FROM @row_counts;
              DROP TABLE #inner_join_tables
       END
 
       -- Reset processed flag for all rows
       UPDATE @foreign_keys
       SET processed = 0;
 
       -------------------------------------------------------------------------------------------------------------------------------
       -- Generate the Delete script for non-self-referencing data
       -------------------------------------------------------------------------------------------------------------------------------
 
       WHILE EXISTS (SELECT * FROM @foreign_keys WHERE processed = 0 AND level > 0 )
       BEGIN
              SELECT @sql_command = '';
              SELECT @join_sql = '';
              SELECT @old_table_name = '';
              SELECT @old_schema_name = '';
 
              SELECT TOP 1
                     @process_schema_name = referencing_schema_name,
                     @process_table_name = referencing_table_name,
                     @object_id_hierarchy_rank = object_id_hierarchy_rank,
                     @row_count = row_count,
                     @foreign_key_id = foreign_key_id
              FROM @foreign_keys
              WHERE processed = 0
              AND level > 0
              ORDER BY level DESC;
 
              SET @sql_command = '-- Maximum rows to be deleted: ' + CAST(@row_count AS VARCHAR(25)) + CHAR(10) +
              'DELETE [' + @process_table_name + ']' + CHAR(10) + 'FROM [' + @process_schema_name + '].[' + @process_table_name + ']' + CHAR(10);
 
              SELECT
                     @join_sql = FKEYS.join_condition_sql
              FROM @foreign_keys FKEYS
              WHERE FKEYS.foreign_key_id = @foreign_key_id
 
              SELECT @sql_command = @sql_command +  @join_sql;
 
              IF @where_clause <> ''
              BEGIN
                     SELECT @sql_command = @sql_command + 'WHERE (' + @where_clause + ')' + CHAR(10);
              END
 
              -- If rows exist to be deleted, then print those delete statements.
              PRINT @sql_command + 'GO' + CHAR(10);
 
              UPDATE @foreign_keys
                     SET processed = 1
              WHERE foreign_key_id = @foreign_key_id
       END
 
       -- Delete data from the root table
       SET @sql_command = '-- Rows to be deleted: ' + CAST(@base_table_row_count AS VARCHAR(25)) + CHAR(10) +
       'DELETE FROM [' + @process_schema_name + '].[' + @table_name + ']';
 
       IF @where_clause <> ''
       BEGIN
              SELECT @sql_command = @sql_command + CHAR(10) + 'WHERE ' + @where_clause;
       END
 
       -- Print deletion statement for root table
       PRINT @sql_command;
 
       -- Select remaining data from hierarchical tables & Update SELECT data for the base table to reflect the row count calculated at the start of this script
       UPDATE @foreign_keys
              SET row_count = @base_table_row_count,
                     processed = 1
       WHERE level = 0;
 
       IF (SELECT COUNT(*) FROM @self_referencing_keys) > 0
       BEGIN
              SELECT
                     *
              FROM @self_referencing_keys;
       END
       SELECT
              *
       FROM @foreign_keys;
END
GO
