Dim conn 
Set conn = createobject("Adodb.Connection")
Dim sConnString
Dim SqlStatement

StartScript

Sub StartScript()

' sSourceServer = InputBox ("Enter the name of the SQL Server","Enter SQL Server Name","")
'    If Len(sSourceServer) = 0 Then
'        MsgBox "No SQL Server was specified.", , "Unable to Continue"
'        Exit Sub
'    End if

'sSourceDB = InputBox ("Enter the name of the Law SQL Database","Enter Law SQL DB Name","")
'    If Len(sSourceDB) = 0 Then
'        MsgBox "No SQL DB was specified.", , "Unable to Continue"
'        Exit Sub
'    End if

sSourceServer = "MyServer.abc.local"
sSourceDB = "master"

' Create the connection string.
sConnString = "Provider=SQLOLEDB;Data Source=" & sSourceServer & "; Initial Catalog=" & sSourceDB & "; Integrated Security=SSPI;"

' Open the connection and execute.
conn.Open sConnString
conn.CommandTimeout = 900

SqlStatement = "update DAB1.dbo.AlsConst set value_digit = 1 where id =  16797442" 

conn.Execute(SqlStatement)

conn.Close
Set rs = Nothing
SqlStatement = vbNullString

End Sub

' MsgBox "All Done! Go Check your results!"
