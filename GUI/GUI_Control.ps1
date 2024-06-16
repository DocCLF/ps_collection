Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$MainxamlFile =".\MainWindow.xaml"
$inputXAML=Get-Content -Path $MainxamlFile -raw
$inputXAML=$inputXAML -replace 'mc:Ignorable="d"','' -replace "x:N","N" -replace "^<Win.*","<Window"
[xml]$MainXAML=$inputXAML
$Mainreader = New-Object System.Xml.XmlNodeReader $MainXAML
$Mainform=[Windows.Markup.XamlReader]::Load($Mainreader)
$MainXAML.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name "TD_$($_.Name)" -Value $Mainform.FindName($_.Name)}

# Get functions files
$PSRootPath = Split-Path -Path $PSScriptRoot -Parent
$Functions = @(Get-ChildItem -Path $PSRootPath\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files
foreach($import in @($Functions)) {
    try {
       . $import.fullname
        Write-Host $import.fullname
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

<# not needed yet #>
<#
$UserCxamlFile = Get-ChildItem ".GUI\UserControl*.xaml"
foreach($file in $UserCxamlFile){
    $fileName = ($file.Name).trim(".xaml")
    Set-Variable -Name "TD_$($fileName)"
    switch -wildcard ($fileName) {
        "*1" { 
            $UserC1=Get-Content -Path $file -raw
            $UserC1=$UserC1 -replace 'mc:Ignorable="d"','' -replace "x:N","N" -replace "^<Win.*","<Window"
            [xml]$UserXAML1=$UserC1
            $Userreader = New-Object System.Xml.XmlNodeReader $UserXAML1
            $TD_UserControl1=[Windows.Markup.XamlReader]::Load($Userreader)
            $UserXAML1.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name "TD_$($_.Name)" -Value $TD_UserControl1.FindName($_.Name) }
         }
        "*2" { 
            $UserC2=Get-Content -Path $file -raw
            $UserC2=$UserC2 -replace 'mc:Ignorable="d"','' -replace "x:N","N" -replace "^<Win.*","<Window"
            [xml]$UserXAML2=$UserC2
            $Userreader = New-Object System.Xml.XmlNodeReader $UserXAML2
            $TD_UserControl2=[Windows.Markup.XamlReader]::Load($Userreader)
            $UserXAML2.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name "TD_$($_.Name)" -Value $TD_UserControl2.FindName($_.Name) }
         }
        "*3" { 
            $UserC3=Get-Content -Path $file -raw
            $UserC3=$UserC3 -replace 'mc:Ignorable="d"','' -replace "x:N","N" -replace "^<Win.*","<Window"
            [xml]$UserXAML3=$UserC3
            $Userreader = New-Object System.Xml.XmlNodeReader $UserXAML3
            $TD_UserControl3=[Windows.Markup.XamlReader]::Load($Userreader)
            $UserXAML3.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name "TD_$($_.Name)" -Value $TD_UserControl3.FindName($_.Name) }
         }
        "*4" { 
            $UserC4=Get-Content -Path $file -raw
            $UserC4=$UserC4 -replace 'mc:Ignorable="d"','' -replace "x:N","N" -replace "^<Win.*","<Window"
            [xml]$UserXAML4=$UserC4
            $Userreader = New-Object System.Xml.XmlNodeReader $UserXAML4
            $TD_UserControl4=[Windows.Markup.XamlReader]::Load($Userreader)
            $UserXAML4.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name "TD_$($_.Name)" -Value $TD_UserControl4.FindName($_.Name) }
         }
        Default { Write-Host "Something did not work, start the application in debug mod and/or check the log file." -ForegroundColor Red; Start-Sleep -Seconds 5; exit }
    }
}
#>

<# Set some Vars#>
$TD_tb_Exportpath.Text = "$PSRootPath\Export\"

