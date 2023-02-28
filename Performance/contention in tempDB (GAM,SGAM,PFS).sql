Select session_id,
wait_type,
wait_duration_ms,
blocking_session_id,
resource_description,
      ResourceType = Case
When Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 1 % 8088 = 0 Then 'Is PFS Page'
            When Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 2 % 511232 = 0 Then 'Is GAM Page'
            When Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 3 % 511232 = 0 Then 'Is SGAM Page'
            Else 'Is Not PFS, GAM, or SGAM page'
            End
From sys.dm_os_waiting_tasks
Where wait_type Like 'PAGE%LATCH_%'
And resource_description Like '2:%'


Select session_id,
wait_type,
wait_duration_ms,
blocking_session_id,
resource_Description,
Descr.*
From sys.dm_os_waiting_tasks as waits inner join sys.dm_os_buffer_Descriptors as Descr
on LEFT(waits.resource_description, Charindex(':', waits.resource_description,0)-1) = Descr.database_id
and SUBSTRING(waits.resource_description, Charindex(':', waits.resource_description)+1,Charindex(':', waits.resource_description,Charindex(':', resource_description)+1)- (Charindex(':', resource_description)+1)) = Descr.[file_id]
and Right(waits.resource_description, Len(waits.resource_description) - Charindex(':', waits.resource_description, 3)) = Descr.[page_id]
Where wait_type Like 'PAGE%LATCH_%'