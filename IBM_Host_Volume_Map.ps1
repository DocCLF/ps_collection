function IBM_Host_Volume_Map {
    <#
    .SYNOPSIS
        Displays a list of host/cluster and there volume relationships
    .NOTES
        v1.0.2
        * fix: TD_* Wildcard at Username, DeviceIP and Export

        v1.0.1
        This function displays a list of volume IDs, names and more. 
        These volumes are the volumes that are mapped to the specified host or hostcluster.  
    .NOTES
        Tested with version IBM Spectrum Virtualize Software 7.8.x to 8.6.x
    .LINK
        https://github.com/DocCLF/ps_collection/blob/main/IBM_Host_Volume_Map.ps1
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
        Result filtered by host and exported to .\Host_Volume_Map_Result_(current date).csv
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
        <# suppresses error messages #>
        $ErrorActionPreference="SilentlyContinue"
        <# create a array #>
        $TD_Mappingresault = @()
        <# int for the progressbar #>
        [int]$nbr=0
        <# Connection to the system via ssh and filtering and provision of data #>
        if($TD_RefreshView -eq "Update"){
            $TD_CollectVolInfo = Get-Content -Path $Env:TEMP\$($TD_Line_ID)_Host_Vol_Map_Temp.txt
            $TD_RefreshView = "Done"
        }else {
            <# Action when all if and elseif conditions are false #>
            if($TD_Device_ConnectionTyp -eq "ssh"){
                $TD_CollectVolInfo = ssh $TD_Device_UserName@$TD_Device_DeviceIP "lshostvdiskmap -delim : && lsvdisk -delim :"
            }else {
                $TD_CollectVolInfo = plink $TD_Device_UserName@$TD_Device_DeviceIP -pw $TD_Device_PW -batch "lshostvdiskmap -delim : && lsvdisk -delim :"
            }
            <# next line one for testing #>
            #$TD_CollectVolInfo = Get-Content -Path "C:\Users\mailt\Documents\lsvdho.txt"
            Out-File -FilePath $Env:TEMP\$($TD_Line_ID)_Host_Vol_Map_Temp.txt -InputObject $TD_CollectVolInfo
        }
        
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
        <# export y or n #>
        if($TD_Export -eq "yes"){
            <# exported to .\Host_Volume_Map_Result.csv #>
            if([string]$TD_Exportpath -ne "$PSRootPath\Export\"){
                $TD_Mappingresault | Export-Csv -Path $TD_Exportpath\$($TD_Line_ID)_Host_Volume_Map_Result_$(Get-Date -Format "yyyy-MM-dd").csv -NoTypeInformation
            }else {
                $TD_Mappingresault | Export-Csv -Path $PSScriptRoot\Export\$($TD_Line_ID)_Host_Volume_Map_Result_$(Get-Date -Format "yyyy-MM-dd").csv -NoTypeInformation
            }
            Write-Host "The Export can be found at $TD_Exportpath " -ForegroundColor Green
            #Invoke-Item "$TD_Exportpath\Host_Volume_Map_Result_$(Get-Date -Format "yyyy-MM-dd").csv"
        }else {
            <# output on the promt #>
            return $TD_Mappingresault
        }
        return $TD_Mappingresault |Select-Object -Skip 1
        <# wait a moment #>
        Start-Sleep -Seconds 1
        <# Cleanup all TD* Vars #>
        #Clear-Variable TD* -Scope Global
    }
}