<# start with functions #>
function Get_CredGUIInfos {
    [CmdletBinding()]
    param(
        #[Parameter(Mandatory)]
        [Int16]$STP_ID,
        #[Parameter(Mandatory)]
        [string]$TD_ConnectionTyp,
        #[Parameter(Mandatory)]
        [string]$TD_IPAdresse,
        #[Parameter(Mandatory)]
        [string]$TD_UserName,
        #[Parameter(Mandatory)]
        $TD_Password,
        [string]$TD_Exportpath = "$PSRootPath\Export\"
    )
    #Write-Host $STP_ID $TD_ConnectionTyp $TD_IPAdresse $TD_UserName $TD_Password.Password -ForegroundColor Red
    $TD_IPPattern = '^(?:[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})$'
    $TD_IPCheck = $TD_IPAdresse -match $TD_IPPattern

    if(($TD_cb_SamePW.IsChecked)-and($TD_ConnectionTyp -eq "plink")){
        $TD_Password=$TD_tb_Password
    }elseif (($TD_ConnectionTyp -eq "ssh")) {
        $TD_Password=""
    }
    if($TD_cb_SameUserName.IsChecked){
        $TD_UserName=$TD_tb_UserName.Text
    }

    if($TD_IPCheck){
        $TD_CredCollection=[ordered]@{
            'ID'= $STP_ID;
            'ConnectionTyp'= $TD_ConnectionTyp;
            'IPAddress'= $TD_IPAdresse;
            'UserName'= $TD_UserName;
            'Password'= $TD_Password.Password
            'ExportPath'= $TD_Exportpath

        }
        $TD_CredObject=New-Object -TypeName psobject -Property $TD_CredCollection
    }else {
        <# Action when all if and elseif conditions are false #>
        Write-Host "IP is not validate or set." -ForegroundColor Red
        $TD_IPAdresse = $null
    }
    return $TD_CredObject
}

function Get-TestConnection {
    param (
        
    )
    $TD_IPTests=@()
    $TD_IPTestTemp = $TD_tb_IPAdr.Text
    $TD_IPTests+=$TD_IPTestTemp
    $TD_IPTestTemp = $TD_tb_IPAdrOne.Text
    $TD_IPTests+=$TD_IPTestTemp
    $TD_IPTestTemp = $TD_tb_IPAdrTwo.Text
    $TD_IPTests+=$TD_IPTestTemp
    $TD_IPTestTemp = $TD_tb_IPAdrThree.Text
    $TD_IPTests+=$TD_IPTestTemp
    
    foreach($TD_IPTest in $TD_IPTests){
        <# Check if ip is a ip#>
        $res = Get_CredGUIInfos -TD_IPAdresse $TD_IPTest
        <# if ip is -eq ip the test it and change color #>
        if($res.IPAddress -eq $TD_IPTest){
            $TD_IPConnectionTest=Test-Connection $TD_IPTest -Count 1
            switch ($TD_IPTest) {
                $TD_tb_IPAdr.Text { If($TD_IPConnectionTest.Status-eq "Success"){$TD_tb_IPAdr.Background = "lightgreen"}else{$TD_tb_IPAdr.Background = "red"} }
                $TD_tb_IPAdrOne.Text { If($TD_IPConnectionTest.Status-eq "Success"){$TD_tb_IPAdrOne.Background = "lightgreen"}else{$TD_tb_IPAdrOne.Background = "red"} }
                $TD_tb_IPAdrTwo.Text { If($TD_IPConnectionTest.Status-eq "Success"){$TD_tb_IPAdrTwo.Background = "lightgreen"}else{$TD_tb_IPAdrTwo.Background = "red"} }
                $TD_tb_IPAdrThree.Text { If($TD_IPConnectionTest.Status-eq "Success"){$TD_tb_IPAdrThree.Background = "lightgreen"}else{$TD_tb_IPAdrThree.Background = "red"} }
                Default {Write-Host "something went wrong" -ForegroundColor red}
            }
        }
        $TD_IPTest=""  
    }
   
    $TD_IPTests=@()
    return $TD_IPConnectionTest.Status
    
}


