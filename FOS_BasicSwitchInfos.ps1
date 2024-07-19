function FOS_BasicSwitchInfos {
    <#
    .SYNOPSIS
        Creates a hashtable with Basic information about the switch.
    .DESCRIPTION
        Use this Function to display basic information about the switch. 
        This function uses various FOS commands to provide the required information.
        FOS Commands are firmwareshow, ipaddrshow, lscfg --show -n, switchshow 
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
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
        [string]$TD_Exportpath
    )
    
    begin {

        Write-Debug -Message "Start Func GET_BasicSwitchInfos |$(Get-Date)` "
        <# suppresses error messages #>
        $ErrorActionPreference="SilentlyContinue"

        <# Connect to Device and get all needed Data #>
        if($TD_Device_ConnectionTyp -eq "ssh"){
            $FOS_MainInformation = ssh $TD_Device_UserName@$TD_Device_DeviceIP 'firmwareshow && ipaddrshow && chassisshow && switchshow'
        }else {
            $FOS_MainInformation = plink $TD_Device_UserName@$TD_Device_DeviceIP -pw $TD_Device_PW -batch 'firmwareshow && ipaddrshow && chassisshow && switchshow'
        }
        <# next line is for tests #>
        #[System.Object]$FOS_MainInformation = Get-Content -Path "C:\Users\mailt\Documents\Export\san2.txt"

        <# Hashtable for BasicSwitch Info #>
        $FOS_SwGeneralInfos =[ordered]@{}
        
        <# collect the information with the help of regex pattern and remove the blanks with the help of replace and trim #>
        $FOS_LoSw_CFG = ($FOS_MainInformation | Select-String -Pattern 'switchName:\s+(.*)$','switchDomain:\s+(\d+)$','switchWwn:\s+(.*)$','\D\((\w+)\)$','^Serial\sNum\:\s+(.*)' |ForEach-Object {$_.Matches.Groups[1].Value})

        switch (($FOS_MainInformation | Select-String -Pattern 'switchType:\s+(\d.*)$' |ForEach-Object {$_.Matches.Groups[1].Value})) {
            {$_ -like "109*"}  { $FOS_SwHw = "Brocade 6510" }
            {$_ -like "118*"}  { $FOS_SwHw = "Brocade 6505" }
            {$_ -like "170*"}  { $FOS_SwHw = "Brocade G610" }
            {$_ -like "162*"}  { $FOS_SwHw = "Brocade G620" }
            {$_ -like "183*"}  { $FOS_SwHw = "Brocade G620" }
            {$_ -like "173*"}  { $FOS_SwHw = "Brocade G630" }
            {$_ -like "184*"}  { $FOS_SwHw = "Brocade G630" }
            {$_ -like "178*"}  { $FOS_SwHw = "Brocade 7810 Extension Switch" }
            {$_ -like "181*"}  { $FOS_SwHw = "Brocade G720" }
            {$_ -like "189*"}  { $FOS_SwHw = "Brocade G730" }
            Default {$FOS_SwHw = "Unknown Type"}
        }
    }
    
    process {
        Write-Debug -Message "Process Func GET_BasicSwitchInfos |$(Get-Date)` "

        <# add the values to the hashtable #>
        $FOS_SwGeneralInfos.Add('Swicht Name',$FOS_LoSw_CFG[1])
        $FOS_SwGeneralInfos.Add('Active ZonenCFG',$FOS_LoSw_CFG[4])
        $FOS_SwGeneralInfos.Add('DomainID',$FOS_LoSw_CFG[2])
        $FOS_SwGeneralInfos.Add('Switch WWN',$FOS_LoSw_CFG[3])

        <# Workaround if VF is not enabled #>
        $FOS_LoSw_Temp = (($FOS_MainInformation | Select-String -Pattern 'SwitchType:\s+(\w+)$' -AllMatches).Matches.groups[1].Value)
        if(!($FOS_LoSw_Temp)) {
            $FOS_SwGeneralInfos.Add('SwitchType','DS')
        }else {
            $FOS_SwGeneralInfos.Add('SwitchType',(($FOS_MainInformation | Select-String -Pattern 'SwitchType:\s+(\w+)$' -AllMatches).Matches.groups[1].Value))
        }
        if(($FOS_MainInformation | Select-String -Pattern '\[FID:\s(\d+)' |ForEach-Object {$_.Matches.Groups[1].Value}).count -eq 1) {
            $FOS_SwGeneralInfos.Add('Fabric ID',($FOS_MainInformation | Select-String -Pattern '\[FID:\s(\d+)' |ForEach-Object {$_.Matches.Groups[1].Value}))
        }else{
            $FOS_SwGeneralInfos.Add('Fabric ID','unknown')
        }

        $FOS_SwGeneralInfos.Add('Brocade Product Name',$FOS_SwHw)
        $FOS_SwGeneralInfos.Add('Serial Num',$FOS_LoSw_CFG[0])

        foreach ($lineUp in $FOS_MainInformation) {
            if($lineUp -match '^Index'){break}
            $FOS_SwGeneralInfos.Add('Fabric OS',(($lineUp| Select-String -Pattern 'FOS\s+([v?][\d]\.[\d+]\.[\d]\w)$').Matches.Groups[1].Value))
            $FOS_SwGeneralInfos.Add('Ethernet IP Address',(($lineUp| Select-String -Pattern 'Ethernet IP Address:\s+([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})').Matches.Groups[1].Value))
            $FOS_SwGeneralInfos.Add('Ethernet Subnet mask',(($lineUp| Select-String -Pattern 'Ethernet Subnet mask:\s+([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})').Matches.Groups[1].Value))
            $FOS_SwGeneralInfos.Add('Gateway IP Address',(($lineUp| Select-String -Pattern 'Gateway IP Address:\s+([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})').Matches.Groups[1].Value))
            $FOS_SwGeneralInfos.Add('DHCP',((($lineUp| Select-String -Pattern '^DHCP:\s(\w+)$' -AllMatches).Matches.Groups[1].Value)))
            $FOS_SwGeneralInfos.Add('Switch State',(($lineUp| Select-String -Pattern 'switchState:\s+(.*)$').Matches.Groups[1].Value))
            $FOS_SwGeneralInfos.Add('Switch Role',(($lineUp| Select-String -Pattern 'switchRole:\s+(.*)$').Matches.Groups[1].Value))
        }
        
    }
    
    end {
        <# returns the hashtable for further processing, not mandatory but the safe way #>
        Write-Debug -Message "End Func FOS_BasicSwitchInfo |$(Get-Date)`n "
        <# export y or n #>
        if($TD_Export -eq "yes"){
            <# exported to .\Host_Volume_Map_Result.csv #>
            if([string]$TD_Exportpath -ne "$PSRootPath\Export\"){
                Out-File -FilePath $TD_Exportpath\$($TD_Line_ID)_BasicSwitchInfo_Result_$(Get-Date -Format "yyyy-MM-dd").csv -InputObject $FOS_SwGeneralInfos
            }else {
                Out-File -FilePath $PSScriptRoot\Export\$($TD_Line_ID)_BasicSwitchInfo_Result_$(Get-Date -Format "yyyy-MM-dd").csv -InputObject $FOS_SwGeneralInfos
            }
            Write-Host "The Export can be found at $TD_Exportpath " -ForegroundColor Green
            #Invoke-Item "$TD_Exportpath\Host_Volume_Map_Result_$(Get-Date -Format "yyyy-MM-dd").csv"
        }else {
            <# output on the promt #>
            return $FOS_SwGeneralInfos
        }
        Write-Debug -Message "End Func GET_BasicSwitchInfos |$(Get-Date)` "
        Write-Debug -Message "return $FOS_SwGeneralInfos ` $(Get-Date)` "
        return $FOS_SwGeneralInfos
    }
}