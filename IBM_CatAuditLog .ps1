function IBM_CatAuditLog {
    <#
    .SYNOPSIS
    Get SAN-Switch License Infos 

    .DESCRIPTION

    .EXAMPLE
    FOS_Port_LicenseShow -UserName admin -SwitchIP 10.10.10.25

    .LINK
    Brocade® Fabric OS® Command Reference Manual, 9.1.x
    https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-1-x/Fabric-OS-Commands.html
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Int16]$TD_Line_ID,
        [Parameter(Mandatory)]
        [string]$TD_Device_ConnectionTyp,
        [Parameter(Mandatory)]
        [string]$TD_Device_UserName,
        [Parameter(Mandatory)]
        [string]$TD_Device_DeviceIP,
        [string]$TD_Device_PW,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","no")]
        [string]$TD_Export = "yes",
        [string]$TD_Exportpath
    )
    
    begin{
        <# suppresses error messages #>
        $ErrorActionPreference="SilentlyContinue"
        Write-Debug -Message "IBM_CatAuditLog Begin block |$(Get-Date)"

        $TD_EventCollection = @()
        
        <# Action when all if and elseif conditions are false #>
        if($TD_Device_ConnectionTyp -eq "ssh"){
            $TD_CollectEventInfo = ssh $TD_Device_UserName@$TD_Device_DeviceIP "catauditlog -delim :"
        }else {
            $TD_CollectEventInfo = plink $TD_Device_UserName@$TD_Device_DeviceIP -pw $TD_Device_PW -batch "catauditlog -delim :"
        }
        <# next line one for testing #>
        #$TD_CollectVolInfo = Get-Content -Path ""
        #$TD_CollectEventInfo = $TD_CollectEventInfo | Select-Object -Skip 1
    }

    process{
        Write-Debug -Message "IBM_CatAuditLog Process block |$(Get-Date)"



    }
    end {
        <# returns the hashtable for further processing, not mandatory but the safe way #>
        Write-Debug -Message "IBM_CatAuditLog End block |$(Get-Date) `n"
        <# export y or n #>
        if($TD_Export -eq "yes"){
            <# exported to .\Host_Volume_Map_Result.csv #>
            if([string]$TD_Exportpath -ne "$PSRootPath\Export\"){
                $TD_EventCollection | Export-Csv -Path $TD_Exportpath\$($TD_Line_ID)_EventLog_Result_$(Get-Date -Format "yyyy-MM-dd").csv -NoTypeInformation
                Write-Host "The Export can be found at $TD_Exportpath " -ForegroundColor Green
            }else {
                $TD_EventCollection | Export-Csv -Path $PSScriptRoot\Export\$($TD_Line_ID)_EventLog_Result_$(Get-Date -Format "yyyy-MM-dd").csv -NoTypeInformation
                Write-Host "The Export can be found at $PSScriptRoot\Export\ " -ForegroundColor Green
            }
            
            #Invoke-Item "$TD_Exportpath\Host_Volume_Map_Result_$(Get-Date -Format "yyyy-MM-dd").csv"
        }else {
            <# output on the promt #>
            return $TD_EventCollection
        }

        return $TD_CollectEventInfo |Select-Object -Last 25
        
    }
}