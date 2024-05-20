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
        $TD_CollectInfos = ssh $UserName@$DeviceIP 'lsnodecanister -nohdr |while read id name IO_group_id;do lsnodecanister $id;echo;done && lsnodecanister -nohdr |while read id name IO_group_id;do lsportstats -node $id ;echo;done'
        Start-Sleep -Seconds 1.5
    }
    
    process {
        <#  #>
        foreach($TD_CollectInfo in $TD_CollectInfos){
            <# Node Info#>
            [int]$TD_NodeID = ($TD_CollectInfo|Select-String -Pattern '^id\s+(\d+)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_NodeName = ($TD_CollectInfo|Select-String -Pattern '^name\s([a-zA-Z0-9-_]+)' -AllMatches).Matches.Groups[1].Value
            [Int64]$TD_NodeWWNN = ($TD_CollectInfo|Select-String -Pattern '^WWNN\s([0-9A-F]+)' -AllMatches).Matches.Groups[1].Value
            <# Card Info #>
            [string]$TD_CardType = ($TD_CollectInfo|Select-String -Pattern '^type.*(FC)' -AllMatches).Matches.Groups[1].Value
            [int]$TD_CardID = ($TD_CollectInfo|Select-String -Pattern '^type_id.*(\d)' -AllMatches).Matches.Groups[1].Value
            [int]$TD_PortID = ($TD_CollectInfo|Select-String -Pattern 'port\sid.*(\d)' -AllMatches).Matches.Groups[1].Value
            [Int64]$TD_WWPN = ($TD_CollectInfo|Select-String -Pattern 'wwpn.*0x([0-9a-f]+)' -AllMatches).Matches.Groups[1].Value
            <# diagnostics data #>
            <# Block 1#>
            [int]$TD_LinkFailure = ($TD_CollectInfo|Select-String -Pattern 'lf=""(\d+)""' -AllMatches).Matches.Groups[1].Value
            [int]$TD_LoseSync = ($TD_CollectInfo|Select-String -Pattern 'lsy=""(\d+)""' -AllMatches).Matches.Groups[1].Value
            [int]$TD_LoseSig = ($TD_CollectInfo|Select-String -Pattern 'lsi=""(\d+)""' -AllMatches).Matches.Groups[1].Value
            [int]$TD_PSErrCount = ($TD_CollectInfo|Select-String -Pattern 'pspe=""(\d+)""' -AllMatches).Matches.Groups[1].Value
            <# Block 2#>
            [int]$TD_InvTransErr = ($TD_CollectInfo|Select-String -Pattern 'itw=""(\d+)""' -AllMatches).Matches.Groups[1].Value
            [int]$TD_CRCErr = ($TD_CollectInfo|Select-String -Pattern 'icrc=""(\d+)""' -AllMatches).Matches.Groups[1].Value
            [int]$TD_ZeroBtB = ($TD_CollectInfo|Select-String -Pattern 'bbcz=""(\d+)""' -AllMatches).Matches.Groups[1].Value
            <# Block 3#>
            [int]$TD_SFPTemp = ($TD_CollectInfo|Select-String -Pattern 'tmp=""(\d+)""' -AllMatches).Matches.Groups[1].Value
            [int]$TD_TXPwr = ($TD_CollectInfo|Select-String -Pattern 'txpwr=""(\d+)""' -AllMatches).Matches.Groups[1].Value
            [int]$TD_RXPwr = ($TD_CollectInfo|Select-String -Pattern 'rxpwr=""(\d+)""' -AllMatches).Matches.Groups[1].Value
            
        }
    }
    
    end {
        
    }
}