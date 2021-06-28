Get-NTFSAccess



Get-ChildItem -Path 'C:\Temp' -Recurse -Force |
ForEach-Object -Process {
$ACL = Get-Acl -Path $PSItem.FullName
Set-Acl -Path $PSItem.FullName -AclObject $ACL
 
Set-NTFSOwner -Account 'Administrator' -Path $PSItem.FullName
 
Clear-NTFSAccess -Path $PSItem.FullName
 
Enable-NTFSAccessInheritance -Path $PSItem.FullName
}