USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[SQLUpdateStatsAll]    Script Date: 23.11.2018 17:27:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/**************************************************************************************
 Purpose:  The Purpose of this Stored Procedure is to update statistics on the user database 
	                      


Date Created: May 02, 2006

Modification History:
Date          	Who              What

=============  ===============  ====================================      
*/



create PROCEDURE [dbo].[SQLUpdateStatsAll]
		       @DBName VARCHAR(80)=NULL,
		       @TableName VARCHAR(80)=NULL,
		       @Sample INT=10,
		       @Scanflag bit=0
AS

SET NOCOUNT ON

DECLARE @StrSQL NVARCHAR(2000)
DECLARE @sDbname VARCHAR(80)
DECLARE @tblName VARCHAR(80)
DECLARE @schmaName VARCHAR(80)
DECLARE @OuterLoop INT
DECLARE @InnerLoop INT
DECLARE @Version VARCHAR(255)
DECLARE @ErrorMessage VARCHAR(400)

SELECT @Version=CASE 
			      WHEN CHARINDEX ('8.00',@@version)>0 then 'SQL Server 2000'
			      WHEN CHARINDEX ('9.00',@@version)>0 then 'SQL Server 2005'
		                   ELSE 'SQL Server 2005'
		END



--Create a Temp table to store
-- the table Names


CREATE TABLE #TempTableList
			 (SchemaName VARCHAR(80),
			  TableName VARCHAR(80)
			  )

--Create a table to store databaseNames.
CREATE TABLE #TempDBList
             (DBName VARCHAR(80),
              Process INT DEFAULT 0
			  )

CREATE TABLE #TableList (Tabname VARCHAR(80))

--Check If dbname is passed as null and a table is passed. 
--Raise an error in that situation.

SET @ErrorMessage='Updating Statistics Requires a Database Name.In order to update statistics on single or multiple tables'+CHAR(13)+CHAR(10)
    		          +'both the database and table names must be passed.'

IF (@DBNAME IS NULL AND @TableName IS NOT NULL)
BEGIN
	RAISERROR (@Errormessage,16,1)
	RETURN
END



--Get the database. Exclude read only databases.
IF @DBName IS NULL
BEGIN

	INSERT INTO #TempDBList(DBName) 
	SELECT [NAME] AS DBName FROM master.dbo.sysdatabases AS A
	WHERE [NAME] NOT IN ('master','msdb','tempdb','Adventureworks','model','pubs')
	AND status &512 = 0
	AND   isnull(databaseproperty(a.name,'isReadOnly'),0) = 0
	AND    isnull(databaseproperty(a.name,'isOffline'),0)  = 0
	AND    isnull(databaseproperty(a.name,'IsSuspect'),0)  = 0
	AND    isnull(databaseproperty(a.name,'IsShutDown'),0)  = 0
	AND    isnull(databaseproperty(a.name,'IsNotRecovered'),0)  = 0
	AND    isnull(databaseproperty(a.name,'IsInStandBy'),0)  = 0
	AND    isnull(databaseproperty(a.name,'IsInRecovery'),0)  = 0
	AND    isnull(databaseproperty(a.name,'IsInLoad'),0)  = 0
	AND    isnull(databaseproperty(a.name,'IsEmergencyMode'),0)  = 0
	AND    isnull(databaseproperty(a.name,'IsDetached'),0)  = 0
	ORDER BY [Name] ASC

END

ELSE
BEGIN



	INSERT INTO #TempDBList(DBName) 
	SELECT [NAME] AS DBName FROM master.dbo.sysdatabases AS A
	WHERE [NAME] NOT IN ('master','msdb','tempdb','Adventureworks','model','pubs')
	AND status &512 = 0
	AND   isnull(databaseproperty(a.name,'isReadOnly'),0) = 0
	AND    isnull(databaseproperty(a.name,'isOffline'),0)  = 0
	AND    isnull(databaseproperty(a.name,'IsSuspect'),0)  = 0
	AND    isnull(databaseproperty(a.name,'IsShutDown'),0)  = 0
	AND    isnull(databaseproperty(a.name,'IsNotRecovered'),0)  = 0
	AND    isnull(databaseproperty(a.name,'IsInStandBy'),0)  = 0
	AND    isnull(databaseproperty(a.name,'IsInRecovery'),0)  = 0
	AND    isnull(databaseproperty(a.name,'IsInLoad'),0)  = 0
	AND    isnull(databaseproperty(a.name,'IsEmergencyMode'),0)  = 0
	AND    isnull(databaseproperty(a.name,'IsDetached'),0)  = 0


