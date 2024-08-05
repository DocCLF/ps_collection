
function IBM_StorageHealthCheck {
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
    
    begin {
        <# suppresses error messages #>
        $ErrorActionPreference="SilentlyContinue"
        <# create a array #>
        #$TD_CommandResault = @()
        #<# int for the progressbar #>
        #[int]$nbr=0
#
        if($TD_Device_ConnectionTyp -eq "ssh"){
            $TD_CollectInfo = ssh $TD_Device_UserName@$TD_Device_DeviceIP "lshost && lshostcluster && lsmdisk && lsvdisk && lsuser && lsquorum && lsfcmap && lsencryption && lsenclosurebattery && lsenclosurestats && lsenclosureslot && lsdrive && lsrcrelationship && lsrcconsistgrp && lspartnership && lssecurity && lseventlog | grep alert"
        }else {
            $TD_CollectInfo = plink $TD_Device_UserName@$TD_Device_DeviceIP -pw $TD_Device_PW -batch "lshost && lshostcluster && lsmdisk && lsvdisk && lsuser && lsquorum && lsfcmap && lsencryption && lsenclosurebattery && lsenclosurestats && lsenclosureslot && lsdrive && lsrcrelationship && lsrcconsistgrp && lspartnership && lssecurity && lseventlog | grep alert"
        }
        <# next line one for testing #>
        #$TD_CollectInfo = Get-Content -Path "C:\Users\mailt\Documents\mimixexport.txt" #C:\Users\mailt\Documents\mimixexport.txt

        $TD_InfoCount = $TD_CollectInfo.count
        0..$TD_InfoCount |ForEach-Object {
            # Pull only the effective ZoneCFG back into ZoneList
            if($TD_CollectInfo[$_] -match 'mapping_count'){
                $TD_HostClusterTemp = $TD_CollectInfo |Select-Object -Skip $_
            }
            if($TD_CollectInfo[$_] -match 'ssh_protocol_suggested'){
                $EventLogTemp = $TD_CollectInfo |Select-Object -Skip ($_ +1)
            }
        }

    }
    
    process {
        $TD_EventCollection = @()
        foreach($EventLine in $EventLogTemp){
            $TD_EventSplitInfo = "" | Select-Object LastTime,Status,Fixed,ErrorCode,Description
            $TD_EventSplitInfo.LastTime = ($EventLine|Select-String -Pattern '^\d+\s+(\d+)' -AllMatches).Matches.Groups[1].Value
            $TD_EventSplitInfo.Status = ($EventLine|Select-String -Pattern '\s+(alert)\s+' -AllMatches).Matches.Groups[1].Value
            $TD_EventSplitInfo.Fixed = ($EventLine|Select-String -Pattern 'alert\s+(no|yes)' -AllMatches).Matches.Groups[1].Value
            if(!([String]::IsNullOrEmpty(($EventLine|Select-String -Pattern '\s+\d{6}\s+(\d+|)\s+' -AllMatches).Matches.Groups[1].Value))){
                $TD_EventSplitInfo.ErrorCode = ($EventLine|Select-String -Pattern '\s+\d{6}\s+(\d+|)\s+' -AllMatches).Matches.Groups[1].Value
            }else {
                $TD_EventSplitInfo.ErrorCode = "none"
            }
            $TD_EventSplitInfo.Description = ($EventLine|Select-String -Pattern '\s+\d{6}\s+(\d+|)\s+([a-zA-Z0-9\s_.,]+)$' -AllMatches).Matches.Groups[2].Value

            $TD_EventCollection += $TD_EventSplitInfo
        }
        if($TD_EventCollection.Count -gt 0){
            $TD_el_EventlogStatusLight.Fill = "red"
            $TD_dg_EventlogStatusInfoText.ItemsSource=$TD_EventCollection
            $TD_UserControl3.Dispatcher.Invoke([System.Action]{},"Render")
            Write-Host "$TD_Device_DeviceIP mehr als einer" -ForegroundColor Blue
        }else {
            $TD_el_EventlogStatusLight.Fill = "green"
            $TD_dg_EventlogStatusInfoText.ItemsSource=$EmptyVar
            $TD_UserControl3.Dispatcher.Invoke([System.Action]{},"Render")
            Write-Host "$TD_Device_DeviceIP keiner" -ForegroundColor yellow
        }

        $TD_HostChostClusterResault = @()
        foreach ($TD_HostHostClusterInfo in $TD_CollectInfo){
            if($TD_HostHostClusterInfo |Select-String -Pattern "mapping_count"){break}
            $TD_HostChostClusterInfo = "" | Select-Object HostName,Status,HostSiteName,HostClusterName #,HostClusterStatus
            $TD_HostChostClusterInfo.HostName = ($TD_HostHostClusterInfo|Select-String -Pattern '^\d+\s+([0-9a-zA-z-_]+)' -AllMatches).Matches.Groups[1].Value
            $TD_HostChostClusterInfo.Status = ($TD_HostHostClusterInfo|Select-String -Pattern '\s+(online|offline|degraded)\s+' -AllMatches).Matches.Groups[1].Value
            $TD_HostChostClusterInfo.HostSiteName = ($TD_HostHostClusterInfo|Select-String -Pattern '\s+(online|offline|degraded)\s+\d+\s+(\w+)\s+\d+' -AllMatches).Matches.Groups[2].Value
            $TD_HostChostClusterInfo.HostClusterName = ($TD_HostHostClusterInfo|Select-String -Pattern '([a-zA-Z0-9-_]+)\s+scsi|fcnvme' -AllMatches).Matches.Groups[1].Value

            if(($TD_HostChostClusterInfo.Status -ne "online")-and (![string]::IsNullOrEmpty($TD_HostChostClusterInfo.HostName))){
                <# HostClusterStatus implement maybe later #>
                #if(![string]::IsNullOrEmpty($TD_HostChostClusterInfo.HostClusterName)){
                #    foreach ($TD_HostClusterStatus in $TD_HostClusterTemp){
                #        if($TD_HostClusterStatus |Select-String -Pattern "supports_unmap"){break}
                #        #if(![string]::IsNullOrEmpty($TD_HostChostClusterInfo.HostClusterStatus)){break}
                #        $TD_HostChostClusterInfo.HostClusterStatus = ($TD_HostClusterStatus|Select-String -Pattern '\s+(online|offline|host_degraded|host_cluster_degraded)\s+' -AllMatches).Matches.Groups[1].Value
                #    }
                #}
                $TD_HostChostClusterResault += $TD_HostChostClusterInfo
            }
            if(([string]::IsNullOrEmpty($TD_HostChostClusterInfo.HostClusterName))-and($TD_HostHostClusterInfo |Select-String -Pattern "mdisk_grp_name")){break}
        }
        if($TD_HostChostClusterResault.Count -gt 0){
            $TD_el_HostStatusLight.Fill = "red"
            $TD_dg_HostStatusInfoText.ItemsSource=$TD_HostChostClusterResault
            $TD_UserControl3.Dispatcher.Invoke([System.Action]{},"Render")
        }else{
            $TD_el_HostStatusLight.Fill = "green"
            $TD_dg_HostStatusInfoText.ItemsSource=$EmptyVar
            $TD_UserControl3.Dispatcher.Invoke([System.Action]{},"Render")
            }

    }
    
    end {
        
    }
}