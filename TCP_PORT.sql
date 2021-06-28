-- Get PORT from connections
SELECT session_id,net_transport,local_net_address,local_tcp_port, client_net_address, client_tcp_port
FROM sys.dm_exec_connections;


-- Execute below script if SQL Server is configured with dynamic port number
DECLARE       @portNo   NVARCHAR(10)
  
EXEC   xp_instance_regread
@rootkey    = 'HKEY_LOCAL_MACHINE',
@key        =
'Software\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IpAll',
@value_name = 'TcpDynamicPorts',
@value      = @portNo OUTPUT
  
SELECT [PortNumber] = @portNo
GO

-- Execute below script if SQL Server is configured with static port number
DECLARE       @portNo   NVARCHAR(10)
  
EXEC   xp_instance_regread
@rootkey    = 'HKEY_LOCAL_MACHINE',
@key        =
'Software\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IpAll',
@value_name = 'TcpPort',
@value      = @portNo OUTPUT
  
SELECT [PortNumber] = @portNo
GO