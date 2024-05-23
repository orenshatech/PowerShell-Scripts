$computer = hostname
$edgeExtAPI = "https://microsoftedge.microsoft.com/addons/getproductdetailsbycrxid"

#Power BI Streaming Dataset
$endpoint = "https://api.powerbi.com/beta/09c030fe-3571-4a28-8929-0ccac75ce583/datasets/8fa4ed11-171e-4c84-ac23-64b9287c72e5/rows?experience=power-bi&key=fUj0ZV7vgcNj%2Bl8vpGqP2PS1sgpG7OIZREFt1N8XvRbzu%2BnhA4NJUL0gXMk2zXicTSrjwToUy5QAXDJuGjycWg%3D%3D"

#Get Extensions in Default Profile of Edge
$Ext = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Extensions" | 
    Select-Object Name

#Loop through Extensions and send info to Power BI
foreach ($ExtId in $Ext){
    #Query Extension Name using ID
    $ExtId = $ExtId.name
    $extensionName = invoke-restmethod -uri "$edgeExtAPI/$ExtId" | 
        select-object name

    $payload = @{ "name" = $extensionName.name
    "id" = $ExtId
    "computer" = $computer}

    #Power BI API
    Invoke-RestMethod -Method Post -Uri "$endpoint" -Body (ConvertTo-Json @($payload))
}

#Get all other profiles for Edge
$Profiles = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Profile*"

#Loop through Profiles
foreach ($Profile in $Profiles){
    $profilename = $profile.name

    $Ext = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Edge\User Data\$profilename\Extensions" | 
        Select-Object Name

    #Loop throuigh Extensions and send info to Power BI
    foreach ($ExtId in $Ext){
    
    #Query Extension Name using ID
    $ExtId = $ExtId.name
    $extensionName = invoke-restmethod -uri "$edgeExtAPI/$ExtId" | 
        select-object name

    $payload = @{ "name" = $extensionName.name
    "id" = $ExtId
    "computer" = $computer}

    #Power BI API
    Invoke-RestMethod -Method Post -Uri "$endpoint" -Body (ConvertTo-Json @($payload))
}}