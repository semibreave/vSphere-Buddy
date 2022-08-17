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

function Get-VMDisks
{
    param($vm)
    Get-VM $vm| Get-HardDisk |

    Select @{N='VM';E={$_.Parent.Name}},

    capacityGB,Filename,

    @{N='SCSIid';E={

        $hd = $_

        $ctrl = $hd.Parent.Extensiondata.Config.Hardware.Device | where{$_.Key -eq $hd.ExtensionData.ControllerKey}

        "$($ctrl.BusNumber):$($_.ExtensionData.UnitNumber)"

     }},

    @{N='Type';E={
        
       $type = Get-ScsiController -HardDisk $_|Select-Object Type

       "$($type.Type)"
        
     }}
}

cls

foreach($vm in (Get-ObjectList computer $scriptPath))
{
  Write-Host "Fetching $vm HDD info"
  $obj += Get-VMDisks $vm
}

cls

$obj |ft



Read-Host "Press Enter to go back"