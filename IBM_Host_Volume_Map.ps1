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
        [string]$FilterType = "Nofilter",
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","no")]
        [string]$Export = "yes"
    )
    begin{

        $TD_Mappingresault = @()
        [int]$nbr=0

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
            $TD_SplitInfos = "" | Select-Object HostID,HostName,HostCluster,VolumeID,VolumeName,UID,Capacity

            <# only the Hostblock #>
            if($i -ge 1){
                if(($TD_HostIDold) -ne (($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[0])-and ($FilterType -eq "Host")){
                    $TD_SplitInfos.HostID = ($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[0]
                    $TD_SplitInfos.HostName = ($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[1]
                    $TD_HostIDold = $TD_SplitInfos.HostID

                }elseif (($TD_HostClusterOld) -ne (($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[10])-and ($FilterType -eq "Hostcluster")){
                    $TD_SplitInfos.HostCluster = ($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[10]
                    $TD_HostClusterOld = $TD_SplitInfos.HostCluster
                }
                elseif (($FilterType -eq "Nofilter")) {
                    $TD_SplitInfos.HostID = ($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[0]
                    $TD_SplitInfos.HostName = ($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[1]
                    $TD_SplitInfos.HostCluster = ($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[10]
                }
                $TD_SplitInfos.VolumeID = ($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[3]
                $TD_SplitInfos.VolumeName = ($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[4]
                $TD_SplitInfos.UID = ($line | Select-String -Pattern '\b(\w+)' -AllMatches).Matches.Value[5]
                
                foreach ($resault in $TD_Resaults) {

                    if(($TD_SplitInfos.UID) -eq (($resault | Select-String -Pattern '([0-9A-F]{32})' -AllMatches).Matches.Groups[1].Value)){
                        $TD_SplitInfos.Capacity = ($resault | Select-String -Pattern '(\d+\.\d+[B-T]+)' -AllMatches).Matches.Groups[1].Value
                        break
                    }
                }

                $TD_Mappingresault += $TD_SplitInfos
                $i--
            }
            
            $nbr++
            $Completed = ($nbr/$TD_CollectVolInfo.Count) * 100
            Write-Progress -Activity "Create the list" -Status "Progress:" -PercentComplete $Completed
        }
            
    }

    
    end{
        if($Export -eq "yes"){
            $TD_Mappingresault | Export-Csv -Path .\Host_Volume_Map_Result.csv -NoTypeInformation
        }
        
        return $TD_Mappingresault
    }
    
}