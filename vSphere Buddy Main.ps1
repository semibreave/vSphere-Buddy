
do{

#Get the script location   
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition


cls

Write-Host "######################################################################################################################"
                        Write-Host "`t` `t`  `t` `t` `t` `t`MAIN MENU" -ForegroundColor Green
Write-Host "######################################################################################################################"
                     
                        Write-Host "1. Get VM Basic Info"
                        Write-Host "2. Get VM HDD Info"
                        Write-Host "3. Get VM Hot Swap Info"
                        Write-Host "4. Set VM's CPU"
                        Write-Host "5. Set VM's HDD"
                        Write-Host "6. Set VM's Memory"
                        Write-Host "7. Go back to Start"
            Write-Host
            
            $choice = Read-Host "Enter number to select"

            if($choice -eq 1){ & $scriptPath\'vSphere Buddy Basic Info.ps1'}

            elseif($choice -eq 2){ & $scriptPath\'vSphere Buddy HDD.ps1'}
            
            elseif($choice -eq 3){ & $scriptPath\'vSphere Buddy Hot Swap.ps1'}

            elseif($choice -eq 5){ & $scriptPath\'vSphere Buddy Expand HDD.ps1'}

            elseif($choice -eq 6){ & $scriptPath\'vSphere Buddy Expand Memory.ps1'}

            elseif($choice -eq 7){break}


}

while($true)