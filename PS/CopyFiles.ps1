$srcpath = "F:\BACKUP\DBS-PURCB\DAB1\FULL"
$dstpath = "\\1.1.1.1\Backup\DIB\PURCB\FULL"

$logfile = "C:\ADM\CopyFULL.log"

Start-Transcript -Path $logfile

$src = Get-ChildItem -Recurse -path $srcpath
$dst = Get-ChildItem -Recurse -path $dstpath

#Compare-Object -ReferenceObject $src -DifferenceObject $dst

$i = 0
foreach ($file in $src) {
    $targetFile = $dst | where Name -eq $file.Name

    # this copies files which do not exist in the target
    if ($file.LastWriteTime -gt $targetFile.LastWriteTime) {
        Copy-Item $file.FullName $dstpath

        Write-Host "$file.FullName copied to $dstpath"

	$i += 1
    	if ($i -gt 4) {
	    break
    	}
    }
}

Stop-Transcript
