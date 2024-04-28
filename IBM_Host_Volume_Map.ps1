function IBM_Host_Volume_Map {
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
        [string]$UserName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$DeviceIP,
        [Parameter(ValueFromPipeline)]
        [string]$FilterName
    )
    begin{
        $TD_Mappingresault = @()
        $TD_CollectVolInfo = ssh $UserName@$DeviceIP "lshostvdiskmap -delim : && lsvdisk -delim : $FilterName"
        $TD_CollectVolInfo = $TD_CollectVolInfo |Select-Object -Skip 1
    }
    process{
        foreach($line in $TD_CollectVolInfo){
            if(($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[0] -eq "id"){Write-Host "<###### --- Ende --- ######>" -ForegroundColor Red;break}
            $TD_SplitInfos = "" | Select-Object HostID,HostName,HostCluster,VolumeID,VolumeName,UID
            $TD_SplitInfos.HostID = ($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[0]
            $TD_SplitInfos.HostName = ($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[1]
            $TD_SplitInfos.HostCluster = ($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[10]
            $TD_SplitInfos.VolumeID = ($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[3]
            $TD_SplitInfos.VolumeName = ($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[4]
            $TD_SplitInfos.UID = ($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[5]
            
            $TD_Mappingresault += $TD_SplitInfos
        }
    }
    end{

    }
    
}