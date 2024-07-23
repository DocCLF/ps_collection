
function FOS_SwitchShowInfo {
    <#
    .SYNOPSIS
        Get switch and port status.
    .DESCRIPTION
        Use this command to display switch, blade, and port status information. Output may vary depending on the switch model.
    .NOTES
        Need infos to be added   
    .LINK
        Brocade® Fabric OS® Command Reference Manual, 9.2.x
        https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-2-x/Fabric-OS-Commands/switchShow_921.html
    .EXAMPLE
        GET_BasicSwitchInfos -FOS_MainInformation $yourvarobject
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
    
    begin {
        <# suppresses error messages #>
        $ErrorActionPreference="SilentlyContinue"
        Write-Debug -Message "Start Func GET_SwitchShowInfo |$(Get-Date)`n "
        <#----- Array for information of the switchports ----#>
        $FOS_SwBasicPortDetails=@()
        <#----- Array for information of the used switchports ----#>
        $FOS_usedPorts =@()
        <# int for the progressbar #>
        [int]$nbr=0

        <# Connection to the system via ssh and filtering and provision of data #>
        <# Action when all if and elseif conditions are false #>
        if($TD_Device_ConnectionTyp -eq "ssh"){
            $FOS_MainInformation = ssh $TD_Device_UserName@$TD_Device_DeviceIP "switchshow"
        }else {
            $FOS_MainInformation = plink $TD_Device_UserName@$TD_Device_DeviceIP -pw $TD_Device_PW -batch "switchshow"
        }
        <# next line one for testing #>
        #$FOS_MainInformation = Get-Content -Path "C:\Users\mailt\Documents\swsh.txt"
        Out-File -FilePath $Env:TEMP\$($TD_Line_ID)_SwitchShow_Temp.txt -InputObject $FOS_MainInformation
        
        $FOS_InfoCount = $FOS_MainInformation.count
        Write-Debug -Message "Number of Lines: $FOS_InfoCount "
        0..$FOS_InfoCount |ForEach-Object {
            # Pull only the effective ZoneCFG back into ZoneList
            if($FOS_MainInformation[$_] -match '^Index'){
                if($FOS_MainInformation[$_] -match '^\s+frames'){break}
                $FOS_SWShowTemp = $FOS_MainInformation |Select-Object -Skip $_
                $FOS_SwShowArry_temp = $FOS_SWShowTemp |Select-Object -Skip 2   
            }
        }
    }
    
    process {
        Write-Debug -Message "Process Func GET_SwitchShowInfo |$(Get-Date)`n "
        <# fill the var with a dummy #>
        $FOS_PortConnect = "empty"

        foreach($FOS_linebyLine in $FOS_SwShowArry_temp){

            <# Only collect data up to the next section, marked by frames #>
            if($FOS_linebyLine -match '^\s+frames'){break}
    
            # Build the Portsection of switchshow
            if($FOS_linebyLine -match '^\s+\d+'){   # (\d+\.\d\w|\d+)
                $FOS_SWsh = "" | Select-Object Index,Port,Address,Media,Speed,State,Proto,PortConnect
                <# Port index is a number between 0 and the maximum number of supported ports on the platform. The port index identifies the port number relative to the switch. #>
                $FOS_SWsh.Index = ($FOS_linebyLine |Select-String -Pattern '^\s+(\d+)' -AllMatches).Matches.Groups.Value[1]
                <# Port number; 0-15, 0-31, or 0-63. #>
                $FOS_SWsh.Port = ($FOS_linebyLine |Select-String -Pattern '^\s+\d+\s+(\d+)' -AllMatches).Matches.Groups.Value[1]
                <# The 24-bit Address Identifier. #>
                $FOS_SWsh.Address = ($FOS_linebyLine |Select-String -Pattern '(\d+[a-z]+\d+|\d+)' -AllMatches).Matches.Value[3]
                <# Media types means module types #>
                $FOS_SWsh.Media = ($FOS_linebyLine |Select-String -Pattern '\s+(id|--|cu)\s+' -AllMatches).Matches.Groups.Value[1]
                <# The speed of the port. #>
                $FOS_SWsh.Speed = ($FOS_linebyLine |Select-String -Pattern '\s+(id|--|cu)\s+(N\d+|\d+G|AN|UN)' -AllMatches).Matches.Groups.Value[2]
                <# Port state information #>
                $FOS_SWsh.State = ($FOS_linebyLine |Select-String -Pattern '(\w+_\w+|\w+)\s+(FC)' -AllMatches).Matches.Groups.Value[1]
                <# Protocol support by GbE port. #>
                $FOS_SWsh.Proto = ($FOS_linebyLine |Select-String -Pattern '(\w+_\w+|\w+)\s+(FC)' -AllMatches).Matches.Groups.Value[2]
                <# WWPN or other Infos #>
                $FOS_PortConnect = ($FOS_linebyLine |Select-String -Pattern '(E-Port\s+([0-9a-f]{2}:){7}[0-9a-f]{2}\s+.*\))' -AllMatches).Matches.Groups.Value[1]
                If($FOS_PortConnect -ne "empty"){
                    $FOS_SWsh.PortConnect =$FOS_PortConnect
                    $FOS_PortConnect = "empty"
                }else{
                    $FOS_SWsh.PortConnect = ($FOS_linebyLine |Select-String -Pattern '\s+(FC)\s+([A-Za-z-]+\s+([0-9a-f]{2}:){7}[0-9a-f]{2}|\(.*\)|[A-Za-z-]+.*)' -AllMatches).Matches.Groups.Value[2]
                }
                $FOS_SwBasicPortDetails += $FOS_SWsh
            }
            # if the Portnumber is not empty and there is a SFP pluged in, push the Port in the FOS_usedPorts array
            if(($FOS_SWsh.Port -ne "") -and ($FOS_SWsh.Media -eq "id")){$FOS_usedPorts += $FOS_SWsh.Port}
        }
    }
    
    end {
        <# returns the hashtable for further processing, not mandatory but the safe way #>
        Write-Debug -Message "End Func GET_SwitchShowInfo |$(Get-Date)`n "
        <# export y or n #>
        if($TD_Export -eq "yes"){
            <# exported to .\Host_Volume_Map_Result.csv #>
            if([string]$TD_Exportpath -ne "$PSRootPath\Export\"){
                $FOS_SwBasicPortDetails | Export-Csv -Path $TD_Exportpath\$($TD_Line_ID)_SwitchShow_Result_$(Get-Date -Format "yyyy-MM-dd").csv -NoTypeInformation
            }else {
                $FOS_SwBasicPortDetails | Export-Csv -Path $PSScriptRoot\Export\$($TD_Line_ID)_SwitchShow_Result_$(Get-Date -Format "yyyy-MM-dd").csv -NoTypeInformation
            }
            Write-Host "The Export can be found at $TD_Exportpath " -ForegroundColor Green
            #Invoke-Item "$TD_Exportpath\Host_Volume_Map_Result_$(Get-Date -Format "yyyy-MM-dd").csv"
        }else {
            <# output on the promt #>
            return $FOS_SwBasicPortDetails
        }
        Write-Debug -Message "$(Get-Date) return:`n $FOS_SwBasicPortDetails `n "
        Write-Debug -Message "$(Get-Date) return:`n $FOS_usedPorts `n "

        <# FOS_usedPorts commented out can be used later via filter option if necessary #>
        return $FOS_SwBasicPortDetails #, $FOS_usedPorts 

        <# Cleanup all TD* Vars #>
        Clear-Variable FOS* -Scope Global
    }
}
