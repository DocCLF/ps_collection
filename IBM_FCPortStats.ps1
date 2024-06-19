function IBM_FCPortStats {
    <#
    .SYNOPSIS
        Display the PortStats of IBM SVC & Storage
    .DESCRIPTION
        To view the port transfer and failure counts and Small Form-factor Pluggable (SFP) diagnostics data that is recorded in the statistics file for a node.
    .NOTES
        Supported with IBM Storage Virtualize 8.4.x and higher
    .NOTES
        Version:
        1.0.1 Initail Release
    .LINK
        IBM Doku to lsportstats
        https://www.ibm.com/docs/en/flashsystem-5x00/8.5.x?topic=commands-lsportstats
    .EXAMPLE
        Note: You need an admin account and you should use the cluster IP to get all data of all devices.
        IBM_Enclosure_FCPortStats -TD_UserName AdminUser -TD_DeviceIP 1.1.1.1

        IBM_Enclosure_FCPortStats -TD_UserName AdminUser -TD_DeviceIP 1.1.1.1 -TD_export yes

        IBM_Enclosure_FCPortStats -TD_UserName AdminUser -TD_DeviceIP 1.1.1.1 -TD_Storage FSystem -TD_export yes

        IBM_Enclosure_FCPortStats -TD_UserName AdminUser -TD_DeviceIP 1.1.1.1 -TD_Storage SVC -TD_export yes
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Int16]$TD_Line_ID = 0,
        [Parameter(Mandatory)]
        [string]$TD_Device_ConnectionTyp,
        [Parameter(Mandatory)]
        [string]$TD_Device_UserName,
        [Parameter(Mandatory)]
        [string]$TD_Device_DeviceIP,
        [string]$TD_Device_PW,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("FSystem","SVC")]
        [string]$TD_Storage = "FSystem",
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","no")]
        [string]$TD_export = "yes",
        [string]$TD_Exportpath
    )
    begin {
        <# suppresses error messages #>
        $ErrorActionPreference="SilentlyContinue"
        $TD_PortStats_Overview = @()
        $NodeList =@()
        [int]$ProgCounter=0
        [int]$i=0
        $test =@('enclosure_serial_number','panel_name','id','name','WWNN','Nn_stats','type','port','wwpn','lf','lsy','lsi','pspe','itw','icrc','bbcz','tmp','txpwr','rxpwr')
        <# Connect to Device and get all needed Data #>
        if($TD_Storage -eq "FSystem"){
            if($TD_Device_ConnectionTyp -eq "ssh"){
                $TD_CollectInfos = ssh $TD_Device_UserName@$TD_Device_DeviceIP 'lsnodecanister -nohdr |while read id name IO_group_id;do lsnodecanister $id;echo;done && lsnodecanister -nohdr |while read id name IO_group_id;do lsportstats -node $id ;echo;done'
            }else{
                $TD_CollectInfos = plink $TD_Device_UserName@$TD_Device_DeviceIP -pw $TD_Device_PW -batch 'lsnodecanister -nohdr |while read id name IO_group_id;do lsnodecanister $id;echo;done && lsnodecanister -nohdr |while read id name IO_group_id;do lsportstats -node $id ;echo;done'
            }
        }else {
            if($TD_Device_ConnectionTyp -eq "ssh"){
                $TD_CollectInfos = ssh $TD_Device_UserName@$TD_Device_DeviceIP 'lsnode -nohdr |while read id name IO_group_id;do lsnode $id;echo;done && lsnode -nohdr |while read id name IO_group_id;do lsportstats -node $id ;echo;done'
            }else{
                $TD_CollectInfos = plink $TD_Device_UserName@$TD_Device_DeviceIP -pw $TD_Device_PW -batch 'lsnode -nohdr |while read id name IO_group_id;do lsnode $id;echo;done && lsnode -nohdr |while read id name IO_group_id;do lsportstats -node $id ;echo;done'
            }
        }
        Start-Sleep -Seconds 1
    }
    process {
        <#  #>
        foreach($TD_CollectInfo in $TD_CollectInfos){
            if(Select-String -InputObject $TD_CollectInfo -Pattern $test){ 
                <# Node Info#>
                [int]$TD_NodeID = ($TD_CollectInfo|Select-String -Pattern '^id\s+(\d+)' -AllMatches).Matches.Groups[1].Value
                #[string]$TD_NodeSN = ($TD_CollectInfo|Select-String -Pattern '^enclosure_serial_number\s([A-Za-z0-9]+)' -AllMatches).Matches.Groups[1].Value
                [string]$TD_NodeName = ($TD_CollectInfo|Select-String -Pattern '^name\s([a-zA-Z0-9-_]+)' -AllMatches).Matches.Groups[1].Value
                [string]$TD_NodeWWNN = ($TD_CollectInfo|Select-String -Pattern '^WWNN\s([0-9A-F]+)' -AllMatches).Matches.Groups[1].Value
                #[string]$TD_NodeSN = ($TD_CollectInfo|Select-String -Pattern '^panel_name\s([A-Za-z0-9]+)' -AllMatches).Matches.Groups[1].Value
                [string]$TD_NodeStatsID = ($TD_CollectInfo|Select-String -Pattern '^Nn_stats_([A-Za-z0-9]+)' -AllMatches).Matches.Groups[1].Value
                if($TD_NodeWWNN -ne ""){
                    Write-Debug -Message $TD_NodeSN
                    $TD_Node =[PSCustomObject]@{
                        NodeID = $TD_NodeID
                        #NodeSN = $TD_NodeSN
                        NodeName = $TD_NodeName
                        NodeWWNN = $TD_NodeWWNN
                    }
                    $NodeList += $TD_Node
                    $TD_NodeWWNN = ""
                }
                if($NodeList.Count -ge 1 -and $TD_NodeStatsID -ne ""){
                    $TD_NodeStatsID = ""
                    $TD_PortStatsSplitInfos = "" | Select-Object NodeID,NodeSN,NodeName,NodeWWNN,CardType,CardID,PortID,WWPN,LinkFailure,LoseSync,LoseSig,PSErrCount,InvTransErr,CRCErr,ZeroBtB,SFPTemp,TXPwr,RXPwr
                    [int]$TD_PortStatsSplitInfos.NodeID = $NodeList.NodeID[$i]
                    #[string]$TD_PortStatsSplitInfos.NodeSN = $NodeList.NodeSN[$i]
                    [string]$TD_PortStatsSplitInfos.NodeName = $NodeList.NodeName[$i]
                    [string]$TD_PortStatsSplitInfos.NodeWWNN = $NodeList.NodeWWNN[$i]
                    Write-Debug -Message $NodeList.NodeName[$i]
                    Write-Debug -Message $TD_NodeStatsID
                    $i++
                }
                <# Card Info #>
                [string]$TD_PortStatsSplitInfos.CardType = ($TD_CollectInfo|Select-String -Pattern '^typ.*(FC)' -AllMatches).Matches.Groups[1].Value
                [string]$TD_PortStatsSplitInfos.CardID = (($TD_CollectInfo|Select-String -Pattern '^type_id.*(\d)' -AllMatches).Matches.Value).Trim('type_id="')
                [string]$TD_PortStatsSplitInfos.PortID = (($TD_CollectInfo|Select-String -Pattern 'port\sid.*(\d)' -AllMatches).Matches.Value).Trim('port id="')
                [string]$TD_PortStatsSplitInfos.WWPN = (($TD_CollectInfo|Select-String -Pattern 'wwpn.*0x([0-9a-f]+)' -AllMatches).Matches.Groups[1].Value)
                <# diagnostics data #>
                <# Block 1#>
                [int]$TD_PortStatsSplitInfos.LinkFailure = ($TD_CollectInfo|Select-String -Pattern 'lf="(\d+)"' -AllMatches).Matches.Groups[1].Value
                [int]$TD_PortStatsSplitInfos.LoseSync = ($TD_CollectInfo|Select-String -Pattern 'lsy="(\d+)"' -AllMatches).Matches.Groups[1].Value
                [int]$TD_PortStatsSplitInfos.LoseSig = ($TD_CollectInfo|Select-String -Pattern 'lsi="(\d+)"' -AllMatches).Matches.Groups[1].Value
                [int]$TD_PortStatsSplitInfos.PSErrCount = ($TD_CollectInfo|Select-String -Pattern 'pspe="(\d+)"' -AllMatches).Matches.Groups[1].Value
                <# Block 2#>
                [int]$TD_PortStatsSplitInfos.InvTransErr = ($TD_CollectInfo|Select-String -Pattern 'itw="(\d+)"' -AllMatches).Matches.Groups[1].Value
                [int]$TD_PortStatsSplitInfos.CRCErr = ($TD_CollectInfo|Select-String -Pattern 'icrc="(\d+)"' -AllMatches).Matches.Groups[1].Value
                [int]$TD_PortStatsSplitInfos.ZeroBtB = ($TD_CollectInfo|Select-String -Pattern 'bbcz="(\d+)"' -AllMatches).Matches.Groups[1].Value
                <# Block 3#>
                [int]$TD_PortStatsSplitInfos.SFPTemp = ($TD_CollectInfo|Select-String -Pattern 'tmp="(\d+)"' -AllMatches).Matches.Groups[1].Value
                [int]$TD_PortStatsSplitInfos.TXPwr = ($TD_CollectInfo|Select-String -Pattern 'txpwr="(\d+)"' -AllMatches).Matches.Groups[1].Value
                [int]$TD_PortStatsSplitInfos.RXPwr = ($TD_CollectInfo|Select-String -Pattern 'rxpwr="(\d+)"' -AllMatches).Matches.Groups[1].Value
            }
            if(([String]::IsNullOrEmpty($TD_CollectInfo)) -or $TD_CollectInfo -eq "/>"){
                if($TD_PortStatsSplitInfos.CardType -ne "FC"){continue}
                $TD_PortStats_Overview += $TD_PortStatsSplitInfos
                $TD_NodeWWNN = ""
                $TD_PortStatsSplitInfos = "" | Select-Object CardType,CardID,PortID,WWPN,LinkFailure,LoseSync,LoseSig,PSErrCount,InvTransErr,CRCErr,ZeroBtB,SFPTemp,TXPwr,RXPwr
            }
            <# Progressbar  #>
            $ProgCounter++
            $Completed = ($ProgCounter/$NodeList.Count) * 100
            Write-Progress -Activity "Create the list" -Status "Progress:" -PercentComplete $Completed
        }
    }
    end {
        <# export y or n #>
        if($TD_export -eq "yes"){
            <# exported to .\Host_Volume_Map_Result.csv #>
            if([string]$TD_Exportpath -ne "$PSRootPath\Export\"){
                $TD_PortStats_Overview | Export-Csv -Path $TD_Exportpath\FCPortStatsOverview_$(Get-Date -Format "yyyy-MM-dd").csv -NoTypeInformation
            }else {
                $TD_PortStats_Overview | Export-Csv -Path $PSScriptRoot\Export\FCPortStatsOverview_$(Get-Date -Format "yyyy-MM-dd").csv -NoTypeInformation
            }
            Write-Host "The Export can be found at $TD_Exportpath " -ForegroundColor Green
            #Invoke-Item "$TD_Exportpath\FCPortStatsOverview_$(Get-Date -Format "yyyy-MM-dd").csv"
        }else {
            <# output on the promt #>
            Write-Host "Result:`n" -ForegroundColor Yellow
            Start-Sleep -Seconds 2.5
            return $TD_PortStats_Overview
        }
        <# wait a moment #>
        Start-Sleep -Seconds 1
        <# Cleanup all TD* Vars #>
        Clear-Variable TD* -Scope Global
    }
}