END



--Loop over the databases
DECLARE DBCursor CURSOR
FOR SELECT DBNAME
        FROM #TempDbList
       WHERE Process=0

OPEN DBCursor

FETCH DBCursor INTO @sDbname 

--Save the fetch status to a variable
SELECT @OuterLoop = @@FETCH_STATUS

WHILE @OuterLoop = 0
BEGIN
	 
IF @Version='SQL Server 2005'
BEGIN
  SELECT @StrSQL = N'SELECT QUOTENAME'+'('+'sc.[Name]'+')'+'AS SchemaName,'+
		         'QUOTENAME'+'('+ 'soj.[Name])AS TableName FROM '+ QuoteName(@sDbName) 
		         +'.'+'sys.objects soj JOIN '+QuoteName(@sDbName)+'.'+
                  	          'sys.schemas sc ON soj.schema_id=sc.schema_id WHERE [type] = ''U'''      
END

IF @Version='SQL Server 2000'
BEGIN
	SELECT @StrSQL = N'SELECT QUOTENAME(''dbo'') As SchemaName, QUOTENAME([NAME]) As TableName  FROM ' + QuoteName(@sDbName) +'.'+'dbo.sysobjects where type = ''U'' and uid = 1 AND [NAME] NOT LIKE ''dt%'''
	

END

                           
	    --PRINT 'Inserting into temp table from ' + @sDbname

	    
	
		  --Insert the names into the temp table for processing
			INSERT INTO #TempTableList 
					(SchemaName,
					TableName)
			EXEC sp_executesql @StrSQL
			

		 --Declare the inner cursor to process each table
	
		IF @TableName IS NULL
			BEGIN
				    DECLARE TableCursor CURSOR FOR
					SELECT SchemaName,
                    					TableName 
				    FROM #TempTableList
			        ORDER BY TableName ASC
			END
			ELSE
				BEGIN


					DECLARE TableCursor CURSOR FOR
					SELECT SchemaName,
						   TableName 
				    	FROM #TempTableList
			        		WHERE TableName IN 
							(SELECT QUOTENAME(TabName) FROM #TableList)
					ORDER BY TableName ASC

														
				END

							  
			--Open and perform initial fetch
			--PRINT 'Opening table cursor on database: ' + @sDbname

			OPEN TableCursor
		
				
			FETCH TableCursor INTO @schmaName,@tblName

         --Save fetch status into local variable
           SELECT @InnerLoop = @@FETCH_STATUS

    WHILE @InnerLoop = 0
    BEGIN
            --Create the update statstics command and execute
	    IF @Scanflag=0
	    BEGIN
		    PRINT ('Updating stats on ' + QuoteName(@sDbname) +'.'+@schmaName+'.'+@tblName)+ ' WITH SAMPLE ' + CONVERT(VARCHAR(30),@Sample) + ' Percent'
	            SELECT @StrSQL = N'Update Statistics ' + QuoteName(@sDbname) +'.'+@schmaName+'.'+@tblName + ' WITH SAMPLE ' + CONVERT(VARCHAR(30),@Sample) + ' Percent'
	    END

	    ELSE
		BEGIN
	            PRINT ('Updating stats on ' + QuoteName(@sDbname) +'.'+@schmaName+'.'+@tblName)+ ' WITH FULLSCAN '
        	    SELECT @StrSQL = N'Update Statistics ' + QuoteName(@sDbname) +'.'+@schmaName+'.'+@tblName + ' WITH FULLSCAN '
		END

            
            EXEC sp_executesql @StrSQL
            

           --Fetch next table to process
           --PRINT 'Fetching next table'

	       FETCH TableCursor INTO @schmaName,@tblName

           --Save fetch status into local variable
           SELECT @InnerLoop = @@FETCH_STATUS
    END

    --Cleanup temp table and cursor
    --PRINT 'Truncating temp table and deallocating tables cursor'

    TRUNCATE TABLE #TempTableList

    CLOSE TableCursor
    DEALLOCATE TableCursor

	--Update the processed database status
	 UPDATE #TempDbList 
	 SET Process = 1
	 WHERE DBName = @sDbname  

    --Fetch next database
    --PRINT 'Fetching the next database'

    FETCH DBCursor into @sDbname

    --Save fetch status to local variable
    SELECT @OuterLoop = @@FETCH_STATUS


END

CLOSE DBCursor
DEALLOCATE DBCursor

DROP TABLE #TempTableList
DROP TABLE #TableList
DROP TABLE #TempDBList

GO


