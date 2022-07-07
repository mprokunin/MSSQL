# Copy files from InDir to OutDir by Mask

$InDir = "C:\TMP\IN"
$OutDir = "C:\TMP\OUT"

$Masks = 063876, 1069980, 1069984, 1070195, 1076323, 1082832, 1083094
$Shift = -2

$Year = "{0:yyyy}" -f (get-date).AddDays($Shift)
$DayBeforeYest = "{0:yyyyMMdd}" -f (get-date).AddDays($Shift)
$InDir = "$InDir\$Year"


$FileExists = Test-Path -Path "$OutDir\$DayBeforeYest" -PathType Container

if ($FileExists -eq $False) {
    echo Not Exists "$OutDir\$DayBeforeYest"
    New-Item -Path "$OutDir" -Name "$DayBeforeYest" -ItemType "directory"
}

$Indir = "$InDir\$DayBeforeYest"


foreach ($Mask in $Masks) {
    Get-ChildItem -Path "$InDir\*" -Include "$Mask*.htm" | Copy-Item -Destination $OutDir\$DayBeforeYest
    Get-ChildItem -Path "$InDir\*" -Include "$Mask*.xml" | Copy-Item -Destination $OutDir\$DayBeforeYest
}
