<#
.Synopsis
   Copy Files from a source Folder to a Destination recursively using powershell
.DESCRIPTION
   Copy Files from a source Folder to a Destination recursively and setting up the date attributes equals to the original file (and folders), and preserving permissions (optional) from the source folders to target ones using PowerShell
.EXAMPLE
   CopyNsetDates.ps1 -source "D:\CloudOD\OneDrive\Soporte Curriculum" -target "D:\Cloud\Dropbox\Desktop\destTest"
   Default Behavior, copy all from folder 'source' to the destination, preserving dates within the files and folders. Receiving 1 notification each 10 files moved/existing

.EXAMPLE
   CopyNsetDates.ps1 -source "D:\CloudOD\OneDrive\Soporte Curriculum" -target "D:\Cloud\Dropbox\Desktop\destTest" -NTFS
   Default Behavior, copy all from folder 'source' to the destination, preserving dates within the files and folders. Receiving 1 notification each 10 files moved/existing, and the -NTFS switch will preserve the NTFS permissions between the 2 folders.

.EXAMPLE
   CopyNsetDates.ps1 -source "D:\CloudOD\OneDrive\Soporte Curriculum" -target "D:\Cloud\Dropbox\Desktop\destTest" -NFiles 50 
   Same as previously but with less notifications. (1 notification each 50 files Moved/Existing

.EXAMPLE
   CopyNsetDates.ps1 -source "D:\CloudOD\OneDrive\Soporte Curriculum" -target "F:\CopyTest"  -NoMatch "MVA"
   Copy all folders that doesn't contains the "MVA" string (no case sensitive) from source to target.

.EXAMPLE
    CopyNsetDates.ps1 -source "D:\CloudOD\OneDrive\Soporte Curriculum" -target "F:\CopyTest"  -Match "MS" -Nfiles 5
    Copy all folders from source to target that contains "MS" in the name (meaning that Mathes ms).
.EXAMPLE
    CopyNsetDates.ps1 -source "D:\CloudOD\OneDrive\Soporte Curriculum" -target "F:\CopyTest"  -NoMatch "MVA" -NFiles 100
    Copy all the files that doesn't match "MVA" in the name. And obtain a notification each 100 files.

.INPUTS
    Mandatory
    Source: Source Folder Path
    Target: Target Folder path

    Optionals
    NTFS: It's the paremeter that execute the copy of the NTFS privilegies from source to target.
    NFiles: Integer, When you're moving a lot of data, set this variable to get a notification each "NFILES", the bigger (less frequent), the less (more frequent). Default value 10. So each 10 files moved you'll get 1 notification
    Match (Name or partial string): Matches the 1sti folder with this pattern and start copying from there. (Persist the folders structure in the new target
    NoMatch: Save every folder except those that maches the $NoMatch string.

.OUTPUTS
   The only output is a log file "copy.log" within the same path of the script
.NOTES
   Autor: Jose Gabriel Ortega C.
   Version: 1.0
   Release date: 11/07/2017
   Version: 2.0
   Release Date 11/12/2017
.COMPONENT
   This script doesn't belongs to any component
.ROLE
   This cmdlet doesn't belongs to any role 
.FUNCTIONALITY
   This CMDLET is similar to xcopy apply robocopy but with setting up the Date (Creation,Modify) in the new file.
#>

[CmdletBinding(DefaultParameterSetName="Full")]
param(
    [Parameter(Mandatory=$true,Position=0)]$source,
    [Parameter(Mandatory=$true,Position=1)]$target,
    [Parameter(Mandatory=$false,Position=2)][switch]$NTFS,

    [Parameter(Mandatory=$false,position=3)][ValidateRange(1,1000000)][int]$Nfiles=10,
    [Parameter(Mandatory=$false,Position=4,ParameterSetName="match")][Alias("pattern")]$Match=$null,
    [Parameter(Mandatory=$false,Position=4,ParameterSetName="NoMatch")]$NoMatch=$null
)
#GLOBALs 
$global:ScriptLocation = $(get-location).Path
$global:DefaultLog = "$global:ScriptLocation\copy.log"
[int]$GLOBAL:Unicount=0 #variable to count operations with files

[int]$GLOBAL:FilesCopied=0 #variable to determine the files that have been copied
[int]$GLOBAL:FilesExisting=0   #variable to determine the existing files
[int]$GLOBAL:TotalDirectories=0  #variable to determine the number of directories created

#region Functions
function Write-Log{
    [CmdletBinding()]
    #[Alias('wl')]
    [OutputType([int])]
    Param(
            # The string to be written to the log.
            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] [ValidateNotNullOrEmpty()] [Alias("LogContent")] [string]$Message,
            # The path to the log file.
            [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true,Position=1)] [Alias('LogPath')] [string]$Path=$global:DefaultLog,
            [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true,Position=2)] [ValidateSet("Error","Warn","Info","Load","Execute")] [string]$Level="Info",
            [Parameter(Mandatory=$false)] [switch]$NoClobber
    )

     Process{
        
        if ((Test-Path $Path) -AND $NoClobber) {
            Write-Warning "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."
            Return
            }

        # If attempting to write to a log file in a folder/path that doesn't exist
        # to create the file include path.
        elseif (!(Test-Path $Path)) {
            Write-Verbose "Creating $Path."
            $NewLogFile = New-Item $Path -Force -ItemType File
            }

        else {
            # Nothing to see here yet.
            }

        # Now do the logging and additional output based on $Level
        switch ($Level) {
            'Error' {
                Write-Warning $Message
                Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") ERROR: `t $Message" | Out-File -FilePath $Path -Append
                }
            'Warn' {
                Write-Warning $Message
                Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") WARNING: `t $Message" | Out-File -FilePath $Path -Append
                }
            'Info' {
                Write-Host $Message -ForegroundColor Green
                Write-Verbose $Message
                Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") INFO: `t $Message" | Out-File -FilePath $Path -Append
                }
            'Load' {
                Write-Host $Message -ForegroundColor Magenta
                Write-Verbose $Message
                Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") LOAD: `t $Message" | Out-File -FilePath $Path -Append
                }
            'Execute' {
                Write-Host $Message -ForegroundColor Green
                Write-Verbose $Message
                Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") EXEC: `t $Message" | Out-File -FilePath $Path -Append
                }
            }
    }
}
function Copy-Info{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,mandatory=$true)] [string]$sourceDir,
        [Parameter(Position=1,mandatory=$true)] [string]$targetDir,
        [Parameter(Position=2,mandatory=$false)] [switch]$NTFS=$false
    )
    BEGIN{
        [int]$counter=0;
        [int]$LogCounter=0;
        [bool]$IsMultipleOfNFiles=$false

        if(! [System.IO.Directory]::Exists($targetDir) ){
           [System.IO.Directory]::CreateDirectory($targetDir) | Out-Null
            Set-DateAttributes -OriginalFilePath $sourceDir -TargetFilePath $targetDir -folder
            #add 1 directory to the total
            $GLOBAL:TotalDirectories++
            Write-Log -Level Load -Message "Folder ""$targetDir"" created..."
        }
    }
    PROCESS{
        foreach($file in [System.IO.Directory]::GetFiles($sourceDir) ){
            #generalcounter
            $GLOBAL:Unicount=$GLOBAL:FilesCopied+ $GLOBAL:FilesExisting + 1;

            $FilePath=[System.IO.Path]::Combine($targetDir, [System.IO.Path]::GetFileName($file))
            $FileInfoNew = new-object System.IO.FileInfo($file)

            if( ($GLOBAL:Unicount)%$Nfiles -eq 0  ){
                $IsMultipleOfNFiles = $true
            }
            else{
                $IsMultipleOfNFiles = $false
            }

            if(![System.IO.File]::Exists($FilePath) ){ #IF doesn't exists, add to the copiedfiles copy the file and set attributes
                [System.IO.File]::Copy($file, $FilePath)
                Set-DateAttributes -OriginalFilePath $file -TargetFilePath $FilePath
                $GLOBAL:FilesCopied++
            }
            else{
			    $FileInfoExisting = new-object System.IO.FileInfo($FilePath)
			    $FileInfoNew      = new-object System.IO.FileInfo($file)
                $GLOBAL:FilesExisting++
                #setattributes
                Set-DateAttributes -OriginalFilePath $file -TargetFilePath $FilePath
            }

            if($IsMultipleOfNFiles){
                Write-Log -Level Info -Message "Writing ""$FilePath""`tCreatedDirectories:$GLOBAL:TotalDirectories`tCopied:$GLOBAL:FilesCopied`tExisting:$GLOBAL:FilesExisting"
            }
        }
        #if ntfs parameter is given then assign the privilegies from Sourcedir to TargetDir
        if($NTFS){
            Copy-Privilegies -OFolder $sourceDir -TFolder $targetDir
        }

        foreach($dir in [System.IO.Directory]::GetDirectories($sourceDir) ){
            $test = [System.IO.Path]::Combine($targetDir, (New-Object -TypeName System.IO.DirectoryInfo -ArgumentList $dir).Name)
            Copy-Info -sourceDir $dir -targetDir $test
            Set-DateAttributes -OriginalFilePath $dir -TargetFilePath $test -folder
            #GetandSetACL -OriginalFilePath $dir -TargetFilePath $test
        }
    }
    END{}
    

    #get source files
    
 }
