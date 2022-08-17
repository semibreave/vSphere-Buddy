#Get the script location   
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition  

#return content of a file
function Get-ObjectList
{
    param($key,$path)
    
    if($key -eq "computer")
    {
        $content = Get-Content $path\computers.txt|Where-Object{$_.trim() -ne ''}|foreach{$_.trim()}
    }
    
    elseif($key -eq "vm"){$content = Import-Csv  $path\vms.csv}
    

    return $content

}

function get-basic
{
    param($vm)
    
    Get-VM $vm
    
}

cls

$obj =foreach($vm in (Get-ObjectList computer $scriptPath))
{
    Write-Host "Fetching memory info for" $vm

    get-basic $vm
}

cls

$obj|select name,MemoryGB |ft

$addSize = Read-Host "Please enter amount(GB) to add"

cls




