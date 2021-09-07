-- List XE Packages
select top 100 * from sys.dm_xe_packages 

select top 100 * from sys.dm_xe_objects 

select top 100 * from sys.server_event_sessions							-- Lists all event session definitions.
select top 100 * from sys.server_event_session_actions					-- Returns a row for each action on each event of an event session.
select top 100 * from sys.server_event_session_events					-- Returns a row for each event in an event session.
select top 100 * from sys.server_event_session_fields					-- Returns a row for each customizable column that was explicitly set on events and targets.
select top 100 * from sys.server_event_session_targets					-- Returns a row for each event target for an event session.

-- After session started
select top 100 * from sys.dm_os_dispatcher_pools						-- Returns information about session dispatcher pools.
select top 100 * from sys.dm_xe_objects									-- Returns a row for each object that is exposed by an event package.
select top 100 * from sys.dm_xe_object_columns							-- Returns the schema information for all the objects.
select top 100 * from sys.dm_xe_packages								-- Lists all the packages registered with the Extended Events engine.
select top 100 * from sys.dm_xe_sessions								-- Returns information about an active Extended Events session.
select top 100 * from sys.dm_xe_session_targets							-- Returns information about session targets.
select top 100 * from sys.dm_xe_session_events							-- Returns information about session events.
select top 100 * from sys.dm_xe_session_event_actions					-- Returns information about event session actions.
select top 100 * from sys.dm_xe_map_values								-- Provides a mapping of internal numeric keys to human-readable text.
select top 100 * from sys.dm_xe_session_object_columns					-- Shows the configuration values for objects that are bound to a session.

select top 1000 * from sys.dm_xe_packages p 
	join sys.dm_xe_objects o on o.package_guid = p.guid
	where  p.name = 'package0'

select map_value Keyword, * from sys.dm_xe_map_values  
where name = 'keyword_map'

select top 1000 * from sys.dm_xe_sessions