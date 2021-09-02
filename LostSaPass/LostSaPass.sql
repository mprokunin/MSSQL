-- We need to start SQL Server in single user mode by adding the parameter -m or –f in the startup parameters. 
-- Open SQL Server configuration manager and select the service of SQL Server instance. Right-click and click on the Properties option.
-- After adding the startup parameter, click on the Apply button and then the OK button in the warning message window.

-- Restart the SQL Server service to start SQL Server in single user mode. 
-- When the SQL Server is started in single user mode, all the users who are a member of the host’s local administrator group can connect to SQL Server instance 
-- and they will gain the privileges of server level role sysadmin which helps us to recover SA password.
-- So, if you are a member of the local administrator group, you can connect to SQL Server instance using SQLCMD.
-- Launch the Command Prompt and connect to SQL Server using SQLCMD. You would be able to successfully connect to the SQL Server instance.

C:\Users\Administrator> SQLCMD -S localhost
1> CREATE LOGIN NewSA WITH PASSWORD = 'Password@1234';
2> GO
3> ALTER SERVER ROLE sysadmin ADD MEMBER NewSA
4> GO

-- Remove the startup parameter -m or -f that is added and restart the SQL Server services. Now, SQL Server instance is started in the multi-user mode and has the login that you created above. Please refer to the below image that shows the connection is established using NewSA login which is created above.



