function IBM_Host_Volume_Map {
    <#
    .SYNOPSIS
        Displays a list of host/cluster - volume relationships
    .DESCRIPTION
        A longer description of the function, follows
    .NOTES
        Tested with version IBM Spectrum Virtualize Software 7.8.x to 8.5.x
    .LINK
        https://github.com/DocCLF/ps_collection/blob/main/IBM_Host_Volume_Map.ps1
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        IBM_Host_Volume_Map -UserName monitor_user -DeviceIP 8.8.8.8
        HostID      : 91                                                                                                        
        HostName    : powervc-614b137d-0000005c-54486154                                                                        
        HostCluster :                                                                                                           
        VolumeID    : 188                                                                                                       
        VolumeName  : volume-powervc-614b137d-0000005c-boot-0-5a6ca77e-307a                                                     
        UID         : 60050763808102F40C000000000003D0                                                                          
        Capacity    : 200.00GB  
    .EXAMPLE
        IBM_Host_Volume_Map -UserName monitor_user -DeviceIP 8.8.8.8 -FilterType Host -Export yes
        Result filtered by host and exported to .\Host_Volume_Map_Result.csv
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$UserName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$DeviceIP,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("Host","Hostcluster")]
        [string]$FilterType = "Nofilter",
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","no")]
        [string]$Export = "no"
    )
    begin{
        <# suppresses error messages #>
        $ErrorActionPreference="SilentlyContinue"
        <# create a array #>
        $TD_Mappingresault = @()
        <# int for the progressbar #>
        [int]$nbr=0

        <# Connection to the system via ssh and filtering and provision of data #>
        $TD_CollectVolInfo = ssh $UserName@$DeviceIP "lshostvdiskmap -delim : && lsvdisk -delim :"
        $TD_CollectVolInfo = $TD_CollectVolInfo |Select-Object -Skip 1
        $i = $TD_CollectVolInfo.Count

        0..$i |ForEach-Object {
            if($TD_CollectVolInfo[$_] -match '^id'){
                $TD_Resaults = $TD_CollectVolInfo | Select-Object -Skip ($_ +1)
                $i = $_
            }
        }       
    }
    process{
        foreach($line in $TD_CollectVolInfo){
            <# creates the objects for the array #>
            $TD_SplitInfos = "" | Select-Object HostID,HostName,HostCluster,VolumeID,VolumeName,UID,Capacity
            
            if($i -ge 1){
                if(($TD_HostIDold) -ne (($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[0])-and ($FilterType -eq "Host")){
                    $TD_SplitInfos.HostID = ($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[0]
                    $TD_SplitInfos.HostName = ($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[1]
                    $TD_SplitInfos.VolumeID = ($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[3]
                    $TD_SplitInfos.VolumeName = ($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[4]
                    $TD_SplitInfos.UID = ($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[5]
                    $TD_HostIDold = $TD_SplitInfos.HostID
                    $FilterTypeHost =$true
                }elseif (($TD_HostClusterOld) -ne (($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[10])-and ($FilterType -eq "Hostcluster")){
                    $TD_SplitInfos.HostCluster = ($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[10]
                    $TD_SplitInfos.VolumeID = ($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[3]
                    $TD_SplitInfos.VolumeName = ($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[4]
                    $TD_SplitInfos.UID = ($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[5]
                    $TD_HostClusterOld = $TD_SplitInfos.HostCluster
                    $FilterTypeHostCluster =$true
                }elseif (($FilterType -eq "Nofilter")) {
                    $TD_SplitInfos.HostID = ($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[0]
                    $TD_SplitInfos.HostName = ($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[1]
                    $TD_SplitInfos.HostCluster = ($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[10]
                    $TD_SplitInfos.VolumeID = ($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[3]
                    $TD_SplitInfos.VolumeName = ($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[4]
                    $TD_SplitInfos.UID = ($line | Select-String -Pattern '([a-zA-Z0-9_-]+)' -AllMatches).Matches.Value[5]
                }
                foreach ($resault in $TD_Resaults) {
                    <# Searches the capacity of the volumes using the UID of the volumes. #>
                    if(($TD_SplitInfos.UID) -eq (($resault | Select-String -Pattern '([0-9A-F]{32})' -AllMatches).Matches.Groups[1].Value)){
                        $TD_SplitInfos.Capacity = ($resault | Select-String -Pattern '(\d+\.\d+[B-T]+)' -AllMatches).Matches.Groups[1].Value
                        break
                    }
                }
                <#
                    Is required to avoid empty lines and to ensure that only the required data is made available.
                    A better option is currently being tested 
                #>
                if($FilterTypeHost -or $FilterTypeHostCluster){
                    $FilterTypeHost = $false; $FilterTypeHostCluster = $false
                    $TD_Mappingresault += $TD_SplitInfos
                }elseif($FilterType -eq "Nofilter") {
                    $TD_Mappingresault += $TD_SplitInfos
                }
                $i--
            }
            <# Progressbar  #>
            $nbr++
            $Completed = ($nbr/$TD_CollectVolInfo.Count) * 100
            Write-Progress -Activity "Create the list" -Status "Progress:" -PercentComplete $Completed
        }
    }
    end{
        <# exported to .\Host_Volume_Map_Result.csv #>
        if($Export -eq "yes"){
            $TD_Mappingresault | Export-Csv -Path .\Host_Volume_Map_Result.csv -NoTypeInformation
        }else {
            return $TD_Mappingresault
        }
    }
}