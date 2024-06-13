[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$file1,
    [Parameter(Mandatory=$true)]
    [string]$file2,
    [Parameter(Mandatory=$true)]
    [string]$idField,
    [Parameter()]
    [ValidateSet("json","csv")]
    [string]$dataType = "json"
)

#Create PS Objects based on datatype
if($dataType -eq "json"){

    $original = get-content $file1 | ConvertFrom-Json
    $compare = get-content $file2 | ConvertFrom-Json

}else {

    $original = import-csv -Path $file1
    $compare = import-csv -Path $file2
}

#Function to compare two PS Objects and return the differences, including the ability to recursively search
function Compare-MyObjects {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [pscustomobject]$object1,
        [Parameter(Mandatory=$true)]
        [pscustomobject]$object2,
        [string]$recurse = ""
    )

#Loop through each object in the array of objects
foreach ($item in $object1){

    #Select the item to compare.  If being called recursively, selects object2
    if($recurse -eq ""){
    $compareItem = $object2 | where-object {$_.$idField -eq $item.$idField}
    }else {
        $compareItem = $object2
    }
    Write-Verbose "Getting CompareItem: $CompareItem"

    #Loop through all fields of the item
    $item | get-member -MemberType NoteProperty | foreach-object {
        $Name = $_.Name
       
        try {
            #Compare with case sensitve Not Equal
            if($Item.$Name -cne $compareItem.$Name){
                
                #If not being run recursively, set id variable to the id of the object
                if($recurse -eq ""){
                    $id = $Item.$idField
                }

                Write-Verbose "Testing $Name from $id"

                #Check if items being compared are both PS Objects, in which case we recursively run the function, else we create an object with differences
                if($Item.$Name -is [PSCustomObject] -and $compareItem.$Name -is [PSCustomObject]){
                    Write-Verbose "Entering Recurse for $Name and $id"
                    Compare-MyObjects -json1 $Item.$Name -json2 $compareItem.$Name -recurse ($recurse + $Name + ".") 
                }else {
                    Write-Verbose "Adding element from $Name and $id"
                     
                        [pscustomobject]@{
                        id = $id;
                        field = $recurse + $Name;
                        original = $Item.$Name;
                        change = $compareItem.$Name}
                }
                
                
            }#if
        }#try
        catch {
            Write-Verbose "Catch Statement called on $Name and $id"
             [pscustomobject]@{
                id = $compareItem.$idField;
                field = $Name;
                original = $Item.$Name;
                change = ""
            }
        }#catch 
        
    }#foreach-object
}#foreach



}

#run the function with the script input
Compare-MyObjects -json1 $original -json2 $compare
