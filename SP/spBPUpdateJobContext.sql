USE [BP]
GO
/****** Object:  StoredProcedure [dbo].[spBPUpdateJobContext]    Script Date: 19.07.2018 12:17:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
ALTER proc [dbo].[spBPUpdateJobContext] (                          
    @pJobID               int                      
  , @pBPID                int                      
  , @pStepID              int                      
  , @pOperDate            datetime                      
  , @pIsSendNotification  int = 0                      
  , @SysUserInfo          varchar(255) = null        
  , @ServerName           varchar(255) = null        
)                      
AS BEGIN                      
                      
/*                      
  CREATED: 2008-09-10/akravckenko - (BP) изменяем строку в BPJobContext для заданного джобв                      
*/                      
                      
set nocount on                      

set @ServerName = case when @pBPID is not null then coalesce( @ServerName, @@servername ) else null end
                     
declare @Wait               int   set @Wait               = 0   -- Ждет запуска                      
declare @Working            int   set @Working            = 1   -- Исполняется                      
declare @Success            int   set @Success            = 2   -- Успешно отработал                      
declare @Error              int   set @Error              = 3   -- Отработал с ошибкой                      
declare @Canceled           int   set @Canceled           = 4   -- Выполнение было вручную прервано                      
declare @Rollbacked         int   set @Rollbacked         = 5   -- Откат выполнен                      
declare @Rollbacking        int   set @Rollbacking        = 6   -- Выполняется откат шага                      
declare @StartRequired      int   set @StartRequired      = 7   -- Запрошен безусловный старт                      
declare @RollbackRequired   int   set @RollbackRequired   = 8   -- Запрошен откат шага                      
declare @Stopped            int   set @Stopped            = 9   -- Остановлено выполнение шагов (это статус всего BP, а не отдельного шага)                      
                      
if isnull( @pIsSendNotification, 0 ) = 1 begin                      
                      
  declare @OperDate datetime, @BPID int, @StepID int, @State int, @Initiator varchar(20), @Comment varchar(max)                
  select @OperDate = h.OperDate, @BPID = h.BPID, @StepID = h.StepID, @State = h.State, @Initiator = h.Initiator, @Comment = isnull( rtrim(ltrim(h.Comment)), '' )                
    from BPJobContext x join BPStepDayHistory h on h.OperDate = x.OperDate and h.BPID = x.BPID and h.StepID = x.StepID                      
      where x.JobID = @pJobID                       
                      
  if @BPID is not null and @StepID is not null and @OperDate is not null begin                      
                      
  declare @BPName varchar(255)                      
  select @BPName = isnull( BPName, '???' ) from BP where BPID = @BPID                      
                      
  declare @StepName varchar(255)                      
  select @StepName = isnull( StepName, '???' ) from BPStep where BPID = @BPID and StepID = @StepID                      
                      
  declare @UserName varchar(255)                      
  select @UserName = coalesce( FullName, [Name] ) from DbUser where [Name] = @Initiator                      
                      
  declare @subj varchar(255), @body varchar(max)                      
  set @subj = '(BP) Шаг "' + isnull( @StepName, 'NULL' ) + '" бизнес-процесса "' + isnull( @BPName, 'NULL' ) + '" - ' +        
  case @State                       
                      
    when @Wait                      
    then 'ожидает запуска'                       
                      
    when @Success                       
    then 'выполнен'             + case when @UserName is not null then ' пользователем ' + @UserName else ' автоматически'  end                       
                      
    when @Canceled                       
    then 'снят'                 + case when @UserName is not null then ' пользователем ' + @UserName else ''                end                      
                      
    when @Rollbacked                 
    then 'откачен'              + case when @UserName is not null then ' пользователем ' + @UserName else ''                end                      
                          
    when @Error                      
    then 'выполнен с ошибками'  + case when @UserName is not null then ' пользователем ' + @UserName else ''                end                      
                              
    else 'статус неопределен'                       
                      
  end                        
                      
  declare @recip varchar(max)                  
                    
  declare @Mode int                  
  set @Mode = case @State when @Success then 2 else 1 end                  
                    
  declare @InfoType int                   
  set @InfoType = case @State when @Success then 2 else 3 end                  
                    
  set @Mode = 1 -- временно                  
  --set @InfoType = 2                  
  exec spBPGetRecipient @pBPID = @BPID, @pStepID = @StepID, @pInfoType = @InfoType, @pMode = @Mode, @pRecip = @recip OUTPUT                      
  if @State in ( @Success, @Canceled, @Rollbacked, @Error ) begin                      
    --if isnull( @recip, '' ) != '' begin                       
      set @body = @subj + char(13) + char(10) + char(13) + char(10) + @Comment                
      begin try             
        --exec msdb.dbo.sp_send_dbmail @recipients = @recip, @subject = @subj, @body = @body             
        exec dbo.spBPNotif @pBPID = @BPID, @pStepID = @StepID, @pState = @State, @pRecip = @recip, @pSubj = @subj, @pBody = @body, @pIsMail = 1, @pIsNotif = 1, @pIsDebug = 0            
      end try begin catch           
        declare @s1 nvarchar(2048)          
        set @s1 = error_message()          
        raiserror( @s1, 12, 1 )          
      end catch                      
    --end                      
  end                      
                      
  end                      
                      
end -- @pIsSendNotification                  
                      
update BPJobContext                       
  set OperDate = @pOperDate, BPID = @pBPID, StepID = @pStepID, ServerName = @ServerName                      
    where JobID = @pJobID                      
                      
END 

select top 10 * from BPJobContext