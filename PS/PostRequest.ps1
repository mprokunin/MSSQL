# How to male hppts POST request

$user = "my_login"
$pass= "my_pass"
$pair = "$($user):$($pass)"
$encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Pair))
$headers = @{ Authorization = "Basic $encodedCredentials" }
Invoke-WebRequest -Method POST -Uri https://abc.def.group/api/NT_Export_Buh_XML -ContentType 'application/xml' -UseBasicParsing -Infile POST.xml -TimeoutSec 1900 -Headers $headers

# Sample XML to send
<#
<?xml version="1.0"?>
   <data>
     <DateBegin>06.12.2021</DateBegin>
     <DateEnd>07.12.2021</DateEnd>
     <GroupByOper>1</GroupByOper>
     <FilePrefix>Foreign Brokers_ALL</FilePrefix>
</data>
#>
