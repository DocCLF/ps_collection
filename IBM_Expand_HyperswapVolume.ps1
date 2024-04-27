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
        [Parameter(ValueFromPipeline)]
        [string]$FilterName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [Int32]$expand_size,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateSet("b","kb","mb","gb","tb","pb")]
        [string]$unit
    )
 
    $TD_CollectVolInfo = ssh $UserName@$DeviceIP "lsvdisk"
    Start-Sleep -Seconds 3
    foreach($TD_info in $TD_CollectVolInfo) {
        $TD_Vol_Info = ($TD_info | Select-String -Pattern '^\d+\s+(\w+_\d+)' -AllMatches).Matches.Groups.Value[1]
        Write-Debug -Message $Vol_Info
        if($TD_Vol_Info -like "$($FilterName)*"){
            <# To prevent duplicate entries #>
            if($TD_Temp -eq $TD_Vol_Info){break}
            <# Returns the command for the cli. #>
            Write-Host "svctask expandvolume -size $expand_size -unit $unit $TD_Vol_Info"
        }
        <# Copy the current value to the temp value for the duplicate check #>
        $TD_Temp = $TD_Vol_Info
    }
    <# Tidying up for the conscience #>
    Clear-Variable TD* -Scope Global;
}