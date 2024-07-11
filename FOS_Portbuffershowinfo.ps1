
function FOS_PortbufferShowInfo {
    <#
    .SYNOPSIS
    Displays the buffer usage information for a port group or for all port groups in the switch.

    .DESCRIPTION
    Use this command to display the current long distance buffer information for the ports in a port group. 
    The port group can be specified by giving any port number in that group. If no port is specified, 
    then the long distance buffer information for all of the port groups of the switch is displayed.    

    .EXAMPLE
    Get_PortbufferShowInfo -FOS_MainInformation $PortBufferShowOutPut

    $PortBufferShowOutPut means the content of the cli outcome from "portbuffershow"
            
    .LINK
    Brocade® Fabric OS® Command Reference Manual, 9.2.x
    https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-2-x/Fabric-OS-Commands/portBufferShow.html
    #>
    [CmdletBinding()]
    param (
        [Int16]$TD_Line_ID,
        [string]$TD_Device_ConnectionTyp,
        [string]$TD_Device_UserName,
        [string]$TD_Device_DeviceIP,
        [string]$TD_Device_PW,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","no")]
        [string]$TD_Export = "yes",
        [string]$TD_Exportpath,
        [string]$TD_RefreshView
    )

    begin{
        <# suppresses error messages #>
        $ErrorActionPreference="SilentlyContinue"
        Write-Debug -Message "Start Func Get_PortbufferShowInfo |$(Get-Date)` "

        if($TD_Device_ConnectionTyp -eq "ssh"){
            Write-Debug -Message "ssh |$(Get-Date)"
            $FOS_MainInformation = ssh $TD_Device_UserName@$TD_Device_DeviceIP "portbuffershow"
        }else {
            Write-Debug -Message "plink |$(Get-Date)"
            $FOS_MainInformation = plink $TD_Device_UserName@$TD_Device_DeviceIP -pw $TD_Device_PW -batch "portbuffershow"
        }
        <# next line one for testing #>
        #$FOS_MainInformation=Get-Content -Path "C:\Users\mailt\Documents\pbs_s.txt"
        Out-File -FilePath $Env:TEMP\$($TD_Line_ID)_PortBufferShow_Temp.txt -InputObject $FOS_MainInformation

        <# Create an array #>
        $FOS_pbs =@()
        $FOS_InfoCount = $FOS_MainInformation.count
        0..$FOS_InfoCount |ForEach-Object {
            # Pull only the effective ZoneCFG back into ZoneList
            if($FOS_MainInformation[$_] -match 'Buffers$'){
                $FOS_pbs_temp = $FOS_MainInformation |Select-Object -Skip $_
                $FOS_Temp_var = $FOS_pbs_temp |Select-Object -Skip 2
            
            }
        }
    }

    process{
        foreach ($FOS_thisLine in $FOS_Temp_var) {
            <# Only collect data up to the next section, marked by Defined #>
            if($FOS_thisLine -match '^Defined'){break}

            #create a var and pipe some objects in and fill them with some data
            $FOS_PortBuff = "" | Select-Object Port,Type,Mode,Max_Resv,Tx,Rx,Usage,Buffers,Distance,Buffer
            # Index number of the port.
            $FOS_PortBuff.Port = ($FOS_thisLine |Select-String -Pattern '^\s+(\d+)' -AllMatches).Matches.Groups.Value[1]
            # E (E_Port), F (F_Port), G (G_Port), L (L_Port), or U (U_Port).
            $FOS_PortBuff.Type = ($FOS_thisLine |Select-String -Pattern '([EFGLU])' -AllMatches).Matches.Groups.Value[1]
            # Long distance mode. L0 -> Link is not in long distance mode. LE -> Link is up to 10 km. LD -> Distance is determined dynamically. LS -> Distance is determined statically by user input.
            $FOS_PortBuff.LX_Mode = ($FOS_thisLine |Select-String -Pattern '(LE|LD|L0|LS)' -AllMatches).Matches.Groups.Value[1]
            # The maximum or reserved number of buffers that are allocated to the port based on the estimated distance.
            $FOS_PortBuff.Max_Resv = ($FOS_thisLine |Select-String -Pattern '(\d+)\s+(\d+\(|-\s\()' -AllMatches).Matches.Groups.Value[1]
            # The average buffer usage and average frame size for Tx and Rx.
            $FOS_PortBuff.Tx = ($FOS_thisLine |Select-String -Pattern '(\d+\(\d+\)|\d\(\s\d+\)|-\s\(\s\d+\)|-\s\(\s+\d+\)|-\s\(\d+\)|-\s\(\s+-\s+\))' -AllMatches).Matches.Groups.Value[1]
            $FOS_PortBuff.Rx = ($FOS_thisLine |Select-String -Pattern '(\d+\(\d+\)|\d\(\s\d+\)|-\s\(\s\d+\)|-\s\(\s+\d+\)|-\s\(\d+\)|-\s\(\s+-\s+\))' -AllMatches).Matches.Value[1]
            # The actual number of buffers allocated to the port.
            $FOS_PortBuff.Usage = ($FOS_thisLine |Select-String -Pattern '\)\s+(\d+)\s+' -AllMatches).Matches.Groups.Value[1]
            # The number of buffers needed to utilize the port at full bandwidth (depending on the port configuration).
            $FOS_PortBuff.Buffers = ($FOS_thisLine |Select-String -Pattern '\)\s+(\d+)\s+(\d+|-)' -AllMatches).Matches.Groups.Value[2]
            <# For L0 (not in long distance mode), the command displays the fixed distance based on port speed, for instance: 10 km (1G), 5 km (2G), 2 km (4G), 1 km (8G), or upto 150 meters for all other port speed. 
            For static long distance mode (LE), the fixed distance of 10 km displays. For LD mode, the distance in kilometers displays as measured by timing the return trip of a MARK primitive that is sent and then echoed back to the switch. 
            LD mode supports distances up to 500 km. Distance measurement on a link longer than 500 km might not be accurate. If the connecting port does not support LD mode, is shows "N/A". #>
            $FOS_PortBuff.Distance = ($FOS_thisLine |Select-String -Pattern '\d\s+(\d+|-)\s+(\d+km|\<\d+km|-)' -AllMatches).Matches.Groups.Value[2]
            # The remaining (unallocated) buffers available for allocation in this group.
            $FOS_PortBuff.Buffer = ($FOS_thisLine |Select-String -Pattern '\s+(\d+)$' -AllMatches).Matches.Groups.Value[1]
            
            <# add the values to the array #>
            $FOS_pbs += $FOS_PortBuff
        }
    }

    end {
        <# returns the hashtable for further processing, not mandatory but the safe way #>
        Write-Debug -Message "Start End-Block GET_PortBufferShowInfos |$(Get-Date) ` "

        <# export y or n #>
        if($TD_Export -eq "yes"){
            <# exported to .\Host_Volume_Map_Result.csv #>
            if([string]$TD_Exportpath -ne "$PSRootPath\Export\"){
                $FOS_pbs | Export-Csv -Path $TD_Exportpath\$($TD_Line_ID)_PortBufferShow_Result_$(Get-Date -Format "yyyy-MM-dd").csv -NoTypeInformation
            }else {
                $FOS_pbs | Export-Csv -Path $PSScriptRoot\Export\$($TD_Line_ID)_PortBufferShow_Result_$(Get-Date -Format "yyyy-MM-dd").csv -NoTypeInformation
            }
            Write-Host "The Export can be found at $TD_Exportpath " -ForegroundColor Green
            #Invoke-Item "$TD_Exportpath\Host_Volume_Map_Result_$(Get-Date -Format "yyyy-MM-dd").csv"
        }else {
            <# output on the promt #>
            return $FOS_pbs
        }

        return $FOS_pbs
        
    }
}