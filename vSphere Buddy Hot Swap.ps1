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



function get-hotSwap
{
    param($vm)
    
    (Get-VM $vm| select ExtensionData).ExtensionData.config | Select Name, MemoryHotAddEnabled, CpuHotAddEnabled, CpuHotRemoveEnabled
    
}

cls

$obj =foreach($vm in (Get-ObjectList computer $scriptPath))
{
    Write-Host "Fetching hot swap status for" $vm

    get-hotSwap $vm
}

cls

$obj |ft

Read-Host "Press enter to go back"

