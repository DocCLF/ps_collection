function IBM_DriveInfo {
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
        Clear-Variable TD* -Scope Global
        <# suppresses error messages #>
        #$ErrorActionPreference="SilentlyContinue"
        $TD_DriveOverview = @()
        [string]$TD_SlotOld = "0"
        <# Connect to Device and get all needed Data #>
        #$TD_CollectInfos = ssh $UserName@$DeviceIP 'lsdrive -nohdr |while read id name IO_group_id;do lsdrive $id ;echo;done'
        $TD_CollectInfos = Get-Content -Path ".\lsdrive.txt"
        #Start-Sleep -Seconds 1.5
    }
    
    process {
        <#  #>
        $TD_DriveSplitInfos = "" | Select-Object DriveID,DriveCap,PhyDriveCap,PhyUsedDriveCap,EffeUsedDriveCap,DriveStatus,DriveCap,ProductID,FWlev,Slot
        foreach($TD_CollectInfo in $TD_CollectInfos){

            <# Node Info#>
            #[int]$TD_NodeID = ($TD_CollectInfo|Select-String -Pattern '^id\s+(\d+)' -AllMatches).Matches.Groups[1].Value
            #[string]$TD_NodeName = ($TD_CollectInfo|Select-String -Pattern '^name\s([a-zA-Z0-9-_]+)' -AllMatches).Matches.Groups[1].Value
            #[Int64]$TD_NodeWWNN = ($TD_CollectInfo|Select-String -Pattern '^WWNN\s([0-9A-F]+)' -AllMatches).Matches.Groups[1].Value
            <# Drive Info #>

            [int]$TD_DriveSplitInfos.DriveID = ($TD_CollectInfo|Select-String -Pattern '^id\s+(\d+)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_DriveSplitInfos.DriveCap = ($TD_CollectInfo|Select-String -Pattern '^capacity\s+(\d+\.\d+\w+)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_DriveSplitInfos.PhyDriveCap = ($TD_CollectInfo|Select-String -Pattern '^physical_capacity\s+(\d+\.\d+\w+)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_DriveSplitInfos.PhyUsedDriveCap = ($TD_CollectInfo|Select-String -Pattern '^physical_used_capacity\s+(\d+\.\d+\w+)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_DriveSplitInfos.EffeUsedDriveCap = ($TD_CollectInfo|Select-String -Pattern '^effective_used_capacity\s+(\d+\.\d+\w+)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_DriveSplitInfos.DriveStatus = ($TD_CollectInfo|Select-String -Pattern '^status\s+(online|offline|degraded)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_DriveSplitInfos.ProductID = ($TD_CollectInfo|Select-String -Pattern '^product_id\s+([A-Z0-9]+)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_DriveSplitInfos.FWlev = ($TD_CollectInfo|Select-String -Pattern '^firmware_level\s+([0-9_]+)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_DriveSplitInfos.Slot = ($TD_CollectInfo|Select-String -Pattern '^slot_id\s+(\d+)' -AllMatches).Matches.Groups[1].Value
            
            if($TD_DriveSplitInfos.Slot -ne $TD_SlotOld){
                Write-Debug -Message $TD_DriveSplitInfos
                $TD_SlotOld=$TD_DriveSplitInfos.Slot
            }else {
                Write-Debug -Message ($TD_DriveSplitInfos.Slot -ne $TD_SlotOld)
                $TD_DriveOverview += $TD_DriveSplitInfos
                $TD_DriveSplitInfos = "" | Select-Object DriveID,DriveCap,PhyDriveCap,PhyUsedDriveCap,EffeUsedDriveCap,DriveStatus,DriveCap,ProductID,FWlev,Slot
            }
        }
    }
    
    end {
        return $TD_DriveOverview
    }
}