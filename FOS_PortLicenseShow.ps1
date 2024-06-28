function FOS_PortLicenseShow {
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
        [Int16]$TD_Line_ID,
        [string]$TD_Device_ConnectionTyp,
        [string]$TD_Device_UserName,
        [string]$TD_Device_DeviceIP,
        [string]$TD_Device_PW,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("Host","Hostcluster","Nofilter")]
        [string]$FilterType = "Nofilter",
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","no")]
        [string]$TD_Export = "yes",
        [string]$TD_Exportpath,
        [string]$TD_RefreshView
    )
    
    begin{
        $ErrorActionPreference="SilentlyContinue"
        Write-Debug -Message "FOS_PortLicenseShow Begin block |$(Get-Date)"

        #[int]$nbr=0

        #if($TD_Device_ConnectionTyp -eq "ssh"){
        #    Write-Debug -Message "ssh |$(Get-Date)"
        #    $FOS_PortLicenseInfo = ssh $TD_Device_UserName@$TD_Device_DeviceIP "switchshow && license --show -port"
        #}else {
        #    Write-Debug -Message "plink |$(Get-Date)"
        #    $FOS_PortLicenseInfo = plink $TD_Device_UserName@$TD_Device_DeviceIP -pw $TD_Device_PW -batch "switchshow && license --show -port"
        #}
        $FOS_PortLicenseInfo = Get-Content -Path "C:\Users\mailt\Documents\0.txt"

    }

    process{
        Write-Debug -Message "FOS_PortLicenseShow Process block |$(Get-Date)"
        $i = $FOS_PortLicenseInfo.Count

        0..$i |ForEach-Object {
            if($FOS_PortLicenseInfo[$_] -match '023f00'){
                $TD_Resaults = $FOS_PortLicenseInfo | Select-Object -Skip ($_ +1)
                $i = $_
            }
        }  
    }
    end{
        Write-Debug -Message "FOS_PortLicenseShow End block |$(Get-Date)"
        return $TD_Resaults
        Write-Debug -Message "Resault: $FOS_PortInfo |$(Get-Date)"
        Clear-Variable TD* -Scope Global;
    }
}