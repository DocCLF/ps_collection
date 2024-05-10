function IBM_Expand_HyperswapVolume {
    <#
    .SYNOPSIS
        Expand Hyperswap-Volumes
    .DESCRIPTION
        The function queries the volumes created on the system via ssh and "lsvdisk" and saves them temporarily in an array.
        The command for extending all hyperswap volumes found is then created and returned to the console via write host.
        This command can then be copied to the console of the storage system.
        Setting options are the size in connection with the unit.
        The function does not exempt you from checking or questioning the command!
    .NOTES
        This function only supports IBM FlashStorage systems starting with version 8.3.x in a hyperswap configuration
        You can expand the size of HyperSwap volumes provided:
        - All copies of the volume are synchronized.
        - All copies of the volume are thin or compressed.
        - There are no mirrored copies.
        - The volume is not in a consistency group. To expand the volume, you must remove the active-active relationship for the volume from the remote copy consistency group. 
          The active-active relationship can be added back to the consistency group after the volume is expanded.
    .LINK
        https://www.ibm.com/docs/en/flashsystem-5x00/8.3.x?topic=commands-expandvolume
    .EXAMPLE
        IBM_Expand_HyperswapVolume -UserName superuser -DeviceIP 192.16.12.1 -expand_size 128849018880 -unit b

        Result: svctask expandvolume -size 10 -unit gb ExampleVolume_01    
    .EXAMPLE
        IBM_Expand_HyperswapVolume -UserName superuser -DeviceIP 192.16.12.1 -FilterName Volu -expand_size 128849018880 -unit b

        Result: svctask expandvolume -size 128849018880 -unit b VolumeName_01        
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
        [Int32]$expand_size,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("b","kb","mb","gb","tb","pb")]
        [string]$unit
    )
    
    $ErrorActionPreference="SilentlyContinue"

    $TD_CollectVolInfo = ssh $UserName@$DeviceIP "lsvdisk"
    Start-Sleep -Seconds 3
    foreach($TD_info in $TD_CollectVolInfo) {
        $TD_Vol_Info = ($TD_info | Select-String -Pattern '^\d+\s+(\w+_\d+)' -AllMatches).Matches.Groups.Value[1]
        Write-Debug -Message $TD_Vol_Info
        if($TD_Vol_Info -like "$($FilterName)*"){
            <# To prevent duplicate entries #>
            if($TD_Temp -eq $TD_Vol_Info){break}

            <# Returns the command for the cli. #>
            if($expand_size -ne "") {
                if($unit -eq ""){Write-Host "If a expand size is specified, we also need a size specification of a unit such as kb,mb,gb,tb, etc.!" -ForegroundColor Red; Start-Sleep -Seconds 5; exit}
                Write-Host "svctask expandvolume -size $expand_size -unit $unit $TD_Vol_Info"
            }else {
                Write-Host "These volumes were found with the specified filters:`n"
            }
        }
        <# Copy the current value to the temp value for the duplicate check #>
        $TD_Temp = $TD_Vol_Info
    }
    Write-Host "`n#Use the expandvolume command ONLY to expand the size of a HyperSwap® volume by a specified capacity.`n" -ForegroundColor Yellow
    Write-Host "`n#And last but not least, if you are not sure then please: 'RTFM'! ;) " -ForegroundColor Red
    <# Tidying up for the conscience #>
    Clear-Variable TD* -Scope Global;
}