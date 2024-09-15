<#
.SYNOPSIS
Gets all files above a specified file size (in MB) from a specified Directory in all User Directories on the computer.
.DESCRIPTION
Use the parameters to change the file size (in MB), set a Directory to search in the all User Directories, and specify an Out Path for the file .txt file will all the files above the specified size.  This file includes file name, Directory Path and File Size.

The script outputs a total file size amount found that matched the query.

This is an excellent tool for finding large files that are taking up space and may need to be deleted.
.PARAMETER FileSize
The size of the file (in MB) to query against (returns all files above this size).
.PARAMETER Directory
The Directory to search in all User Directories.  The Default is "Downloads", but it could be set to blank ("") to query all Directories.
.PARAMETER OutPath
The path you want the result file to be created.
.EXAMPLE
Get-UserFiles -FileSize 100 -Directory "Documents" -OutPath "C:\path\to\folder"
#>

#Parameters
param(
$FileSize = 100,
$Directory = 'Downloads',
$OutPath = 'C:\temp'
)

$filesum = 0
$paths = Get-ChildItem 'C:\Users'
$files = foreach ($path in $paths){
    Get-ChildItem -Recurse -Path "$path\$Directory" | 
    where-object -FilterScript {($_.Length / 1MB) -gt $filesize} | 
    Select-Object -Property Name, DirectoryName,
    @{name='File Size (MB)';expression={$_.Length / 1MB}} | 
    Sort-Object -Property 'File Size (MB)' -Descending
}

$date = Get-Date -Format "yyyy.MM.dd"
$files | out-file -FilePath `
"$OutPath\$date.$Env:ComputerName.User.Downloads.txt"

foreach ($file in $files) {
    $filesum += $file.'File Size (MB)'
}

Write-Output "$($files.count) total large files in User $Directory folders totalling $filesum MB on $Env:ComputerName"
