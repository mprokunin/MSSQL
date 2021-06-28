CREATE PROCEDURE sp_MShistory_cleanup  
(  
 @history_retention int = 24  
)  
AS  
BEGIN  
    DECLARE @cutoff_time datetime  
    ,@replerr_cutoff datetime  
    ,@start_time datetime  
    ,@num_snapshot_rows int  
    ,@num_logreader_rows int  
    ,@num_distribution_rows int  
    ,@num_replerror_rows int  
    ,@num_queuereader_rows int  
    ,@num_alert_rows int  
    ,@num_tracer_record_rows int  
    ,@num_milliseconds int  
    ,@num_seconds float  
    ,@seconds_str nvarchar(10)  
    ,@rate int  
    ,@retcode int  
    ,@total_rows int  
    ,@num_merge_rows int  
    ,@num_merge_deleted_articlehistory int  
    ,@agent_name nvarchar(255)  
    ,@agent_type nvarchar(100)  
    ,@message nvarchar(255)  
    ,@agent_id int  
    ,@error int  
  
    SET NOCOUNT ON  
  
    -- Check for invalid parameter values  
    IF @history_retention < 0  
    BEGIN  
        RAISERROR(14106, 16, -1)  
        RETURN 1  
    END  
      
    -- Get start time for statistics at the end  
 -- Get cutoff time  
 -- cleanup MSrepl_error with HistoryRetention+30 days  
    SELECT @start_time       = getdate(),  
   @num_snapshot_rows     = 0,  
   @num_logreader_rows     = 0,  
   @num_distribution_rows    = 0,  
   @num_merge_rows      = 0,  
   @num_replerror_rows     = 0,  
   @num_queuereader_rows    = 0,  
   @num_merge_deleted_articlehistory = 0,  
   @cutoff_time      = dateadd(hour, -@history_retention, getdate()),  
   @replerr_cutoff      = dateadd(hour, -@history_retention - 30*24, getdate())  
   
 DECLARE #crSnapshotAgents CURSOR LOCAL FAST_FORWARD FOR  
  SELECT id  
   FROM MSsnapshot_agents  
   
 OPEN #crSnapshotAgents  
   
 FETCH #crSnapshotAgents INTO @agent_id  
 WHILE @@FETCH_STATUS <> -1  
 BEGIN  
    
  -- Delete sp_MSsnapshot_history (leave at least one row for monitoring)  
  DELETE MSsnapshot_history   
   WHERE agent_id = @agent_id  
    AND time <= @cutoff_time   
    AND timestamp not in (SELECT max(timestamp)   
          FROM MSsnapshot_history   
          WHERE agent_id = @agent_id)  
   OPTION(MAXDOP 1)  
  
  SELECT @error = @@error, @num_snapshot_rows = @num_snapshot_rows + @@rowcount  
  IF @error <> 0  
   GOTO FAILURE  
  
  FETCH #crSnapshotAgents INTO @agent_id  
 END  
  
 CLOSE #crSnapshotAgents  
 DEALLOCATE #crSnapshotAgents  
  
    -- Delete sp_MSsnapshot_history that no longer has an MSsnapshot_agent entry  
    DELETE FROM MSsnapshot_history   
  WHERE NOT EXISTS (SELECT *   
       FROM MSsnapshot_agents  
       WHERE id = agent_id)  
  OPTION(MAXDOP 1)  
    SELECT @error = @@error, @num_snapshot_rows = @num_snapshot_rows + @@rowcount  
 IF @error <> 0  
  GOTO FAILURE  
  
    -- Delete sp_MSlogreader_history (leave at least one row for monitoring)  
 DECLARE #crLogreaderAgents CURSOR LOCAL FAST_FORWARD FOR  
  SELECT id  
   FROM MSlogreader_agents  
   
 OPEN #crLogreaderAgents  
   
 FETCH #crLogreaderAgents INTO @agent_id  
 WHILE @@FETCH_STATUS <> -1  
 BEGIN  
    
  -- Delete sp_MSsnapshot_history (leave at least one row for monitoring)  
  DELETE MSlogreader_history   
   WHERE agent_id = @agent_id  
    AND time <= @cutoff_time   
    AND timestamp not in (SELECT max(timestamp)   
          FROM MSlogreader_history   
          WHERE agent_id = @agent_id)  
   OPTION(MAXDOP 1)  
  SELECT @error = @@error, @num_logreader_rows = @num_logreader_rows + @@rowcount  
  IF @error <> 0  
   GOTO FAILURE  
  
  FETCH #crLogreaderAgents INTO @agent_id  
 END  
  
 CLOSE #crLogreaderAgents  
 DEALLOCATE #crLogreaderAgents  
  
    -- Delete sp_MSlogreader_history that no longer has an MSlogreader_agent entry  
 DELETE FROM MSlogreader_history   
  WHERE NOT EXISTS (SELECT *   
       FROM MSlogreader_agents  
       WHERE id = agent_id)  
  OPTION(MAXDOP 1)  
    SELECT @error = @@error, @num_logreader_rows = @num_logreader_rows + @@rowcount  
 IF @error <> 0  
  GOTO FAILURE  
  
    -- Delete sp_MSdistribution_history (leave at least one row for monitoring)  
 DECLARE #crDistribAgents CURSOR LOCAL FAST_FORWARD FOR  
  SELECT id  
   FROM MSdistribution_agents  
   
 OPEN #crDistribAgents  
   
 FETCH #crDistribAgents INTO @agent_id  
 WHILE @@FETCH_STATUS <> -1  
 BEGIN  
    
  -- Delete sp_MSsnapshot_history (leave at least one row for monitoring)  
  DELETE MSdistribution_history   
   WHERE agent_id = @agent_id  
    AND time <= @cutoff_time   
    AND timestamp not in (SELECT max(timestamp)   
          FROM MSdistribution_history   
          WHERE agent_id = @agent_id)  
   OPTION(MAXDOP 1)  
  SELECT @error = @@error, @num_distribution_rows = @num_distribution_rows + @@rowcount  
  IF @error <> 0  
   GOTO FAILURE  
  
  FETCH #crDistribAgents INTO @agent_id  
 END  
  
 CLOSE #crDistribAgents  
 DEALLOCATE #crDistribAgents  
  
    -- Delete sp_MSlogreader_history that no longer has an MSlogreader_agent entry  
 DELETE FROM MSdistribution_history   
  WHERE NOT EXISTS (SELECT *   
       FROM MSdistribution_agents  
       WHERE id = agent_id)  
  OPTION(MAXDOP 1)  
    SELECT @error = @@error, @num_distribution_rows = @num_distribution_rows + @@rowcount  
 IF @error <> 0  
  GOTO FAILURE  
  
    -- Delete MSqreader_history (leave at least one row for monitoring)  
 DECLARE #crQreaderAgents CURSOR LOCAL FAST_FORWARD FOR  
  SELECT id  
   FROM MSqreader_agents  
   
 OPEN #crQreaderAgents  
   
 FETCH #crQreaderAgents INTO @agent_id  
 WHILE @@FETCH_STATUS <> -1  
 BEGIN  
    
  -- Delete sp_MSsnapshot_history (leave at least one row for monitoring)  
  DELETE MSqreader_history   
   WHERE agent_id = @agent_id  
    AND time <= @cutoff_time   
    AND timestamp not in (SELECT max(timestamp)   
          FROM MSqreader_history   
          WHERE agent_id = @agent_id)  
   OPTION(MAXDOP 1)  
  SELECT @error = @@error, @num_queuereader_rows = @num_queuereader_rows + @@rowcount  
  IF @error <> 0  
   GOTO FAILURE  
  
  FETCH #crQreaderAgents INTO @agent_id  
 END  
  
 CLOSE #crQreaderAgents  
 DEALLOCATE #crQreaderAgents  
  
    -- Delete sp_MSlogreader_history that no longer has an MSlogreader_agent entry  
 DELETE FROM MSqreader_history   
  WHERE NOT EXISTS (SELECT *   
       FROM MSqreader_agents  
       WHERE id = agent_id)  
  OPTION(MAXDOP 1)  
    SELECT @error = @@error, @num_queuereader_rows = @num_queuereader_rows + @@rowcount  
 IF @error <> 0  
  GOTO FAILURE  
  
    -- Delete sp_MSmerge_history (leave at least one row for monitoring)  
    -- Leave last record ONLY if the agent is not anonymous.  The current logic is to remove all history for anonymous  
    -- subscription, the agent definition will also be removed below.  
    -- use session id  
    DELETE dbo.MSmerge_history  
  FROM dbo.MSmerge_history msmh  
   JOIN dbo.MSmerge_sessions msms   
    ON msmh.session_id = msms.session_id  
  WHERE msms.end_time <= @cutoff_time  
  OPTION(MAXDOP 1)  
    SELECT @error = @@error, @num_merge_rows = @num_merge_rows + @@rowcount  
    IF @error <> 0  
  GOTO FAILURE  
  
    -- Delete sp_MSmerge_history that no longer has an MSmerge_agent entry  
    DELETE FROM dbo.MSmerge_history   
  WHERE NOT EXISTS (SELECT *   
       FROM dbo.MSmerge_agents   
       WHERE id = agent_id)  
  OPTION(MAXDOP 1)  
    SELECT @error = @@error, @num_merge_rows = @num_merge_rows + @@rowcount  
    IF @error <> 0  
  GOTO FAILURE  
  
    -- Delete MSrepl_error entries  
    DELETE FROM MSrepl_errors   
  WHERE time <= @replerr_cutoff   
  OPTION(MAXDOP 1)  
    SELECT @error = @@error, @num_replerror_rows = @@rowcount  
    IF @error <> 0  
  GOTO FAILURE  
  
 -- similiar to above time based cleanup, we need to clean up added tables  
 DELETE dbo.MSmerge_articlehistory  
  FROM dbo.MSmerge_articlehistory msmah   
   JOIN dbo.MSmerge_sessions msms  
    ON msmah.session_id = msms.session_id  
  WHERE msms.end_time <= @cutoff_time  
  OPTION(MAXDOP 1)  
 SELECT @error = @@error, @num_merge_deleted_articlehistory = @num_merge_deleted_articlehistory + @@rowcount  
    IF @error <> 0  
  GOTO FAILURE  
          
    DELETE FROM dbo.MSmerge_sessions   
  WHERE end_time <= @cutoff_time  
   AND session_id NOT IN (SELECT max(session_id)   
         from dbo.MSmerge_sessions   
         group by agent_id)  
  OPTION(MAXDOP 1)  
    SELECT @error = @@error, @num_merge_rows = @num_merge_rows + @@rowcount  
    IF @error <> 0  
  GOTO FAILURE  
          
    -- Delete MSmerge_sessions that no longer has an MSmerge_agent entry  
    DELETE FROM dbo.MSmerge_sessions   
  WHERE NOT EXISTS (SELECT *   
       FROM dbo.MSmerge_agents   
       WHERE id = agent_id)  
  OPTION(MAXDOP 1)  
    SELECT @error = @@error, @num_merge_rows = @num_merge_rows + @@rowcount  
    IF @error <> 0  
  GOTO FAILURE  
    
 -- Delete sysreplicationalerts table  
    DELETE FROM msdb.dbo.sysreplicationalerts   
  WHERE time <= @cutoff_time   
  OPTION(MAXDOP 1)  
    SELECT @error = @@error, @num_alert_rows = @@rowcount  
    IF @error <> 0  
  GOTO FAILURE  
  
 -- Delete Tracer Record history rows  
 EXEC @error = sys.sp_MSdelete_tracer_history @cutoff_date = @cutoff_time, @num_records_removed = @num_tracer_record_rows output  
 IF @error <> 0  
        GOTO FAILURE  
  
    -- Calculate statistics for number of rows deleted  
    SELECT @num_milliseconds = datediff(millisecond, @start_time, getdate())  
    IF @num_milliseconds <> 0  
        SELECT @num_seconds = @num_milliseconds*1.0/1000  
    ELSE  
        SELECT @num_seconds = 0  
  
    SELECT @total_rows = @num_merge_rows +   
          @num_merge_deleted_articlehistory +  
          @num_snapshot_rows +   
       @num_logreader_rows +   
       @num_distribution_rows +    
       @num_queuereader_rows +  
       @num_replerror_rows +   
       @num_alert_rows +   
       @num_tracer_record_rows  
  
    IF @num_seconds <> 0   
        SELECT @rate = @total_rows/@num_seconds  
    ELSE  
        SELECT @rate = @total_rows  
  
    SELECT @seconds_str = CONVERT(nchar(10), @num_seconds)  
  
    RAISERROR(14108, 10, -1, @num_merge_rows, 'MSmerge_history')  
 RAISERROR(14108, 10, -1, @num_merge_deleted_articlehistory, 'MSmerge_articlehistory')  
 RAISERROR(14108, 10, -1, @num_snapshot_rows, 'MSsnapshot_history')  
    RAISERROR(14108, 10, -1, @num_logreader_rows, 'MSlogreader_history')  
    RAISERROR(14108, 10, -1, @num_distribution_rows, 'MSdistribution_history')  
    RAISERROR(14108, 10, -1, @num_queuereader_rows, 'MSqreader_history')  
    RAISERROR(14108, 10, -1, @num_replerror_rows, 'MSrepl_errors')  
    RAISERROR(14108, 10, -1, @num_alert_rows, 'sysreplicationalerts')  
    RAISERROR(14108, 10, -1, @num_tracer_record_rows, 'MStracer_tokens')  
 RAISERROR(14149, 10, -1, @total_rows, @seconds_str, @rate)  
      
    RETURN 0  
FAILURE:  
    -- Raise the Agent Failure error  
    SELECT @agent_type  = formatmessage(20544),  
   @agent_name = db_name() + @agent_type,  
   @message = formatmessage(20553)  
  
    EXEC sys.sp_MSrepl_raiserror @agent_type, @agent_name, 5, @message  
  
    RETURN 1  
END  
  