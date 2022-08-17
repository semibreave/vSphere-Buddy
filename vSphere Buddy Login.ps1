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

#return vm with associated vCenter object
function Match-CSV
{
    
    param($computers,$csv)

    $vm_vc = @()
    
    #Generate VM_VC table
    foreach($computer in $computers)
    {
        Write-Host "Getting vCenter for"$computer
        
        $vc = ($csv|Select-Object vm,vc|Where-Object{$_.vm -eq $computer}).vc
    
        if($vc -ne $null)
        {
           $vm_vc += New-Object psobject -Property @{
                    
                                                        "VM" = $computer
                                                        "VC" = $vc
                     
                                                     }
        }
        
        else
        {
            $vm_vc += New-Object psobject -Property @{
                    
                                                        "VM" = $computer
                                                        "VC" = "null"
                     
                                                     }
 
        
        }
    
       
    }

    cls

    return $vm_vc

}

#Check if vcenter object have associated Vc and other criteria
function Get-CSV_Compliant
{
    param($vm_vc)

    $result = "Pass"

    foreach($vco in $vm_vc)
    {
        if(( (($vco|where{$_.vm -eq $vco.vm}).vc.count) -gt 1 ) -or ($vco.vc -eq "NULL")  )
        {
           $result = "Fail" 
           break
        }
    
    }

    return $result
}

#return vm,vc and it login status object
function Login-ManyVCenter
{
   param($vm_vc,$credential)
   
   Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false |Out-Null
   
   $vc_login_stat = @()
   
    
   foreach($vco in $vm_vc)
   {
      
      Write-Host "Logging to vCenter for" $vco.vm
       
       
       try{ 
            Connect-VIServer $vco.vc -ErrorAction Stop -Credential $credential | Out-Null

            $vc_login_stat +=  New-Object psobject -Property @{
                                                                "VM" = $vco.vm
                                                                "vCenter" = $vco.vc
                                                                "Login"   = "OK"
                                                               }
           }

       catch{
              $vc_login_stat +=  New-Object psobject -Property @{
                                                                    "VM" = $vco.vm
                                                                    "vCenter" = $vco.vc
                                                                    "Login"   = "UTL"
                                                                }
        }
   }

   cls
   
   return $vc_login_stat
}

#check if all VM associated vc is logged on
function Get-VC_Compliant
{
    param ($vc_login_stat)

    $result = "Pass"

    foreach($vco in $vc_login_stat)
    {
        if($vco.login -eq "UTL")
        {
           $result = "Fail" 
           break
        }
    
    }

    return $result

}


do{
 

cls

Write-Host "######################################################################################################################"
Write-Host "`t` `t`  `t` `t` `t` `t`Welcome to vSphere Buddy :)" -ForegroundColor Yellow
Write-Host "######################################################################################################################"

Write-Host "1.Key/Rekey in credential"
Write-Host "2.Start Login"    

#Write-Host
#$credential = Get-Credential -Message "Some vCenters required passed credential"

$choice = Read-Host "Enter number to select"

if($choice -eq 1){$credential = Get-Credential -Message "Some vCenters required passed credential"}


elseif($choice -eq 2){

                #Computer list to be use for other scripts
                $computers = Get-ObjectList computer $scriptPath
                
                cls
                
                $vm_vc_obj = Match-CSV $computers (Get-ObjectList vm $scriptPath)
                
                $csv_compliance = Get-CSV_Compliant($vm_vc_obj)
                
                
                if($csv_compliance -eq "Pass")
                {
                        
                    $vc_stat = Login-ManyVCenter $vm_vc_obj $credential
                
                    $vc_compliance = Get-VC_Compliant $vc_stat
                
                    if($vc_compliance -eq "Pass"){
                
                        Write-Host "PasS"
                        
                        & $scriptPath\'vSphere Buddy Main.ps1'
                     
                     }
                
                    else{
        
        Write-Host "Remove or resolve VM with UTL" -ForegroundColor Red
        $vc_stat|FT

                    Read-Host "Press enter to go back"

        
    }
                }
                
                else
                {
                    Write-Host "Remove VM with null or multiple vCenter and try again" -ForegroundColor Red

                    $vm_vc_obj|FT

                    Read-Host "Press enter to go back"

                }


       
   }


}

while($true)