function Copy-InfoNoMatch{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,mandatory=$true)] [string]$sourceDir,
        [Parameter(Position=1,mandatory=$true)] [string]$targetDir,
        [Parameter(Position=2,mandatory=$true)] [string]$NoMatch,
        [Parameter(Position=3,mandatory=$false)] [switch]$NTFS
    )
    BEGIN{
        [int]$counter=0;
        [int]$LogCounter=0;
        [bool]$IsMultipleOfNFiles=$false

        if($sourceDir.Split('\')[-1] -notmatch $NoMatch -and (! [System.IO.Directory]::Exists($targetDir)) ){
            [System.IO.Directory]::CreateDirectory($targetDir) | Out-Null
            Set-DateAttributes -OriginalFilePath $sourceDir -TargetFilePath $targetDir -folder
            #add 1 directory to the total
            $GLOBAL:TotalDirectories++
            Write-Log -Level Load -Message "Folder ""$targetDir"" created..."
        }
      
        
    }
    PROCESS{

        
            foreach($dir in [System.IO.Directory]::GetDirectories($sourceDir) ){
                if($dir.Split('\')[-1] -notmatch $NoMatch){
                    $test = [System.IO.Path]::Combine($targetDir, (New-Object -TypeName System.IO.DirectoryInfo -ArgumentList $dir).Name)
                    Copy-Info -sourceDir $dir -targetDir $test -NTFS:$NTFS
                    Set-DateAttributes -OriginalFilePath $dir -TargetFilePath $test -folder
                    
                }
             }
            foreach($file in [System.IO.Directory]::GetFiles($sourceDir) ){
                #generalcounter
                $GLOBAL:Unicount=$GLOBAL:FilesCopied+ $GLOBAL:FilesExisting + 1;

                $FilePath=[System.IO.Path]::Combine($targetDir, [System.IO.Path]::GetFileName($file))
                $FileInfoNew = new-object System.IO.FileInfo($file)

                if( ($GLOBAL:Unicount)%$Nfiles -eq 0  ){
                    $IsMultipleOfNFiles = $true
                }
                else{
                    $IsMultipleOfNFiles = $false
                }

                if(![System.IO.File]::Exists($FilePath) ){ #IF doesn't exists, add to the copiedfiles copy the file and set attributes
                    [System.IO.File]::Copy($file, $FilePath)
                    Set-DateAttributes -OriginalFilePath $file -TargetFilePath $FilePath
                    #GetandSetACL -OriginalFilePath $file -TargetFilePath $FilePath
                    $GLOBAL:FilesCopied++
                }
                else{
			        $FileInfoExisting = new-object System.IO.FileInfo($FilePath)
			        $FileInfoNew      = new-object System.IO.FileInfo($file)
                    $GLOBAL:FilesExisting++
                    #setattributes
                    Set-DateAttributes -OriginalFilePath $file -TargetFilePath $FilePath
                }

                if($IsMultipleOfNFiles){
                    Write-Log -Level Info -Message "Writing ""$FilePath""`tCreatedDirectories:$GLOBAL:TotalDirectories`tCopied:$GLOBAL:FilesCopied`tExisting:$GLOBAL:FilesExisting"
                }
            }
    }
    END{}
    

    #get source files
    
 }
function Set-DateAttributes{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]$OriginalFilePath,
        [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$true)]$TargetFilePath,
        [Parameter(Mandatory=$false,Position=2,ValueFromPipeline=$true)][switch]$folder
    )
    BEGIN{
        [int]$logcounter=0
    }
    PROCESS{
        if(!($folder)){
            [System.IO.FileInfo] $fi = New-Object System.IO.FileInfo -ArgumentList $originalFilePAth
            [System.IO.File]::SetCreationTime($targetFilePath,$fi.CreationTime)
            [System.IO.File]::SetLastWriteTime($TargetFilePath,$fi.LastWriteTime)
            [System.IO.File]::SetLastAccessTime( $TargetFilePath,$fi.LastAccessTime)
        }
        else{
            [System.IO.DirectoryInfo]$di = New-Object System.IO.DirectoryInfo -ArgumentList $OriginalFilePath
            [System.IO.Directory]::SetCreationTime($TargetFilePath,$di.CreationTime)
            [System.IO.Directory]::SetLastWriteTime($TargetFilePath,$di.LastWriteTime)
            [System.IO.Directory]::SetLastAccessTime($TargetFilePath,$di.LastAccessTime)
        }
    }
    END{
        
    }
}
function Copy-PrivilegiesRecursively{            
	[cmdletbinding()]            
	param(
		[Parameter(Mandatory=$true,position=0)][string]$OFolder,
        [Parameter(Mandatory=$true,position=0)][string]$TFolder
	)
	BEGIN{}
	PROCESS{
		Copy-Privilegies -OFolder $folder -TFolder $TFolder
		$HomeFolders = Get-ChildItem $folder -Directory
		if($HomeFolders.Count -gt 0){
			
			foreach ($HomeFolder in $HomeFolders) {
				$fn = $HomeFolder.FullName
				SetFolderPrivilegies $fn
			}
		}
	}
	END{}
} 
function Copy-Privilegies{            
	[cmdletbinding()]            
	param(
		[Parameter(Mandatory=$true,position=0)][string]$OFolder,
        [Parameter(Mandatory=$true,position=0)][string]$TFolder
	)
	BEGIN{
        $OAcl = (Get-Item $OFolder).GetAccessControl('Access')
        $Tacl = (Get-Item $TFolder).GetAccessControl('Access')
	}
	PROCESS{
            #Set Privilegies from the Source $OACL to the Target $TFolder.
		    Set-Acl -path $TFolder -AclObject $OAcl 
	}
	END{}
} 
function find-RootFolderPattern{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]$source,
        [Parameter(Mandatory=$true,Position=1)][Alias("pattern")]$Match=$null
    )
    BEGIN{
        $wasFound=$false
        $out=$null
    }
    PROCESS{
        $folders = [System.IO.Directory]::GetDirectories($source)
        if($folders.count -gt 0){
            foreach($folder in $folders){
                if( ($folder.split("\")[-1] -match $Match) -and (!$wasFound) ){
                    $wasFound=$true;
                    $out=$folder
                    break;
                }
            }
        }
        else{
            find-RootFolderPattern $source
        }

        
        
    }
    END{
        return $folder
    }
}
#endregion


#STARTSCRIPT



switch ($PsCmdlet.ParameterSetName) {
    "Full"{
        #.\CopyNsetDates.ps1 -source "D:\CloudOD\OneDrive\Soporte Curriculum" -target "F:\CopyTest" -Nfiles 30
        #Set-DateAttributes -OriginalFilePath "D:\CloudOD\OneDrive\Soporte Curriculum\Taller-Big-Data.pdf" -TargetFilePath "D:\Cloud\Dropbox\Desktop\123\Taller-Big-Data.pdf"
        Copy-Info -sourceDir $source -targetDir $target -NTFS:$NTFS
    }
    "Match" {
        #.\CopyNsetDates.ps1 -source "D:\CloudOD\OneDrive\Soporte Curriculum" -target "F:\CopyTest"  -Match "MS" -Nfiles 5
        $folder =find-RootFolderPattern -source $source  -Match $Match
        $newTarget = $target + "\" + $folder.split('\')[-1]
        Copy-Info -sourceDir $folder -targetDir $newTarget -NTFS:$NTFS

    }
    "NoMatch" {
        #.\CopyNsetDates.ps1 -source "D:\CloudOD\OneDrive\Soporte Curriculum" -target "F:\CopyTest"  -NoMatch "MVA"
        Copy-InfoNoMatch -sourceDir $source -targetDir $target -NoMatch $NoMatch -NTFS:$NTFS
    }
}



Write-Log -Level Info -Message "CreatedDirectories:$GLOBAL:TotalDirectories`tCopied:$GLOBAL:FilesCopied`tExisting:$GLOBAL:FilesExisting"
