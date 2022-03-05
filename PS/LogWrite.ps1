$logfile = "C:\ADM\CopyFULL.log"

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

LogWrite "Bla-bla was written to $logfile"
