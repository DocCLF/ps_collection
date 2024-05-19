function IBM_Enclosure_FCPortStats {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$TD_UserName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ipaddress]$TD_DeviceIP,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","no")]
        [string]$TD_export = "no"
    )
    begin {
        <# suppresses error messages #>
        $ErrorActionPreference="SilentlyContinue"
        <# Connect to Device and get all needed Data #>
        $TD_CollectInfo = ssh $UserName@$DeviceIP 'lsnodecanister -nohdr |while read id name IO_group_id;do lsnodecanister $id;echo;done'
        Start-Sleep -Seconds 1.5
    }
    
    process {
        <#  #>
        foreach($TD_CollectLine in $TD_CollectInfo){
            <# Node & Card Info#>
            [string]$TD_Node
            [string]$TD_CardType = ($TD_CollectLine|Select-String -Pattern '^type.*(FC)' -AllMatches).Matches.Groups[1].Value
            [int]$TD_CardID
            [int]$TD_PortID
            [Int64]$TD_WWPN
            <# diagnostics data #>
            <# Block 1#>
            [int]$TD_LinkFailure
            [int]$TD_LoseSync
            [int]$TD_LoseSig
            [int]$TD_PSErrCount
            <# Block 2#>
            [int]$TD_InvTransErr
            [int]$TD_CRCErr
            [int]$TD_ZeroBtB
            <# Block 3#>
            [int]$TD_SFPTemp
            [int]$TD_TXPwr
            [int]$TD_RXPwr

        }
    }
    
    end {
        
    }
}