$TD_tbn_addrmLine.add_click({
    <#log the txtbox (optional for later use)#>
    #$TD_tb_IPAdr.IsEnabled=$false
    if($TD_tbn_addrmLine.Content -eq "ADD"){
        $TD_tbn_addrmLine.Content="REMOVE"
        $TD_stp_Panel2.Visibility="Visible"
        $TD_tbn_addrmLineOne.Content="ADD"
        $TD_tbn_addrmLineTwo.Content="ADD"
    }else {
        $TD_tbn_addrmLine.Content="ADD"
        $TD_stp_Panel2.Visibility="Collapsed"
        $TD_stp_Panel3.Visibility="Collapsed"
        $TD_stp_Panel4.Visibility="Collapsed"
    }
})
$TD_tbn_addrmLineOne.add_click({

    if($TD_tbn_addrmLineOne.Content -eq "ADD"){
        $TD_tbn_addrmLineOne.Content="REMOVE"
        $TD_stp_Panel3.Visibility="Visible"
        $TD_tbn_addrmLineTwo.Content="ADD"
    }else {
        $TD_tbn_addrmLineOne.Content="ADD"
        $TD_stp_Panel3.Visibility="Collapsed"
        $TD_stp_Panel4.Visibility="Collapsed"
    }
})
$TD_tbn_addrmLineTwo.add_click({

    if($TD_tbn_addrmLineTwo.Content -eq "ADD"){
        $TD_tbn_addrmLineTwo.Content="REMOVE"
        $TD_stp_Panel4.Visibility="Visible"
    }else {
        $TD_tbn_addrmLineTwo.Content="ADD"
        $TD_stp_Panel4.Visibility="Collapsed"
    }
})

$TD_btn_ConnectTest.add_click({
    $TD_PingTest = Get-TestConnection
    <# looking for a good color-marker, later #>
    #if($TD_PingTest -eq "Success"){
    #    $TD_btn_ConnectTest.Background = "lightgreen"
    #}else{
    #    $TD_btn_ConnectTest.Background = "red"
    #}
})

<#$TD_btn_IBM_test.add_click({
    Get_CredGUIInfos  
})
 maybe for later use as filter option
$TD_tb_UserName.Add_TextChanged({
    Get_CredGUIInfos
})
#>

$TD_btn_IBM_HostVolumeMap.add_click({
    $TD_tb_IPAdr.Background = "White"
    $TD_Credentials=@()
    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 1 -TD_ConnectionTyp $TD_cb_ConnectionTyp.Text -TD_IPAdresse $TD_tb_IPAdr.Text -TD_UserName $TD_tb_UserName.Text -TD_Password $TD_tb_Password -TD_Exportpath $TD_tb_Exportpath.Text
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 2 -TD_ConnectionTyp $TD_cb_ConnectionTypOne.Text -TD_IPAdresse $TD_tb_IPAdrOne.Text -TD_UserName $TD_tb_UserNameOne.Text -TD_Password $TD_tb_PasswordOne -TD_Exportpath $TD_tb_Exportpath.Text
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 3 -TD_ConnectionTyp $TD_cb_ConnectionTypTwo.Text -TD_IPAdresse $TD_tb_IPAdrTwo.Text -TD_UserName $TD_tb_UserNameTwo.Text -TD_Password $TD_tb_PasswordTwo -TD_Exportpath $TD_tb_Exportpath.Text
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 4 -TD_ConnectionTyp $TD_cb_ConnectionTypThree.Text -TD_IPAdresse $TD_tb_IPAdrThree.Text -TD_UserName $TD_tb_UserNameThree.Text -TD_Password $TD_tb_PasswordThree -TD_Exportpath $TD_tb_Exportpath.Text
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    #if(!($TD_UserControl1.IsLoaded)){$TD_User_Contr_Area.Children.Add($TD_UserControl1)}
    #$TD_User_Contr_Area.Children.Remove($TD_UserControl2)
    #$TD_User_Contr_Area.Children.Remove($TD_UserControl3)

    foreach($TD_Credential in $TD_Credentials){
        

        if(($TD_Credential.ConnectionTyp -eq "ssh") -or ($TD_Credential.ConnectionTyp -eq "plink")){
            Write-Host $TD_Credential.ConnectionTyp -ForegroundColor Red
            Write-Host "1" -ForegroundColor Green
            IBM_Host_Volume_Map -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.UserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.Password -TD_Exportpath $TD_Credential.ExportPath
            Start-Sleep -Seconds 1.5
        }
        #Write-Host $TD_Credential
    }
    #Write-Host $TD_Credentials[0] `n $TD_Credentials[1] `n $TD_Credentials[2] `n $TD_Credentials[3] `n
})
#IsEnabled="False"
$TD_btn_IBM_DriveInfo.add_click({
    $TD_Credentials=@()
    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 1 -TD_ConnectionTyp $TD_cb_ConnectionTyp.Text -TD_IPAdresse $TD_tb_IPAdr.Text -TD_UserName $TD_tb_UserName.Text -TD_Password $TD_tb_Password -TD_Exportpath $TD_tb_Exportpath.Text
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 2 -TD_ConnectionTyp $TD_cb_ConnectionTypOne.Text -TD_IPAdresse $TD_tb_IPAdrOne.Text -TD_UserName $TD_tb_UserNameOne.Text -TD_Password $TD_tb_PasswordOne -TD_Exportpath $TD_tb_Exportpath.Text
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 3 -TD_ConnectionTyp $TD_cb_ConnectionTypTwo.Text -TD_IPAdresse $TD_tb_IPAdrTwo.Text -TD_UserName $TD_tb_UserNameTwo.Text -TD_Password $TD_tb_PasswordTwo -TD_Exportpath $TD_tb_Exportpath.Text
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 4 -TD_ConnectionTyp $TD_cb_ConnectionTypThree.Text -TD_IPAdresse $TD_tb_IPAdrThree.Text -TD_UserName $TD_tb_UserNameThree.Text -TD_Password $TD_tb_PasswordThree -TD_Exportpath $TD_tb_Exportpath.Text
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    foreach($TD_Credential in $TD_Credentials){
        #Write-Host $TD_Credential -ForegroundColor Red
        if($TD_Credential -ne ""){
            IBM_DriveInfo -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.UserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.Password -TD_Exportpath $TD_Credential.ExportPath
            Start-Sleep -Seconds 1.5
        }
        #Write-Host $TD_Credential
    }
    #Write-Host $TD_Credentials[0] `n $TD_Credentials[1] `n $TD_Credentials[2] `n $TD_Credentials[3] `n
    #IBM_DriveInfo 
    #$TD_User_Contr_Area.Children.Add($TD_UserControl2)
    #$TD_User_Contr_Area.Children.Remove($TD_UserControl1)
    #$TD_User_Contr_Area.Children.Remove($TD_UserControl3)
    $TD_tb_Exportpath.IsEnabled=$true
})

