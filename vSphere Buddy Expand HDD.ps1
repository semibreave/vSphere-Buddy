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

function Expand-Disk
{
    param($vm,$disk_no,$size)

    $hdd_name = "hard disk " + $disk_no

    try{
        Get-VM $vm -ErrorAction Stop | Get-HardDisk -Name $hdd_name -ErrorAction Stop | Set-HardDisk -CapacityGB $size -Verbose:$false -Confirm:$false -ErrorAction Stop
        return "YES"
    }

    catch{
        return "NO"
    }
}

function Get-VMDiskSpace
{
   param($vm,$disk_no)
   
   try{
        $hdd_capac = Get-VM $vm -ErrorAction Stop |Get-HardDisk -ErrorAction Stop |select -Property *|Select-Object Name,CapacityGB|Where-Object{$_.Name -eq "hard disk " + $disk_no} 
        
        return $hdd_capac.CapacityGB
   }

   catch{

        return "Fail"
   }
}

cls

$disk_number  = Read-Host "Enter disk number"

$add_size = Read-Host "Enter add size(GB)"


cls

$obj = @()


foreach($vm in (Get-ObjectList computer $scriptPath))
{
    Write-Host "Expanding"$vm
    
    $disk_space = Get-VMDiskSpace $vm $disk_number

    if($disk_space -ne "Fail"){

        $size = $disk_space + $add_size
        
        $result = Expand-Disk $vm $disk_number $size

        if($result -eq "YES"){

            $obj += New-Object psobject -Property @{
                                                    "VM" = $vm
                                                    "Expand" = "Success"
                                                    "Before(GB)" = $disk_space
                                                    "After(GB)" = Get-VMDiskSpace $vm $disk_number
                                                   }
        }

        else{
                $obj += New-Object psobject -Property @{
                                                    "VM" = $vm
                                                    "Expand" = "Fail"
                                                    "Before(GB)" = $disk_space
                                                    "After(GB)" = Get-VMDiskSpace $vm $disk_number
                                                   }
        
        
        }

    }

    else{

        $obj += New-Object psobject -Property @{
                                                 "VM" = $vm
                                                 "Expand" = "UTC"
                                                 "Before(GB)" = "UTC"
                                                 "After(GB)" = "UTC"
                                               }
    }
}

cls

$obj|Out-Default

Read-Host "Press Enter to go back"

Clear-Host

& $scriptPath\'vSphere Buddy Main.ps1'