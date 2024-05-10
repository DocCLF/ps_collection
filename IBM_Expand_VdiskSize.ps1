function IBM_Expand_VdiskSize {
    <#
    .SYNOPSIS
        Get back the cli-command to expand non-Hyperswap Volumes
    .DESCRIPTION
        With the help of this function, the powershell connects to the specified storage system and collects the names of all volumes or the volume names specified in the filter with a wildcard. 
        All unnecessary data will be removed and the command for volume expansion is listed in the prompt.

        You can expand the capacity of any volume in a Global Mirror or Metro Mirror relationship that is in a consistent_synchronized state.
        You must expand both volumes in a relationship to maintain full operation of the system. 
        To perform this task:
        1. Expand the secondary volume by the required extra capacity.
        2. Expand the primary volume by the required extra capacity.

        Volumes in Metro Mirror and Global Mirror relationships cannot be expanded if any of these conditions are true:
        - Volumes are in Global Mirror relationships that are operating in cycling mode.
        - Volumes are in relationships where a change volume is configured. The change volume must be removed from the relationship before the volume can be expanded.

        You cannot use the expandvdisksize command to expand HyperSwap® volumes, instead use the expandvolume command.

        You cannot expand the capacity of any volume in a migration relationship.

        Only a user with the security administrator or the superuser role is permitted to use expandvdisksize to change the capacity of a Safeguarded backup copy.
    .NOTES
        This function only supports IBM FlashStorage systems starting with version 8.3.x
    .LINK
        https://www.ibm.com/docs/en/flashsystem-5x00/8.6.x?topic=vc-expandvdisksize
    .EXAMPLE
        IBM_Expand_VdiskSize -UserName superuser -DeviceIP 192.16.12.1 -expand_size 128849018880 -unit b

        Result: svctask expandvdisksize -size 10 -unit gb ExampleVolume_01    
    .EXAMPLE
        IBM_Expand_VdiskSize -UserName superuser -DeviceIP 192.16.12.1 -FilterName Volu -expand_size 128849018880 -unit b

        Result: svctask expandvdisksize -size 128849018880 -unit b VolumeName_01        
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$UserName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$DeviceIP,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$FilterName,
        [Parameter(ValueFromPipeline)]
        [Int32]$expand_size = 0,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("b","kb","mb","gb","tb","pb")]
        [string]$unit
    )
 
    $ErrorActionPreference="SilentlyContinue"

    $TD_CollectVolInfo = ssh $UserName@$DeviceIP "lsvdisk"
    Start-Sleep -Seconds 3
    foreach($TD_info in $TD_CollectVolInfo) {
        $TD_Vol_Info = ($TD_info | Select-String -Pattern '^\d+\s+([a-zA-Z0-9_-]*)\s+' -AllMatches).Matches.Groups.Value[1]
        Write-Debug -Message $TD_Vol_Info
        if($TD_Vol_Info -like "$($FilterName)*"){
            <# To prevent duplicate entries #>
            if($TD_Temp -eq $TD_Vol_Info){break}
            <# Returns the command for the cli. #>
            if($expand_size -gt 0) {
                if($unit -eq ""){Write-Host "If a expand size is specified, we also need a size specification of a unit such as kb,mb,gb,tb, etc.!" -ForegroundColor Red; Start-Sleep -Seconds 5; exit}
                Write-Host "svctask expandvdisksize -size $expand_size -unit $unit $TD_Vol_Info"
            }else {
                Write-host $TD_Vol_Info
            }
            
        }
        <# Copy the current value to the temp value for the duplicate check #>
        $TD_Temp = $TD_Vol_Info
    }
    Write-Host "`n`nRemember:`n1. You cannot resize (expand) an image mode volume.`n2. You cannot resize (expand) a volume if cloud snapshot is enabled on that volume.`n3. You cannot specify expandvdisksize -rsize to expand (resize) a thin or compressed volume copy that is in a data reduction pool.`n4. You cannot specify expandvdisksize -mdisk to resize (expand) a volume when a volume is being migrated." -ForegroundColor Yellow
    Write-Host "`n#And last but not least, if you are not sure then please: 'RTFM'! ;) " -ForegroundColor Red
    
    <# Tidying up for the conscience #>
    Clear-Variable TD* -Scope Global;
}