$TD_btn_IBM_FCPortStats.add_click({
    $TD_tb_Exportpath.IsEnabled=$false
    $TD_Credentials=@()
    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 1 -TD_ConnectionTyp $TD_cb_ConnectionTyp.Text -TD_IPAdresse $TD_tb_IPAdr.Text -TD_UserName $TD_tb_UserName.Text -TD_Password $TD_tb_Password -TD_Exportpath $TD_tb_Exportpath.Text
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 2 -TD_ConnectionTyp $TD_cb_ConnectionTypOne.Text -TD_IPAdresse $TD_tb_IPAdrOne.Text -TD_UserName $TD_tb_UserNameOne.Text -TD_Password $TD_tb_PasswordOne -TD_Exportpath $TD_tb_Exportpath.Text
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 3 -TD_ConnectionTyp $TD_cb_ConnectionTypTwo.Text -TD_IPAdresse $TD_tb_IPAdrTwo.Text -TD_UserName $TD_tb_UserNameTwo.Text -TD_Password $TD_tb_PasswordTwo -TD_Exportpath $TD_tb_Exportpath.Text
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 4 -TD_ConnectionTyp $TD_cb_ConnectionTypThree.Text -TD_IPAdresse $TD_tb_IPAdrThree.Text -TD_UserName $TD_tb_UserNameThree.Text -TD_Password $TD_tb_PasswordThree -TD_Exportpath $TD_tb_Exportpath.Text
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    foreach($TD_Credential in $TD_Credentials){
        #Write-Host $TD_Credential -ForegroundColor Red
        if($TD_Credential -ne ""){
            IBM_FCPortStats -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.UserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.Password -TD_Exportpath $TD_Credential.ExportPath
            Start-Sleep -Seconds 1.5
        }
        #Write-Host $TD_Credential
    }
    #IBM_FCPortStats
    #$TD_User_Contr_Area.Children.Remove($TD_UserControl1)
    #$TD_User_Contr_Area.Children.Remove($TD_UserControl2)
    #$TD_User_Contr_Area.Children.Add($TD_UserControl3)
    $TD_tb_Exportpath.IsEnabled=$true
})
 
$TD_btn_CloseAll.add_click({
    $Mainform.Close()
})


Get-Variable TD_*


$Mainform.showDialog()
$Mainform.activate()