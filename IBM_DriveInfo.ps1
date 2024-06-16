function IBM_DriveInfo {
    <#
    .SYNOPSIS
       Display Drive information
    .DESCRIPTION
        Shows the most important information of the hard disks in my opinion and exports them if desired.
    .NOTES
        Tested from IBM Spectrum Virtualize 8.5.x in combination with pwsh 5.1 and 7.4
    .NOTES
        current Verion: 1.0.2
        fix: TD_* Wildcard at Username, DeviceIP and Export
        
        old Version:
        1.0.1 Initail Release
    .LINK
        IBM Link for lsvdisk: https://www.ibm.com/docs/en/flashsystem-5x00/8.5.x?topic=commands-lsdrive
        GitHub Link for Script support: https://github.com/DocCLF/ps_collection/blob/main/IBM_DriveInfo.ps1
    .EXAMPLE
        IBM_DriveInfo -TD_UserName MoUser -TD_DeviceIP 123.234.345.456 -TD_export no
        Result for: rz1-N1_superstorage
        Product: 4666-AH8
        Firmware: 8.6.0.3

        DriveID          : 35
        DriveCap         : 26.2TB
        PhyDriveCap      : 8.73TB
        PhyUsedDriveCap  : 1.18TB
        EffeUsedDriveCap : 4.50TB
        DriveStatus      : online
        ProductID        : 101406B1
        FWlev            : 3_1_11
        Slot             : 22
    .EXAMPLE
        IBM_DriveInfo -TD_UserName MoUser -TD_DeviceIP 123.234.345.456 -TD_export yes   
        .\NodeName_Drive_Overview_Date.csv 
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TD_Device_ConnectionTyp,
        [Parameter(Mandatory)]
        [string]$TD_Device_UserName,
        [Parameter(Mandatory)]
        [string]$TD_Device_DeviceIP,
        [string]$TD_Device_PW,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("Host","Hostcluster")]
        [string]$FilterType = "Nofilter",
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","no")]
        [string]$TD_Export = "yes",
        [string]$TD_Exportpath
    )
    begin {
        Clear-Variable TD* -Scope Global
        <# suppresses error messages #>
        $ErrorActionPreference="SilentlyContinue"
        $TD_DriveOverview = @()
        [string]$TD_SlotOld = "0"
        [int]$ProgCounter=0
        <# Connect to Device and get all needed Data #>
        if($TD_Device_ConnectionTyp -eq "ssh"){
            $TD_CollectInfos = ssh $TD_Device_UserName@$TD_Device_DeviceIP 'lsnodecanister -nohdr |while read id name IO_group_id;do lsnodecanister $id;echo;done && lsdrive -nohdr |while read id name IO_group_id;do lsdrive $id ;echo;done'
        }else {
            $TD_CollectInfos = plink $TD_Device_UserName@$TD_Device_DeviceIP -pw $TD_Device_PW -batch 'lsnodecanister -nohdr |while read id name IO_group_id;do lsnodecanister $id;echo;done && lsdrive -nohdr |while read id name IO_group_id;do lsdrive $id ;echo;done'
        }
        
        Write-Debug -Message "Number of Lines: $($TD_CollectInfos.count) "
        0..$TD_CollectInfos.count |ForEach-Object {
            <# Split the infos in 2 var #>
            if($TD_CollectInfos[$_] -match '^serial_number'){
                $TD_NodeInfoTemp = $TD_CollectInfos |Select-Object -First $_
                $TD_CollectInfosTemp = $TD_CollectInfos |Select-Object -Skip $_
            }
        }
        Start-Sleep -Seconds 1
    }
    
    process {
        <# Node Info#>
        $TD_NodeSplitInfo = "" | Select-Object NodeName,ProdName,NodeFW
        foreach($TD_NodeInfoLine in $TD_NodeInfoTemp){
            $TD_NodeSplitInfo.NodeName = ($TD_NodeInfoLine|Select-String -Pattern '^failover_name\s+([a-zA-Z0-9-_]+)' -AllMatches).Matches.Groups[1].Value
            $TD_NodeSplitInfo.ProdName = ($TD_NodeInfoLine|Select-String -Pattern '^product_mtm\s+([a-zA-Z0-9-_]+)' -AllMatches).Matches.Groups[1].Value
            $TD_NodeSplitInfo.NodeFW = ($TD_NodeInfoLine|Select-String -Pattern '^code_level\s+([a-zA-Z0-9-_.]+)' -AllMatches).Matches.Groups[1].Value
            Write-Debug -Message $TD_NodeSplitInfo
        }

        <# Drive Info #>
        $TD_DriveSplitInfos = "" | Select-Object DriveID,DriveCap,PhyDriveCap,PhyUsedDriveCap,EffeUsedDriveCap,DriveStatus,DriveCap,ProductID,FWlev,Slot
        foreach($TD_CollectInfo in $TD_CollectInfosTemp){
            [int]$TD_DriveSplitInfos.DriveID = ($TD_CollectInfo|Select-String -Pattern '^id\s+(\d+)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_DriveSplitInfos.DriveCap = ($TD_CollectInfo|Select-String -Pattern '^capacity\s+(\d+\.\d+\w+)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_DriveSplitInfos.PhyDriveCap = ($TD_CollectInfo|Select-String -Pattern '^physical_capacity\s+(\d+\.\d+\w+)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_DriveSplitInfos.PhyUsedDriveCap = ($TD_CollectInfo|Select-String -Pattern '^physical_used_capacity\s+(\d+\.\d+\w+)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_DriveSplitInfos.EffeUsedDriveCap = ($TD_CollectInfo|Select-String -Pattern '^effective_used_capacity\s+(\d+\.\d+\w+)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_DriveSplitInfos.DriveStatus = ($TD_CollectInfo|Select-String -Pattern '^status\s+(online|offline|degraded)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_DriveSplitInfos.ProductID = ($TD_CollectInfo|Select-String -Pattern '^product_id\s+([A-Z0-9]+)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_DriveSplitInfos.FWlev = ($TD_CollectInfo|Select-String -Pattern '^firmware_level\s+([A-Z0-9_]+)' -AllMatches).Matches.Groups[1].Value
            [string]$TD_DriveSplitInfos.Slot = ($TD_CollectInfo|Select-String -Pattern '^slot_id\s+(\d+)' -AllMatches).Matches.Groups[1].Value
            
            if($TD_DriveSplitInfos.Slot -ne $TD_SlotOld){
                Write-Debug -Message $TD_DriveSplitInfos
                $TD_SlotOld=$TD_DriveSplitInfos.Slot
            }else {
                Write-Debug -Message ($TD_DriveSplitInfos.Slot -ne $TD_SlotOld)
                $TD_DriveOverview += $TD_DriveSplitInfos
                $TD_DriveSplitInfos = "" | Select-Object DriveID,DriveCap,PhyDriveCap,PhyUsedDriveCap,EffeUsedDriveCap,DriveStatus,DriveCap,ProductID,FWlev,Slot
            }

            <# Progressbar  #>
            $ProgCounter++
            $Completed = ($ProgCounter/$TD_CollectInfosTemp.Count) * 100
            Write-Progress -Activity "Create the list" -Status "Progress:" -PercentComplete $Completed
        }
    }
    end{
        <# export y or n #>
        if($TD_export -eq "yes"){
            <# exported to .\Drive_Overview_(Date).csv #>
            if([string]$TD_Exportpath -ne "$PSRootPath\Export\"){
                $TD_DriveOverview | Export-Csv -Path $TD_Exportpath\$($TD_NodeSplitInfo.NodeName)_Drive_Overview_$(Get-Date -Format "yyyy-MM-dd").csv -NoTypeInformation
            }else {
                $TD_Mappingresault | Export-Csv -Path $PSScriptRoot\Export\$($TD_NodeSplitInfo.NodeName)_Drive_Overview_$(Get-Date -Format "yyyy-MM-dd").csv -NoTypeInformation
            }
            #$TD_FileInfo=Get-ChildItem Host_Volume_Map_Result_$(Get-Date -Format "yyyy-MM-dd").csv -Recurse -ErrorAction SilentlyContinue
            Write-Host "The Export can be found at $TD_Exportpath " -ForegroundColor Green
            Start-Sleep -Seconds 1
            #Invoke-Item "$TD_Exportpath\$($TD_NodeSplitInfo.NodeName)_Drive_Overview_$(Get-Date -Format "yyyy-MM-dd").csv"
        }else {
            <# output on the promt #>
            Write-Host "Result for:`nName: $($TD_NodeSplitInfo.NodeName) `nProduct: $($TD_NodeSplitInfo.ProdName) `nFirmware: $($TD_NodeSplitInfo.NodeFW)`n`n" -ForegroundColor Yellow
            Start-Sleep -Seconds 2.5
            return $TD_DriveOverview
        }
        <# wait a moment #>
        Start-Sleep -Seconds 1
        <# Cleanup all TD* Vars #>
        Clear-Variable TD* -Scope Global
    }
}
