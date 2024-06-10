[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    $file1,
    [Parameter(Mandatory=$true)]
    $file2,
    [Parameter(Mandatory=$true)]
    $idField
)


$original = get-content $file1 | ConvertFrom-Json

$compare = get-content $file2 | ConvertFrom-Json

function Compare-MyJsonFiles {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [pscustomobject]$json1,
        [Parameter(Mandatory=$true)]
        [pscustomobject]$json2
    )

$notEqual = @()

foreach ($item in $json1){

    $compareItem = $json2 | where-object {$_.$idField -eq $item.idField}
    
    $item | get-member -MemberType NoteProperty | foreach-object {
        $Name = $_.Name
        try {
            if($Item.$Name -ne $compareItem.$Name){
                $notEqual += [ordered]@{
                    id = $compareItem.$id;
                    field = $Name;
                    orignal = $Item.$Name;
                    change = $compareItem.$Name
                }
            }
        }
        catch {
            $notEqual += [ordered]@{
                id = $compareItem.user_id;
                field = $Name;
                orignal = $Item.$Name;
                change = ""
            }
        }
        
    }
}

$notEqual

}

Compare-MyJsonFiles -json1 $original -json2 $compare
