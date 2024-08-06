
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
            $TD_CollectInfo = ssh $TD_Device_UserName@$TD_Device_DeviceIP "lshost && lshostcluster && lsmdisk && lsvdisk && lsuser && lsquorum && lsfcmap && lsencryption && lsenclosurebattery && lsenclosurestats && lsenclosureslot && lsrcrelationship && lsrcconsistgrp && lspartnership && lssecurity && lseventlog | grep alert"
        }else {
            $TD_CollectInfo = plink $TD_Device_UserName@$TD_Device_DeviceIP -pw $TD_Device_PW -batch "lshost && lshostcluster && lsmdisk && lsvdisk && lsuser && lsquorum && lsfcmap && lsencryption && lsenclosurebattery && lsenclosurestats && lsenclosureslot && lsrcrelationship && lsrcconsistgrp && lspartnership && lssecurity && lseventlog | grep alert"
        }
        <# next line one for testing #>
        #$TD_CollectInfo = Get-Content -Path "C:\Users\mailt\Documents\hyperswap.txt" #C:\Users\mailt\Documents\mimixexport.txt hyperswap
        #$TD_CollectInfo = Get-Content -Path "C:\Users\mailt\Desktop\FS5200_W.txt"

        $TD_InfoCount = $TD_CollectInfo.count
        0..$TD_InfoCount |ForEach-Object {
            # Pull only the effective ZoneCFG back into ZoneList
            if($TD_CollectInfo[$_] -match 'mapping_count'){
                $TD_HostClusterTemp = $TD_CollectInfo |Select-Object -Skip $_
            }
            if($TD_CollectInfo[$_] -match 'ssh_protocol_suggested'){
                $TD_EventLogTemp = $TD_CollectInfo |Select-Object -Skip ($_ +1)
            }
            if($TD_CollectInfo[$_] -match 'distributed'){
                $TD_MDiskInfoTemp = $TD_CollectInfo |Select-Object -Skip ($_ +1)
            }
            if($TD_CollectInfo[$_] -match 'vdisk_UID'){
                $TD_VDiskInfoTemp = $TD_CollectInfo |Select-Object -Skip ($_ +1)
            }
            if($TD_CollectInfo[$_] -match 'usergrp_id'){
                $TD_UserInfoTemp = $TD_CollectInfo |Select-Object -Skip ($_ +1)
            }
        }
    }
    
    process {
        $TD_EventCollection = @()
        foreach($EventLine in $TD_EventLogTemp){
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
        }else {
            $TD_el_EventlogStatusLight.Fill = "green"
            $TD_dg_EventlogStatusInfoText.ItemsSource=$EmptyVar
            $TD_UserControl3.Dispatcher.Invoke([System.Action]{},"Render")
        }

        $TD_HostChostClusterResault = @()
        foreach ($TD_HostHostClusterInfo in $TD_CollectInfo){
            if($TD_HostHostClusterInfo |Select-String -Pattern "mapping_count"){break}
            $TD_HostChostClusterInfo = "" | Select-Object HostName,Status,HostSiteName,HostClusterName #,HostClusterStatus
            $TD_HostChostClusterInfo.HostName = ($TD_HostHostClusterInfo|Select-String -Pattern '^\d+\s+([0-9a-zA-z-_]+)' -AllMatches).Matches.Groups[1].Value
            $TD_HostChostClusterInfo.Status = ($TD_HostHostClusterInfo|Select-String -Pattern '\s+(online|offline|degraded)\s+' -AllMatches).Matches.Groups[1].Value
            $TD_HostChostClusterInfo.HostSiteName = ($TD_HostHostClusterInfo|Select-String -Pattern '\s+(online|offline|degraded)\s+\d+\s+(\w+)\s+\d+' -AllMatches).Matches.Groups[2].Value
            $TD_HostChostClusterInfo.HostClusterName = ($TD_HostHostClusterInfo|Select-String -Pattern '\s+(online|offline|degraded)\s+(\d+|)\s+([a-zA-Z0-9-_]+|)\s+(\d+|)\s+([a-zA-Z0-9-_]+)\s+scsi|fcnvme' -AllMatches).Matches.Groups[5].Value

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
        
        $TD_MDiskResault = @()
        foreach ($TD_MDisk in $TD_MDiskInfoTemp){
            if($TD_MDisk |Select-String -Pattern "vdisk_UID"){break}
            $TD_MDiskInfo = "" | Select-Object Pool,Status,Capacity
            $TD_MDiskInfo.Status = ($TD_MDisk|Select-String -Pattern '\d+\s+([a-zA-Z0-9-_]+)\s+(online|offline|excluded|degraded|degraded_paths|degraded_ports)' -AllMatches).Matches.Groups[2].Value
            $TD_MDiskInfo.Pool = ($TD_MDisk|Select-String -Pattern '\s+\d+\s+([a-zA-Z0-9-_]+)\s+(\d+.\d+[A-Z]+)' -AllMatches).Matches.Groups[1].Value
            $TD_MDiskInfo.Capacity = ($TD_MDisk|Select-String -Pattern '\s+\d+\s+([a-zA-Z0-9-_]+)\s+(\d+.\d+[A-Z]+)' -AllMatches).Matches.Groups[2].Value
            $TD_MDiskResault += $TD_MDiskInfo
        }
        if(($TD_MDiskResault.Status -eq "online").count -eq ($TD_MDiskResault.count)){
            $TD_dg_MdiskStatusInfoText.ItemsSource=$EmptyVar
            $TD_el_MdiskStatusLight.Fill ="green"
        }elseif ($TD_MDiskResault.Status -like "degraded*") {
            $TD_dg_MdiskStatusInfoText.ItemsSource=$EmptyVar
            $TD_el_MdiskStatusLight.Fill ="yellow"
            $TD_dg_MdiskStatusInfoText.ItemsSource=$TD_MDiskResault
        }elseif (($TD_MDiskResault.Status -eq "offline")-or($TD_MDiskResault.Status -eq "excluded")){
            $TD_dg_MdiskStatusInfoText.ItemsSource=$EmptyVar
            $TD_el_MdiskStatusLight.Fill ="red"
            $TD_dg_MdiskStatusInfoText.ItemsSource=$TD_MDiskResault
        }
        $TD_UserControl3.Dispatcher.Invoke([System.Action]{},"Render")

        $TD_VdiskResaultTemp = @()
        foreach($TD_VDisk in $TD_VDiskInfoTemp){
            if($TD_VDisk |Select-String -Pattern "usergrp_id"){break}
            $TD_VDiskinfo = "" | Select-Object Volume_Name,IO_Group,Status,Pool,Volume_UID,VolFunc
            $TD_VDiskinfo.Volume_Name = ($TD_VDisk|Select-String -Pattern '^\d+\s+([a-zA-Z0-9-_]+)\s+\d+\s+([a-zA-Z0-9-_]+)\s+' -AllMatches).Matches.Groups[1].Value
            $TD_VDiskinfo.IO_Group = ($TD_VDisk|Select-String -Pattern '^\d+\s+([a-zA-Z0-9-_]+)\s+\d+\s+([a-zA-Z0-9-_]+)\s+' -AllMatches).Matches.Groups[2].Value
            $TD_VDiskinfo.Status = ($TD_VDisk|Select-String -Pattern '\s+(online|offline|deleting|degraded)\s+' -AllMatches).Matches.Groups[1].Value
            $TD_VDiskinfo.Pool = ($TD_VDisk|Select-String -Pattern '\s+(online|offline|deleting|degraded)\s+\d+\s+([a-zA-Z0-9-_]+)' -AllMatches).Matches.Groups[2].Value
            $TD_VDiskinfo.Volume_UID = ($TD_VDisk|Select-String -Pattern '\s+([0-9A-F]+)\s+\d+\s+\d+\s+' -AllMatches).Matches.Groups[1].Value
            $TD_VDiskinfo.VolFunc = ($TD_VDisk|Select-String -Pattern '\s+(master_change|master|aux_change|aux)\s+' -AllMatches).Matches.Groups[1].Value
            If([String]::IsNullOrEmpty($TD_VDiskinfo.VolFunc)){
                $TD_VDiskinfo.VolFunc="none"
            }
            $TD_VdiskResaultTemp += $TD_VDiskinfo
        }
        $TD_VdiskResault=@()
        $TD_VdiskResaultTemp | ForEach-Object {
            if(($_.VolFunc -eq 'master')-or($_.VolFunc -eq 'none')){
                #Write-Host $_
                $TD_VdiskResault += $_
            }
        }
        if($TD_VdiskResault.Status -eq "online"){
            $TD_dg_VDiskStatusInfoText.ItemsSource=$EmptyVar
            $TD_el_VDiskStatusLight.Fill ="green"
        }elseif ($TD_VdiskResault.Status -like "degraded") {
            $TD_dg_VDiskStatusInfoText.ItemsSource=$EmptyVar
            $TD_el_VDiskStatusLight.Fill ="yellow"
            $TD_dg_VDiskStatusInfoText.ItemsSource=$TD_MDiskResault
        }elseif (($TD_VdiskResault.Status -eq "offline")-or($TD_VdiskResault.Status -eq "deleting")){
            $TD_dg_VDiskStatusInfoText.ItemsSource=$EmptyVar
            $TD_el_VDiskStatusLight.Fill ="red"
            $TD_dg_VDiskStatusInfoText.ItemsSource=$TD_MDiskResault
        }
        $TD_UserControl3.Dispatcher.Invoke([System.Action]{},"Render")

        $TD_UserResault=@()
        foreach($TD_User in $TD_UserInfoTemp){
            if($TD_User |Select-String -Pattern "quorum_index"){break}
            $TD_Userinfo = "" | Select-Object User_Name,Password,SSH_Key,Remote,UserGrp,Locked,PW_Change_required
            $TD_Userinfo.User_Name = ($TD_User|Select-String -Pattern '^\d+\s+([a-zA-Z0-9-_]+)' -AllMatches).Matches.Groups[1].Value
            $TD_Userinfo.Password = ($TD_User|Select-String -Pattern '\s+(yes|no)\s+(yes|no)\s+(yes|no)\s+' -AllMatches).Matches.Groups[1].Value
            $TD_Userinfo.SSH_Key = ($TD_User|Select-String -Pattern '\s+(yes|no)\s+(yes|no)\s+(yes|no)\s+' -AllMatches).Matches.Groups[2].Value
            $TD_Userinfo.Remote = ($TD_User|Select-String -Pattern '\s+(yes|no)\s+(yes|no)\s+(yes|no)\s+' -AllMatches).Matches.Groups[3].Value
            $TD_Userinfo.UserGrp = ($TD_User|Select-String -Pattern '\s+(yes|no)\s+(yes|no)\s+(yes|no)\s+\d+\s+([a-zA-Z0-9-_]+)\s+' -AllMatches).Matches.Groups[4].Value
            $TD_Userinfo.Locked = ($TD_User|Select-String -Pattern '\s+(no|auto|manual)\s+(yes|no)\s+$' -AllMatches).Matches.Groups[1].Value
            $TD_Userinfo.PW_Change_required = ($TD_User|Select-String -Pattern '\s+(no|auto|manual)\s+(yes|no)\s+$' -AllMatches).Matches.Groups[2].Value

            $TD_UserResault += $TD_Userinfo
        }
        if(($TD_UserResault.PW_Change_required -eq "yes")-or($TD_UserResault.SSH_Key -eq "no")){
            $TD_dg_UserStatusInfoText.ItemsSource=$EmptyVar
            $TD_el_UserStatusLight.Fill ="red"
            $TD_dg_UserStatusInfoText.ItemsSource=$TD_UserResault
        }elseif ($TD_UserResault.PW_Change_required -like "yes") {
            $TD_dg_UserStatusInfoText.ItemsSource=$EmptyVar
            $TD_el_UserStatusLight.Fill ="yellow"
            $TD_dg_UserStatusInfoText.ItemsSource=$TD_UserResault
        }elseif ($TD_UserResault.PW_Change_required -eq "no"){
            $TD_dg_UserStatusInfoText.ItemsSource=$EmptyVar
            $TD_el_UserStatusLight.Fill ="green"
        }
        $TD_UserControl3.Dispatcher.Invoke([System.Action]{},"Render")

    }
    
    end {
        
    }
}