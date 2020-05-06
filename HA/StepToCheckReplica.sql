-- Add Step to check is HA Primary ?

USE msdb;
SET NOCOUNT ON; SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 

IF OBJECT_ID(N'tempdb.dbo.#data', N'U') IS NOT NULL DROP TABLE dbo.#data;
CREATE TABLE dbo.#data (id int IDENTITY PRIMARY KEY, name sysname);


-- Get all job names exclude jobs that already have a step named 'get_availability_group_role'
INSERT dbo.#data (name)
SELECT DISTINCT j.name--, s.step_name 
FROM dbo.sysjobs j --where description like '%{ABHADR}%'
    EXCEPT
SELECT DISTINCT j.name
FROM dbo.sysjobs j
INNER JOIN dbo.sysjobsteps s ON j.job_id = s.job_id
WHERE s.step_name = N'get_availability_group_role';

-- Remove jobs that need to run on any replica
DELETE FROM #data WHERE name LIKE 'SQL Sentry%';
DELETE FROM #data WHERE name LIKE 'syspolicy_purge_history';
DELETE FROM #data WHERE name LIKE 'DBA - Backup%';
--SELECT * FROM #data ORDER BY 1;


DECLARE @command varchar(max), @min_id int, @max_id int, @job_name sysname, @availability_group sysname;
SELECT  @min_id = 1, @max_id = (SELECT MAX(d.id) FROM #data AS d);

--SELECT @availability_group = (SELECT ag.name FROM sys.availability_groups ag);
SELECT @availability_group = 'ABHADR';

-- If this is instance does not belong to HA exit here
IF @availability_group IS NULL 
BEGIN;
    PRINT 'This instance does not belong to AG. Terminating.';
    RETURN;
END;


DECLARE @debug bit = 1; --<------ print only 

-- Loop through the table and execute/print the command per each job
WHILE @min_id <= @max_id
BEGIN;
        SELECT @job_name = name FROM dbo.#data AS d WHERE d.id = @min_id;

        SELECT @command = 
        'BEGIN TRAN;
        DECLARE @ReturnCode INT;
        EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_name=''' + @job_name + ''', @step_name=N''get_availability_group_role'', 
                @step_id=1, 
                @cmdexec_success_code=0, 
                @on_success_action=3, 
                @on_success_step_id=0, 
                @on_fail_action=3, 
                @on_fail_step_id=0, 
                @retry_attempts=0, 
                @retry_interval=0, 
                @os_run_priority=0, @subsystem=N''TSQL'', 
                @command=
        N''-- Detect if this instance''''s role is a Primary Replica.
-- If this instance''''s role is NOT a Primary Replica stop the job so that it does not go on to the next job step
DECLARE @rc int; 
EXEC @rc = master.dbo.fn_hadr_group_is_primary N''''' + @availability_group + ''''';

IF @rc = 0
BEGIN;
    DECLARE @name sysname;
    SELECT  @name = (SELECT name FROM msdb.dbo.sysjobs WHERE job_id = CONVERT(uniqueidentifier, $(ESCAPE_NONE(JOBID))));
    
    EXEC msdb.dbo.sp_stop_job @job_name = @name;
    PRINT ''''Stopped the job since this is not a Primary Replica'''';
END;'', 
        @database_name=N''master'', 
        @flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
BEGIN; 
    PRINT ''-- Rollback: ''''' + @job_name + ''''''' ROLLBACK TRAN; 
END;
ELSE COMMIT TRAN;' + CHAR(10) + 'GO';

        PRINT @command;
        IF @debug = 0 EXEC (@command);

    SELECT @min_id += 1;
END;





















----------------------------

