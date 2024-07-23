Add-Type -AssemblyName PresentationCore,PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

<# Create the xaml Files / Base of GUI Mainwindow #>
$MainxamlFile =".\MainWindow.xaml"
$inputXAML=Get-Content -Path $MainxamlFile -raw
$inputXAML=$inputXAML -replace 'mc:Ignorable="d"','' -replace "x:N","N" -replace "^<Win.*","<Window"
[xml]$MainXAML=$inputXAML
$Mainreader = New-Object System.Xml.XmlNodeReader $MainXAML
$Mainform=[Windows.Markup.XamlReader]::Load($Mainreader)
$MainXAML.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name "TD_$($_.Name)" -Value $Mainform.FindName($_.Name)}

# Get functions files
$PSRootPath = Split-Path -Path $PSScriptRoot -Parent
Unblock-File -Path $PSRootPath\*.ps1
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

<# Create UserControls as basis of Content for MainWindow #>
$UserCxamlFile = Get-ChildItem ".\UserControl*.xaml"
foreach($file in $UserCxamlFile){
    $fileName = ($file.Name).trim(".xaml")
    Set-Variable -Name "TD_$($fileName)"
    <# if you want more UserControls then add them here #>
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


<# Set some Vars #>
$TD_tb_Exportpath.Text = "$PSRootPath\Export\"

#$TD_tb_sanIPAdr             
#$TD_tb_sanIPAdrOne          
#$TD_tb_sanIPAdrThree        
#$TD_tb_sanIPAdrTwo          
#$TD_tb_sanPassword          
#$TD_tb_sanPasswordOne       
#$TD_tb_sanPasswordThree     
#$TD_tb_sanPasswordTwo       
#$TD_tb_sanUserName          
#$TD_tb_sanUserNameOne       
#$TD_tb_sanUserNameThree     
#$TD_tb_sanUserNameTwo       

<# start with functions #>
function Get_CredGUIInfos {
    [CmdletBinding()]
    param(
        #[Parameter(Mandatory)]
        [Int16]$STP_ID = 0,
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
    if($TD_IPAdresse -ne ""){
        $TD_IPCheck = $TD_IPAdresse -match $TD_IPPattern
        #$TD_IPConnectionTest=Test-Connection $TD_IPAdresse -Count 1
    }
    #Write-Host $TD_IPConnectionTest.Status -ForegroundColor Yellow
    #if(($TD_IPCheck)-and($TD_IPConnectionTest.Status-eq "Success")){
    if(($TD_IPCheck)){    
        if((($TD_cb_storageSamePW.IsChecked)-or($TD_ConnectionTyp -eq "plink"))-and($TD_ConnectionTyp -ne "ssh")){
                $TD_StoragePassword=$TD_tb_storagePassword
        }elseif (($TD_ConnectionTyp -eq "ssh")) {
            $TD_StoragePassword=""
        }
        if((($TD_cb_sanSamePW.IsChecked)-or($TD_ConnectionTyp -eq "plink"))-and($TD_ConnectionTyp -ne "ssh")){
            $TD_SANPassword=$TD_tb_sanPassword
        }elseif (($TD_ConnectionTyp -eq "ssh")) {
            $TD_SANPassword=""
        }
        if($TD_cb_storageSameUserName.IsChecked){
            $TD_StorageUserName=$TD_tb_storageUserName.Text
        }else{
            $TD_StorageUserName =$TD_UserName
        }
        if($TD_cb_sanSameUserName.IsChecked){
            $TD_SANUserName=$TD_tb_sanUserName.Text
        }else{
            $TD_SANUserName =$TD_UserName
        }
        $TD_CredCollection=[ordered]@{
            'ID'= $STP_ID;
            'ConnectionTyp'= $TD_ConnectionTyp;
            'IPAddress'= $TD_IPAdresse;
            'StorageUserName'= $TD_StorageUserName;
            'SANUserName'= $TD_SANUserName;
            'StoragePassword'= $TD_StoragePassword.Password;
            'SANPassword'= $TD_SANPassword.Password;
            'ExportPath'= $TD_Exportpath;
        }
        $TD_CredObject=New-Object -TypeName psobject -Property $TD_CredCollection
    }else {
        <# Action when all if and elseif conditions are false #>
        Write-Host "IP is not validate or set." -ForegroundColor Red
        $TD_IPAdresse = $null
    }
    return $TD_CredObject
}

<# Test connection need a rework and a better option for 5.1#>
function Get-TestConnection {
    param (
        [string]$TD_StorageIPAdresse,
        [string]$TD_StorageIPAdresseOne,
        [string]$TD_StorageIPAdresseTwo,
        [string]$TD_StorageIPAdresseThree
    )
    $TD_IPTests=@()
    $TD_IPTestTemp = $TD_StorageIPAdresse
    $TD_IPTests+=$TD_IPTestTemp
    $TD_IPTestTemp = $TD_StorageIPAdresseOne
    $TD_IPTests+=$TD_IPTestTemp
    $TD_IPTestTemp = $TD_StorageIPAdresseTwo
    $TD_IPTests+=$TD_IPTestTemp
    $TD_IPTestTemp = $TD_StorageIPAdresseThree
    $TD_IPTests+=$TD_IPTestTemp
    
    foreach($TD_IPTest in $TD_IPTests){
        <# Check if ip is a ip#>
        $res = Get_CredGUIInfos -TD_IPAdresse $TD_IPTest
        <# if ip is -eq ip the test it and change color #>
        if($res.IPAddress -eq $TD_IPTest){
            $TD_IPConnectionTest=Test-Connection $TD_IPTest -Count 1
        }else {
            <# Action when all if and elseif conditions are false #>
            $TD_IPConnectionTest = "Fail"
        }
        <# change the color of TBs #>
        switch ($TD_IPTest) {
            $TD_StorageIPAdresse { If($TD_IPConnectionTest.Status-eq "Success"){$TD_tb_storageIPAdr.Background = "lightgreen"}else{$TD_tb_storageIPAdr.Background = "red"} }
            $TD_StorageIPAdresseOne { If($TD_IPConnectionTest.Status-eq "Success"){$TD_tb_storageIPAdrOne.Background = "lightgreen"}else{$TD_tb_storageIPAdrOne.Background = "red"} }
            $TD_StorageIPAdresseTwo { If($TD_IPConnectionTest.Status-eq "Success"){$TD_tb_storageIPAdrTwo.Background = "lightgreen"}else{$TD_tb_storageIPAdrTwo.Background = "red"} }
            $TD_StorageIPAdresseThree { If($TD_IPConnectionTest.Status-eq "Success"){$TD_tb_storageIPAdrThree.Background = "lightgreen"}else{$TD_tb_storageIPAdrThree.Background = "red"} }
            Default {Write-Host "something went wrong" -ForegroundColor red}
        }
        $TD_IPTest=""  
    }
   
    $TD_IPTests=@()   
}

function ExportCred {
    param (
        [Parameter(Mandatory)]
        [string]$TD_DeviceType,
        [Parameter(Mandatory)]
        [Int16]$STP_ID,
        [Parameter(Mandatory)]
        [string]$TD_ConnectionTyp,
        [Parameter(Mandatory)]
        [string]$TD_IPAdresse,
        [Parameter(Mandatory)]
        [string]$TD_UserName
    )
    <# collect the access data for subsequent processing #>
    $TD_CredCollection=[ordered]@{
        'DeviceType' = $TD_DeviceType;
        'ID'= $STP_ID;
        'ConnectionTyp'= $TD_ConnectionTyp;
        'IPAddress'= $TD_IPAdresse;
        'UserName'= $TD_UserName;
    }
    $TD_CredObject=New-Object -TypeName psobject -Property $TD_CredCollection
 
    return $TD_CredObject
}

Function SaveFile_to_Directory {
    param(
        $TD_UserDataObject
    )
    $saveFileDialog = [System.Windows.Forms.SaveFileDialog]@{
        CheckPathExists  = $true
        OverwritePrompt  = $true
        InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
        Title            = 'Choose directory to save the output file'
        Filter           = "CSV documents (.csv)|*.csv"
    }
    # Show save file dialog box
    if($saveFileDialog.ShowDialog() -eq 'Ok') {
        $TD_UserDataObject | Export-Csv -Path $saveFileDialog.FileName -Delimiter ';' -NoTypeInformation
    }
    $TD_lb_CerdExportPath.Content = "$($saveFileDialog.FileName)"
    return $saveFileDialog
}

function ImportCred {
    param (
        
    )
    $TD_ImportCredentialObjs = OpenFile_from_Directory
    #$test = Get-Content -Path C:\Users\r.glanz\Documents\testexp.csv
    if($TD_ImportCredentialObjs.FileName -ne ""){
    $TD_ImportedCredentials = Import-Csv -Path $TD_ImportCredentialObjs.FileName -Delimiter ';'
    }
    #Write-Host $TD_ImportedCredentials -ForegroundColor Blue
    return $TD_ImportedCredentials
}

function OpenFile_from_Directory {
    # Show an Open File Dialog and return the file selected by the user.
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Title = "Select File"
    $openFileDialog.InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
    $openFileDialog.Filter = "All files (*.csv)|*.*"
    $openFileDialog.MultiSelect = $false 
    $openFileDialog.ShowHelp = $true    # Without this line the ShowDialog() function may hang depending on system configuration and running from console vs. ISE.
    $openFileDialog.ShowDialog() > $null

    #Write-Host $openFileDialog.InitialDirectory
    return $openFileDialog
}

<# Button Area Menu #>
$TD_btn_IBM_SV.add_click({
    $TD_label_ExpPath.Content ="Export Path: $($TD_tb_ExportPath.Text)"
    if(!($TD_UserControl1.IsLoaded)){$TD_UserContrArea.Children.Add($TD_UserControl1)}
    $TD_UserContrArea.Children.Remove($TD_UserControl2)
    $TD_UserContrArea.Children.Remove($TD_UserControl3)
    $TD_UserContrArea.Children.Remove($TD_UserControl4)
    
})
$TD_btn_Broc_SAN.add_click({
    $TD_label_ExpPath.Content ="Export Path: $($TD_tb_ExportPath.Text)"
    if(!($TD_UserControl2.IsLoaded)){$TD_UserContrArea.Children.Add($TD_UserControl2)}
    $TD_UserContrArea.Children.Remove($TD_UserControl1)
    $TD_UserContrArea.Children.Remove($TD_UserControl3)
    $TD_UserContrArea.Children.Remove($TD_UserControl4)
})
$TD_btn_Stor_San.add_click({
    $TD_label_ExpPath.Content ="Export Path: $($TD_tb_ExportPath.Text)"
    if(!($TD_UserControl3.IsLoaded)){$TD_UserContrArea.Children.Add($TD_UserControl3)}
    $TD_UserContrArea.Children.Remove($TD_UserControl1)
    $TD_UserContrArea.Children.Remove($TD_UserControl2)
    $TD_UserContrArea.Children.Remove($TD_UserControl4)
})
$TD_btn_Settings.add_click({
    if(!($TD_UserControl4.IsLoaded)){$TD_UserContrArea.Children.Add($TD_UserControl4)}
    $TD_UserContrArea.Children.Remove($TD_UserControl1)
    $TD_UserContrArea.Children.Remove($TD_UserControl2)
    $TD_UserContrArea.Children.Remove($TD_UserControl3)
})
<# Button SettingsArea Storage #>
$TD_tbn_storageaddrmLine.add_click({
    <#log the txtbox (optional for later use)#>
    #$TD_tb_IPAdr.IsEnabled=$false
    if($TD_tbn_storageaddrmLine.Content -eq "ADD"){
        $TD_tbn_storageaddrmLine.Content="REMOVE"
        $TD_stp_storagePanel2.Visibility="Visible"
        $TD_tbn_storageaddrmLineOne.Content="ADD"
        $TD_tbn_storageaddrmLineTwo.Content="ADD"
    }else {
        $TD_tbn_storageaddrmLine.Content="ADD"
        $TD_stp_storagePanel2.Visibility="Collapsed"
        $TD_stp_storagePanel3.Visibility="Collapsed"
        $TD_stp_storagePanel4.Visibility="Collapsed"
    }
})
$TD_tbn_storageaddrmLineOne.add_click({

    if($TD_tbn_storageaddrmLineOne.Content -eq "ADD"){
        $TD_tbn_storageaddrmLineOne.Content="REMOVE"
        $TD_stp_storagePanel3.Visibility="Visible"
        $TD_tbn_storageaddrmLineTwo.Content="ADD"
    }else {
        $TD_tbn_storageaddrmLineOne.Content="ADD"
        $TD_stp_storagePanel3.Visibility="Collapsed"
        $TD_stp_storagePanel4.Visibility="Collapsed"
    }
})
$TD_tbn_storageaddrmLineTwo.add_click({

    if($TD_tbn_storageaddrmLineTwo.Content -eq "ADD"){
        $TD_tbn_storageaddrmLineTwo.Content="REMOVE"
        $TD_stp_storagePanel4.Visibility="Visible"
    }else {
        $TD_tbn_storageaddrmLineTwo.Content="ADD"
        $TD_stp_storagePanel4.Visibility="Collapsed"
    }
})
<# Button SettingsArea SAN #>
$TD_tbn_sanaddrmLine.add_click({
    <#log the txtbox (optional for later use)#>
    #$TD_tb_IPAdr.IsEnabled=$false
    if($TD_tbn_sanaddrmLine.Content -eq "ADD"){
        $TD_tbn_sanaddrmLine.Content="REMOVE"
        $TD_stp_sanPanel2.Visibility="Visible"
        $TD_tbn_sanaddrmLineOne.Content="ADD"
        $TD_tbn_sanaddrmLineTwo.Content="ADD"
    }else {
        $TD_tbn_sanaddrmLine.Content="ADD"
        $TD_stp_sanPanel2.Visibility="Collapsed"
        $TD_stp_sanPanel3.Visibility="Collapsed"
        $TD_stp_sanPanel4.Visibility="Collapsed"
    }
})
$TD_tbn_sanaddrmLineOne.add_click({

    if($TD_tbn_sanaddrmLineOne.Content -eq "ADD"){
        $TD_tbn_sanaddrmLineOne.Content="REMOVE"
        $TD_stp_sanPanel3.Visibility="Visible"
        $TD_tbn_sanaddrmLineTwo.Content="ADD"
    }else {
        $TD_tbn_sanaddrmLineOne.Content="ADD"
        $TD_stp_sanPanel3.Visibility="Collapsed"
        $TD_stp_sanPanel4.Visibility="Collapsed"
    }
})
$TD_tbn_sanaddrmLineTwo.add_click({

    if($TD_tbn_sanaddrmLineTwo.Content -eq "ADD"){
        $TD_tbn_sanaddrmLineTwo.Content="REMOVE"
        $TD_stp_sanPanel4.Visibility="Visible"
    }else {
        $TD_tbn_sanaddrmLineTwo.Content="ADD"
        $TD_stp_sanPanel4.Visibility="Collapsed"
    }
})
<# Button Export Settings #>
$TD_btn_ChangeExportPath.add_click({
    $TD_ChPathdialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($TD_ChPathdialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $TD_DirectoryName = $TD_ChPathdialog.SelectedPath
        Write-Host "Directory selected is $TD_DirectoryName"
        $TD_tb_ExportPath.Text = $TD_DirectoryName
    }
    $TD_label_ExpPath.Content ="Export Path: $($TD_tb_ExportPath.Text)"
})
<# Button Credentials In-/ Export #>
$TD_btn_ExportCred.add_click({
    $TD_ExportCred = @()
    <#Storage#>
    if($TD_tb_storageIPAdr.Text -ne ""){
        $TD_ExportCred += ExportCred -TD_DeviceType "Storage" -STP_ID 1 -TD_ConnectionTyp $TD_cb_storageConnectionTyp.Text -TD_IPAdresse $TD_tb_storageIPAdr.Text -TD_UserName $TD_tb_storageUserName.Text
    }
    if ($TD_tb_storageIPAdrOne.Text -ne "") {
        $TD_ExportCred += ExportCred -TD_DeviceType "Storage" -STP_ID 2 -TD_ConnectionTyp $TD_cb_storageConnectionTypOne.Text -TD_IPAdresse $TD_tb_storageIPAdrOne.Text -TD_UserName $TD_tb_storageUserNameOne.Text
    }
    if ($TD_tb_storageIPAdrTwo.Text -ne "") {
        $TD_ExportCred += ExportCred -TD_DeviceType "Storage" -STP_ID 3 -TD_ConnectionTyp $TD_cb_storageConnectionTypTwo.Text -TD_IPAdresse $TD_tb_storageIPAdrTwo.Text -TD_UserName $TD_tb_storageUserNameTwo.Text
    }
    if ($TD_tb_storageIPAdrThree.Text -ne "") {
        $TD_ExportCred += ExportCred -TD_DeviceType "Storage" -STP_ID 4 -TD_ConnectionTyp $TD_cb_storageConnectionTypThree.Text -TD_IPAdresse $TD_tb_storageIPAdrThree.Text -TD_UserName $TD_tb_storageUserNameThree.Text
    }
    Write-Host $TD_ExportCred -ForegroundColor Yellow
    <#SAN#>
    if($TD_tb_sanIPAdr.Text -ne ""){
        $TD_ExportCred += ExportCred -TD_DeviceType "SAN" -STP_ID 1 -TD_ConnectionTyp $TD_cb_sanConnectionTyp.Text -TD_IPAdresse $TD_tb_sanIPAdr.Text -TD_UserName $TD_tb_sanUserName.Text
    }
    if ($TD_tb_sanIPAdrOne.Text -ne "") {
        $TD_ExportCred += ExportCred -TD_DeviceType "SAN" -STP_ID 2 -TD_ConnectionTyp $TD_cb_sanConnectionTypOne.Text -TD_IPAdresse $TD_tb_sanIPAdrOne.Text -TD_UserName $TD_tb_sanUserNameOne.Text
    }
    if ($TD_tb_sanIPAdrTwo.Text -ne "") {
        $TD_ExportCred += ExportCred -TD_DeviceType "SAN" -STP_ID 3 -TD_ConnectionTyp $TD_cb_sanConnectionTypTwo.Text -TD_IPAdresse $TD_tb_sanIPAdrTwo.Text -TD_UserName $TD_tb_sanUserNameTwo.Text
    }
    if ($TD_tb_sanIPAdrThree.Text -ne "") {
        $TD_ExportCred += ExportCred -TD_DeviceType "SAN" -STP_ID 4 -TD_ConnectionTyp $TD_cb_sanConnectionTypThree.Text -TD_IPAdresse $TD_tb_sanIPAdrThree.Text -TD_UserName $TD_tb_sanUserNameThree.Text
    }
    Write-Host $TD_ExportCred -ForegroundColor Red
    $TD_SaveCred = SaveFile_to_Directory -TD_UserDataObject $TD_ExportCred
    Write-Host $TD_SaveCred.FileName -ForegroundColor Green
})
$TD_btn_ImportCred.add_click({

    <#there must be a better option for this line#>
    $TD_tb_storageIPAdr.CLear(); $TD_tb_storageIPAdrOne.CLear(); $TD_tb_storageIPAdrThree.CLear(); $TD_tb_storageIPAdrTwo.CLear();$TD_tb_storagePassword.CLear(); $TD_tb_storagePasswordOne.CLear(); $TD_tb_storagePasswordThree.CLear(); $TD_tb_storagePasswordTwo.CLear(); $TD_tb_storageUserName.CLear(); $TD_tb_storageUserNameOne.CLear(); $TD_tb_storageUserNameThree.CLear(); $TD_tb_storageUserNameTwo.CLear();
    $TD_tb_sanIPAdr.CLear(); $TD_tb_sanIPAdrOne.CLear(); $TD_tb_sanIPAdrTwo.CLear(); $TD_tb_sanIPAdrThree.CLear();$TD_tb_sanPassword.CLear(); $TD_tb_sanPasswordOne.CLear(); $TD_tb_sanPasswordTwo.CLear(); $TD_tb_sanPasswordThree.CLear(); $TD_tb_sanUserName.CLear(); $TD_tb_sanUserNameOne.CLear(); $TD_tb_sanUserNameTwo.CLear(); $TD_tb_sanUserNameThree.CLear();    
    $TD_ImportedCredentials = ImportCred
    $TD_ImportedCredentials | Format-Table
    Write-Host $TD_ImportedCredentials -ForegroundColor Yellow
    foreach($TD_Cred in $TD_ImportedCredentials){
        if($TD_Cred.DeviceType -eq "Storage"){
            switch ($TD_Cred.ID) {
                {($_ -eq 1)} { 
                    $TD_cb_storageConnectionTyp.Text = $TD_Cred.ConnectionTyp;  $TD_tb_storageIPAdr.Text = $TD_Cred.IPAddress;  $TD_tb_storageUserName.Text= $TD_Cred.UserName; 
                }
                {($_ -eq 2)} { 
                    $TD_tbn_storageaddrmLine.Content="REMOVE"
                    $TD_stp_storagePanel2.Visibility="Visible"
                    $TD_cb_storageConnectionTypOne.Text = $TD_Cred.ConnectionTyp;  $TD_tb_storageIPAdrOne.Text = $TD_Cred.IPAddress;  $TD_tb_storageUserNameOne.Text= $TD_Cred.UserName; 
                }
                {($_ -eq 3)} { 
                    $TD_tbn_storageaddrmLineOne.Content="REMOVE"
                    $TD_stp_storagePanel3.Visibility="Visible"
                    $TD_cb_storageConnectionTypTwo.Text = $TD_Cred.ConnectionTyp;  $TD_tb_storageIPAdrTwo.Text = $TD_Cred.IPAddress;  $TD_tb_storageUserNameTwo.Text= $TD_Cred.UserName; 
                }
                {($_ -eq 4)} { 
                    $TD_tbn_storageaddrmLineTwo.Content="REMOVE"
                    $TD_stp_storagePanel4.Visibility="Visible"
                    $TD_cb_storageConnectionTypThree.Text = $TD_Cred.ConnectionTyp;  $TD_tb_storageIPAdrThree.Text = $TD_Cred.IPAddress;  $TD_tb_storageUserNameThree.Text= $TD_Cred.UserName; 
                }
                Default {Write-Host "What"}
            }
        }else {
            switch ($TD_Cred.ID) {
                {($_ -eq 1)} { 
                    $TD_cb_sanConnectionTyp.Text = $TD_Cred.ConnectionTyp;  $TD_tb_sanIPAdr.Text = $TD_Cred.IPAddress;  $TD_tb_sanUserName.Text= $TD_Cred.UserName; 
                }
                {($_ -eq 2)} { 
                    $TD_tbn_sanaddrmLine.Content="REMOVE"
                    $TD_stp_sanPanel2.Visibility="Visible"
                    $TD_cb_sanConnectionTypOne.Text = $TD_Cred.ConnectionTyp;  $TD_tb_sanIPAdrOne.Text = $TD_Cred.IPAddress;  $TD_tb_sanUserNameOne.Text= $TD_Cred.UserName; 
                }
                {($_ -eq 3)} { 
                    $TD_tbn_sanaddrmLineOne.Content="REMOVE"
                    $TD_stp_sanPanel3.Visibility="Visible"
                    $TD_cb_sanConnectionTypTwo.Text = $TD_Cred.ConnectionTyp;  $TD_tb_sanIPAdrTwo.Text = $TD_Cred.IPAddress;  $TD_tb_sanUserNameTwo.Text= $TD_Cred.UserName; 
                }
                {($_ -eq 4)} { 
                    $TD_tbn_sanaddrmLineTwo.Content="REMOVE"
                    $TD_stp_sanPanel4.Visibility="Visible"
                    $TD_cb_sanConnectionTypThree.Text = $TD_Cred.ConnectionTyp;  $TD_tb_sanIPAdrThree.Text = $TD_Cred.IPAddress;  $TD_tb_sanUserNameThree.Text= $TD_Cred.UserName; 
                }
                Default {Write-Host "What"}
            }
        }
    }
    #Write-Host $TD_GetSavedCred.FileName -ForegroundColor Green
})
<# Button Connect Test #>
#$TD_btn_ConnectTest.add_click({
    <#looking for a better way, to support pws 5.1#>
    #Get-TestConnection -TD_StorageIPAdresse $TD_tb_storageIPAdr.Text -TD_StorageIPAdresseOne $TD_tb_storageIPAdrOne.Text -TD_StorageIPAdresseTwo $TD_tb_storageIPAdrTwo.Text -TD_StorageIPAdresseThree $TD_tb_storageIPAdrThree.Text
    <# looking for a good color-marker, later #>
    #if($TD_PingTest -eq "Success"){
    #    $TD_btn_ConnectTest.Background = "lightgreen"
    #}else{
    #    $TD_btn_ConnectTest.Background = "red"
    #}
#})

<#$TD_btn_IBM_test.add_click({
    Get_CredGUIInfos  
})
 maybe for later use as filter option
$TD_tb_UserName.Add_TextChanged({
    Get_CredGUIInfos
})
#>

<# Update View for Host Volume Map #>
$TD_btn_UpFilHVM.add_click({
    $TD_Host_Volume_Map = IBM_Host_Volume_Map -TD_Line_ID $TD_cb_ListFilterStorageHVM.Text -FilterType $TD_cb_StorageHVM.Text -TD_RefreshView "Update"
    Start-Sleep -Seconds 0.5
    $TD_stp_DriveInfo.Visibility="Collapsed"
    $TD_stp_FCPortStats.Visibility="Collapsed"
    $TD_stp_HostVolInfo.Visibility="Visible"
    $TD_lb_HostVolInfo.ItemsSource = $TD_Host_Volume_Map
})
#$TD_btn_UpFilFCPS.add_click({
    <# need a implem. for more as one Storage #>
    #$TD_FCPortStats = IBM_FCPortStats -FilterType $TD_FCPortStats.Text -TD_RefreshView "Update"
    #Start-Sleep -Seconds 0.5
    #$TD_label_ExpPFCPS.Content ="Export Path: $($TD_tb_ExportPath.Text)"
    #$TD_stp_DriveInfo.Visibility="Collapsed"
    #$TD_stp_HostVolInfo.Visibility="Collapsed"
    #$TD_stp_FCPortStats.Visibility="Visible"
    #$TD_lb_HostVolInfo.ItemsSource = $TD_FCPortStats
#})

<# Storage Button #>
$TD_btn_IBM_Eventlog.add_click({

    $TD_Credentials=@()
    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 1 -TD_ConnectionTyp $TD_cb_storageConnectionTyp.Text -TD_IPAdresse $TD_tb_storageIPAdr.Text -TD_UserName $TD_tb_storageUserName.Text -TD_Password $TD_tb_storagePassword
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 2 -TD_ConnectionTyp $TD_cb_storageConnectionTypOne.Text -TD_IPAdresse $TD_tb_storageIPAdrOne.Text -TD_UserName $TD_tb_storageUserNameOne.Text -TD_Password $TD_tb_storagePasswordOne
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 3 -TD_ConnectionTyp $TD_cb_storageConnectionTypTwo.Text -TD_IPAdresse $TD_tb_storageIPAdrTwo.Text -TD_UserName $TD_tb_storageUserNameTwo.Text -TD_Password $TD_tb_storagePasswordTwo
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 4 -TD_ConnectionTyp $TD_cb_storageConnectionTypThree.Text -TD_IPAdresse $TD_tb_storageIPAdrThree.Text -TD_UserName $TD_tb_storageUserNameThree.Text -TD_Password $TD_tb_storagePasswordThree
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    foreach($TD_Credential in $TD_Credentials){
        <# QaD needs a Codeupdate #>
        #$TD_IBM_EventLogShow =@()
        #Write-Debug -Message $TD_Credential
        switch ($TD_Credential.ID) {
            {($_ -eq 1)} 
            {   Write-Host $TD_Credential.ID -ForegroundColor Green
                $TD_IBM_EventLogShow += IBM_EventLog -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.StorageUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.StoragePassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 1
                $TD_lb_StorageEventLogOne.ItemsSource = $TD_IBM_EventLogShow
            }
            {($_ -eq 2) } <# -or ($_ -eq 3) -or ($_ -eq 4)}  for later use maybe #>
            {            
                $TD_IBM_EventLogShow += IBM_EventLog -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.StorageUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.StoragePassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 1
                $TD_lb_StorageEventLogTwo.ItemsSource = $TD_IBM_EventLogShow
            }
            {($_ -eq 3) } <# -or ($_ -eq 3) -or ($_ -eq 4)}  for later use maybe #>
            {            
                $TD_IBM_EventLogShow += IBM_EventLog -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.StorageUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.StoragePassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 1
                $TD_lb_StorageEventLogThree.ItemsSource = $TD_IBM_EventLogShow
            }
            {($_ -eq 4) }
            {            
                $TD_IBM_EventLogShow += IBM_EventLog -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.StorageUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.StoragePassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 1
                $TD_lb_StorageEventLogFour.ItemsSource = $TD_IBM_EventLogShow
            }
            Default {Write-Debug "Nothing" }
        }
    }
    $TD_stp_DriveInfo.Visibility="Collapsed"
    $TD_stp_FCPortStats.Visibility="Collapsed"
    $TD_stp_HostVolInfo.Visibility="Collapsed"
    $TD_stp_StorageEventLog.Visibility="Visible"
})

$TD_btn_IBM_HostVolumeMap.add_click({
    $TD_Credentials=@()
    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 1 -TD_ConnectionTyp $TD_cb_storageConnectionTyp.Text -TD_IPAdresse $TD_tb_storageIPAdr.Text -TD_UserName $TD_tb_storageUserName.Text -TD_Password $TD_tb_storagePassword
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 2 -TD_ConnectionTyp $TD_cb_storageConnectionTypOne.Text -TD_IPAdresse $TD_tb_storageIPAdrOne.Text -TD_UserName $TD_tb_storageUserNameOne.Text -TD_Password $TD_tb_storagePasswordOne
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 3 -TD_ConnectionTyp $TD_cb_storageConnectionTypTwo.Text -TD_IPAdresse $TD_tb_storageIPAdrTwo.Text -TD_UserName $TD_tb_storageUserNameTwo.Text -TD_Password $TD_tb_storagePasswordTwo
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 4 -TD_ConnectionTyp $TD_cb_storageConnectionTypThree.Text -TD_IPAdresse $TD_tb_storageIPAdrThree.Text -TD_UserName $TD_tb_storageUserNameThree.Text -TD_Password $TD_tb_storagePasswordThree
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    foreach($TD_Credential in $TD_Credentials){
        <# QaD needs a Codeupdate #>
        $TD_Host_Volume_Map =@()
        #Write-Debug -Message $TD_Credential
        switch ($TD_Credential.ID) {
            {($_ -eq 1)} 
            {   Write-Host $TD_Credential.StoragePassword -ForegroundColor Green
                $TD_Host_Volume_Map += IBM_Host_Volume_Map -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.StorageUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.StoragePassword -FilterType $TD_cb_StorageHVM.Text -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_HostVolInfo.ItemsSource =$TD_Host_Volume_Map
            }
            {($_ -eq 2) } <# -or ($_ -eq 3) -or ($_ -eq 4)}  for later use maybe #>
            {            
                $TD_Host_Volume_Map += IBM_Host_Volume_Map -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.StorageUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.StoragePassword -FilterType $TD_cb_StorageHVM.Text -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_HostVolInfoTwo.ItemsSource =$TD_Host_Volume_Map
            }
            Default {Write-Debug "Nothing" }
        }
        #Write-Host $TD_Host_Volume_Map
    }
    #$TD_label_ExpPath.Content ="Export Path: $($TD_tb_ExportPath.Text)"
    $TD_stp_DriveInfo.Visibility="Collapsed"
    $TD_stp_FCPortStats.Visibility="Collapsed"
    $TD_stp_StorageEventLog.Visibility="Collapsed"
    $TD_stp_HostVolInfo.Visibility="Visible"
})

$TD_btn_IBM_DriveInfo.add_click({
    $TD_Credentials=@()
    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 1 -TD_ConnectionTyp $TD_cb_storageConnectionTyp.Text -TD_IPAdresse $TD_tb_storageIPAdr.Text -TD_UserName $TD_tb_storageUserName.Text -TD_Password $TD_tb_storagePassword
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 2 -TD_ConnectionTyp $TD_cb_storageConnectionTypOne.Text -TD_IPAdresse $TD_tb_storageIPAdrOne.Text -TD_UserName $TD_tb_storageUserNameOne.Text -TD_Password $TD_tb_storagePasswordOne
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 3 -TD_ConnectionTyp $TD_cb_storageConnectionTypTwo.Text -TD_IPAdresse $TD_tb_storageIPAdrTwo.Text -TD_UserName $TD_tb_storageUserNameTwo.Text -TD_Password $TD_tb_storagePasswordTwo 
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 4 -TD_ConnectionTyp $TD_cb_storageConnectionTypThree.Text -TD_IPAdresse $TD_tb_storageIPAdrThree.Text -TD_UserName $TD_tb_storageUserNameThree.Text -TD_Password $TD_tb_storagePasswordThree
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    foreach($TD_Credential in $TD_Credentials){
        <# QaD needs a Codeupdate #>
        $TD_DriveInfo =@()
        Write-Host  $TD_Credential.ID -ForegroundColor Green
        switch ($TD_Credential.ID) {
            {($_ -eq 1)} 
            {            
                $TD_DriveInfo = IBM_DriveInfo -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.StorageUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.StoragePassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_DriveInfo.ItemsSource = $TD_DriveInfo
            }
            {($_ -eq 2)} 
            {            
                $TD_DriveInfo = IBM_DriveInfo -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.StorageUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.StoragePassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_DriveInfoTwo.ItemsSource = $TD_DriveInfo
            }
            {($_ -eq 3)} 
            {            
                $TD_DriveInfo = IBM_DriveInfo -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.StorageUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.StoragePassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_DriveInfoThree.ItemsSource = $TD_DriveInfo
            }
            {($_ -eq 4)} 
            {            
                $TD_DriveInfo = IBM_DriveInfo -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.StorageUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.StoragePassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_DriveInfoFour.ItemsSource = $TD_DriveInfo
            }
        Default {Write-Debug "Nothing" }
    }
    #Write-Host $TD_Host_Volume_Map
}
    #$TD_label_ExpPath.Content ="Export Path: $($TD_tb_ExportPath.Text)"
    $TD_stp_HostVolInfo.Visibility="Collapsed"
    $TD_stp_FCPortStats.Visibility="Collapsed"
    $TD_stp_StorageEventLog.Visibility="Collapsed"
    $TD_stp_DriveInfo.Visibility="Visible"
    #Write-Host $TD_Credentials[0] `n $TD_Credentials[1] `n $TD_Credentials[2] `n $TD_Credentials[3] `n
})

$TD_btn_IBM_FCPortStats.add_click({
    $TD_Credentials=@()
    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 1 -TD_ConnectionTyp $TD_cb_storageConnectionTyp.Text -TD_IPAdresse $TD_tb_storageIPAdr.Text -TD_UserName $TD_tb_storageUserName.Text -TD_Password $TD_tb_storagePassword
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 2 -TD_ConnectionTyp $TD_cb_storageConnectionTypOne.Text -TD_IPAdresse $TD_tb_storageIPAdrOne.Text -TD_UserName $TD_tb_storageUserNameOne.Text -TD_Password $TD_tb_storagePasswordOne
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 3 -TD_ConnectionTyp $TD_cb_storageConnectionTypTwo.Text -TD_IPAdresse $TD_tb_storageIPAdrTwo.Text -TD_UserName $TD_tb_storageUserNameTwo.Text -TD_Password $TD_tb_storagePasswordTwo
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 4 -TD_ConnectionTyp $TD_cb_storageConnectionTypThree.Text -TD_IPAdresse $TD_tb_storageIPAdrThree.Text -TD_UserName $TD_tb_storageUserNameThree.Text -TD_Password $TD_tb_storagePasswordThree
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    foreach($TD_Credential in $TD_Credentials){
        <# QaD needs a Codeupdate because Grouping dose not work #>
        $TD_FCPortStats =@()
        switch ($TD_Credential.ID) {
            {($_ -eq 1)} 
            {            
                $TD_FCPortStats = IBM_FCPortStats -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.StorageUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.StoragePassword -TD_Storage $TD_cb_FCPortStats.Text -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_FCPortStatsOne.ItemsSource = $TD_FCPortStats
            }
            {($_ -eq 2)} 
            {            
                $TD_FCPortStats = IBM_FCPortStats -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.StorageUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.StoragePassword -TD_Storage $TD_cb_FCPortStats.Text -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_FCPortStatsTwo.ItemsSource = $TD_FCPortStats
            }
            {($_ -eq 3)} 
            {            
                $TD_FCPortStats = IBM_FCPortStats -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.StorageUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.StoragePassword -TD_Storage $TD_cb_FCPortStats.Text -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_FCPortStatsThree.ItemsSource = $TD_FCPortStats
            }
            {($_ -eq 4)} 
            {            
                $TD_FCPortStats = IBM_FCPortStats -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.StorageUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.StoragePassword -TD_Storage $TD_cb_FCPortStats.Text -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_FCPortStatsFour.ItemsSource = $TD_FCPortStats
        }
        Default {Write-Debug "Nothing" }
    }
    #Write-Host $TD_Host_Volume_Map
}
    #$TD_label_ExpPath.Content ="Export Path: $($TD_tb_ExportPath.Text)"
    $TD_stp_DriveInfo.Visibility="Collapsed"
    $TD_stp_HostVolInfo.Visibility="Collapsed"
    $TD_stp_StorageEventLog.Visibility="Collapsed"
    $TD_stp_FCPortStats.Visibility="Visible"
    
})

<#SAN Button#>
$TD_btn_FOS_BasicSwitchInfo.add_click({
    $TD_Credentials=@()
    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 1 -TD_ConnectionTyp $TD_cb_sanConnectionTyp.Text -TD_IPAdresse $TD_tb_sanIPAdr.Text -TD_UserName $TD_tb_sanUserName.Text -TD_Password $TD_tb_sanPassword
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 2 -TD_ConnectionTyp $TD_cb_sanConnectionTypOne.Text -TD_IPAdresse $TD_tb_sanIPAdrOne.Text -TD_UserName $TD_tb_sanUserNameOne.Text -TD_Password $TD_tb_sanPasswordOne
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 3 -TD_ConnectionTyp $TD_cb_sanConnectionTypTwo.Text -TD_IPAdresse $TD_tb_sanIPAdrTwo.Text -TD_UserName $TD_tb_sanUserNameTwo.Text -TD_Password $TD_tb_sanPasswordTwo
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 4 -TD_ConnectionTyp $TD_cb_sanConnectionTypThree.Text -TD_IPAdresse $TD_tb_sanIPAdrThree.Text -TD_UserName $TD_tb_sanUserNameThree.Text -TD_Password $TD_tb_sanPasswordThree
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    foreach($TD_Credential in $TD_Credentials){
        <# QaD needs a Codeupdate #>
        #Write-Debug -Message $TD_Credential
        switch ($TD_Credential.ID) {
            {($_ -eq 1)} 
            {   
                $FOS_BasicSwitch = FOS_BasicSwitchInfos -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_dg_sanBasicSwitchInfoOne.ItemsSource = $FOS_BasicSwitch
            }
            {($_ -eq 2) } <# -or ($_ -eq 3) -or ($_ -eq 4)}  for later use maybe #>
            {            
                $FOS_BasicSwitch = FOS_BasicSwitchInfos -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_dg_sanBasicSwitchInfoTwo.ItemsSource =$FOS_BasicSwitch
            }
            {($_ -eq 3) } <# -or ($_ -eq 3) -or ($_ -eq 4)}  for later use maybe #>
            {            
                $FOS_BasicSwitch = FOS_BasicSwitchInfos -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_dg_sanBasicSwitchInfoThree.ItemsSource =$FOS_BasicSwitch
            }
            {($_ -eq 4) }
            {            
                $FOS_BasicSwitch = FOS_BasicSwitchInfos -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_dg_sanBasicSwitchInfoFour.ItemsSource =$FOS_BasicSwitch
            }
            Default {Write-Debug "Nothing" }
        }
    }

    <#Chang to correct Content etc.#>
    <#$TD_label_ExpPHVM.Content ="Export Path: $($TD_tb_ExportPath.Text)"#>
    Start-Sleep -Seconds 0.5
    $TD_stp_sanLicenseShow.Visibility="Collapsed"
    $TD_stp_sanPortBufferShow.Visibility="Collapsed"
    $TD_stp_sanPortErrorShow.Visibility="Collapsed"
    $TD_stp_sanSwitchShow.Visibility="Collapsed"
    $TD_stp_sanZoneDetailsShow.Visibility="Collapsed"
    $TD_stp_sanBasicSwitchInfo.Visibility="Visible"
})

$TD_btn_FOS_SwitchShow.add_click({
    $TD_Credentials=@()
    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 1 -TD_ConnectionTyp $TD_cb_sanConnectionTyp.Text -TD_IPAdresse $TD_tb_sanIPAdr.Text -TD_UserName $TD_tb_sanUserName.Text -TD_Password $TD_tb_sanPassword
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 2 -TD_ConnectionTyp $TD_cb_sanConnectionTypOne.Text -TD_IPAdresse $TD_tb_sanIPAdrOne.Text -TD_UserName $TD_tb_sanUserNameOne.Text -TD_Password $TD_tb_sanPasswordOne
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 3 -TD_ConnectionTyp $TD_cb_sanConnectionTypTwo.Text -TD_IPAdresse $TD_tb_sanIPAdrTwo.Text -TD_UserName $TD_tb_sanUserNameTwo.Text -TD_Password $TD_tb_sanPasswordTwo
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 4 -TD_ConnectionTyp $TD_cb_sanConnectionTypThree.Text -TD_IPAdresse $TD_tb_sanIPAdrThree.Text -TD_UserName $TD_tb_sanUserNameThree.Text -TD_Password $TD_tb_sanPasswordThree
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    foreach($TD_Credential in $TD_Credentials){
        <# QaD needs a Codeupdate #>
        $FOS_SwitchShow =@()
        #Write-Debug -Message $TD_Credential
        switch ($TD_Credential.ID) {
            {($_ -eq 1)} 
            {   
                $FOS_SwitchShow += FOS_SwitchShowInfo -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_SwitchShowOne.ItemsSource =$FOS_SwitchShow
            }
            {($_ -eq 2) } <# -or ($_ -eq 3) -or ($_ -eq 4)}  for later use maybe #>
            {            
                $FOS_SwitchShow += FOS_SwitchShowInfo -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_SwitchShowTwo.ItemsSource =$FOS_SwitchShow
            }
            {($_ -eq 3) } <# -or ($_ -eq 3) -or ($_ -eq 4)}  for later use maybe #>
            {            
                $FOS_SwitchShow += FOS_SwitchShowInfo -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_SwitchShowThree.ItemsSource =$FOS_SwitchShow
            }
            {($_ -eq 4) }
            {            
                $FOS_SwitchShow += FOS_SwitchShowInfo -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_SwitchShowFour.ItemsSource =$FOS_SwitchShow
            }
            Default {Write-Debug "Nothing" }
        }
    }

    <#Chang to correct Content etc.#>
    <#$TD_label_ExpPHVM.Content ="Export Path: $($TD_tb_ExportPath.Text)"#>
    Start-Sleep -Seconds 0.5
    $TD_stp_sanBasicSwitchInfo.Visibility="Collapsed"
    $TD_stp_sanLicenseShow.Visibility="Collapsed"
    $TD_stp_sanPortBufferShow.Visibility="Collapsed"
    $TD_stp_sanPortErrorShow.Visibility="Collapsed"
    $TD_stp_sanZoneDetailsShow.Visibility="Collapsed"
    $TD_stp_sanSwitchShow.Visibility="Visible"
})

$TD_btn_FOS_ZoneDetailsShow.add_click({
    $TD_Credentials=@()
    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 1 -TD_ConnectionTyp $TD_cb_sanConnectionTyp.Text -TD_IPAdresse $TD_tb_sanIPAdr.Text -TD_UserName $TD_tb_sanUserName.Text -TD_Password $TD_tb_sanPassword
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 2 -TD_ConnectionTyp $TD_cb_sanConnectionTypOne.Text -TD_IPAdresse $TD_tb_sanIPAdrOne.Text -TD_UserName $TD_tb_sanUserNameOne.Text -TD_Password $TD_tb_sanPasswordOne
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 3 -TD_ConnectionTyp $TD_cb_sanConnectionTypTwo.Text -TD_IPAdresse $TD_tb_sanIPAdrTwo.Text -TD_UserName $TD_tb_sanUserNameTwo.Text -TD_Password $TD_tb_sanPasswordTwo
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 4 -TD_ConnectionTyp $TD_cb_sanConnectionTypThree.Text -TD_IPAdresse $TD_tb_sanIPAdrThree.Text -TD_UserName $TD_tb_sanUserNameThree.Text -TD_Password $TD_tb_sanPasswordThree
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    foreach($TD_Credential in $TD_Credentials){
        <# QaD needs a Codeupdate #>
        #Write-Debug -Message $TD_Credential
        switch ($TD_Credential.ID) {
            {($_ -eq 1)} 
            {   Write-Host $TD_Credential.ID -ForegroundColor Green
                $TD_FOS_ZoneShow, $FOS_EffeZoneNameOne = FOS_ZoneDetails -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Write-Host $TD_FOS_ZoneShow -ForegroundColor Yellow
                Write-Host $FOS_EffeZoneNameOne -ForegroundColor Green
                Start-Sleep -Seconds 0.5
                $TD_lb_ZoneDetailsOne.ItemsSource =$TD_FOS_ZoneShow
            }
            {($_ -eq 2) } <# -or ($_ -eq 3) -or ($_ -eq 4)}  for later use maybe #>
            {            
                $TD_FOS_ZoneShow, $FOS_EffeZoneNameTwo = FOS_ZoneDetails -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Write-Host $FOS_EffeZoneNameOne $FOS_EffeZoneNameTwo
                if($FOS_EffeZoneNameOne -ne $FOS_EffeZoneNameTwo){
                Start-Sleep -Seconds 0.5
                $TD_lb_ZoneDetailsTwo.ItemsSource =$TD_FOS_ZoneShow}
            }
            {($_ -eq 3) } <# -or ($_ -eq 3) -or ($_ -eq 4)}  for later use maybe #>
            {            
                $TD_FOS_ZoneShow, $FOS_EffeZoneNameThree = FOS_ZoneDetails  -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                Write-Host $FOS_EffeZoneNameOne $FOS_EffeZoneNameThree
                if($FOS_EffeZoneNameOne -ne $FOS_EffeZoneNameThree){
                    if($FOS_EffeZoneNameThree -ne $FOS_EffeZoneNameTwo){
                        Start-Sleep -Seconds 0.5
                        $TD_lb_ZoneDetailsTwo.ItemsSource =$TD_FOS_ZoneShow}
                    }
            }
            <# not needed becaus max support at moment are 2 fabs #>
            #{($_ -eq 4) }
            #{            
            #    $TD_FOS_PortbufferShow += FOS_ZoneDetails -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
            #    Start-Sleep -Seconds 0.5
            #    $TD_lb_PortBufferShowFour.ItemsSource =$TD_FOS_PortbufferShow
            #}
            Default {Write-Debug "Nothing" }
        }
    }
    
    <#Chang to correct Content etc.#>
    <#$TD_label_ExpPHVM.Content ="Export Path: $($TD_tb_ExportPath.Text)"#>
    Start-Sleep -Seconds 0.5
    $TD_stp_sanBasicSwitchInfo.Visibility="Collapsed"
    $TD_stp_sanLicenseShow.Visibility="Collapsed"
    $TD_stp_sanPortErrorShow.Visibility="Collapsed"
    $TD_stp_sanSwitchShow.Visibility="Collapsed"
    $TD_stp_sanPortBufferShow.Visibility="Collapsed"
    $TD_stp_sanZoneDetailsShow.Visibility="Visible"
})

$TD_btn_FOS_PortLicenseShow.add_click({

    $TD_Credentials=@()
    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 1 -TD_ConnectionTyp $TD_cb_sanConnectionTyp.Text -TD_IPAdresse $TD_tb_sanIPAdr.Text -TD_UserName $TD_tb_sanUserName.Text -TD_Password $TD_tb_sanPassword
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 2 -TD_ConnectionTyp $TD_cb_sanConnectionTypOne.Text -TD_IPAdresse $TD_tb_sanIPAdrOne.Text -TD_UserName $TD_tb_sanUserNameOne.Text -TD_Password $TD_tb_sanPasswordOne
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 3 -TD_ConnectionTyp $TD_cb_sanConnectionTypTwo.Text -TD_IPAdresse $TD_tb_sanIPAdrTwo.Text -TD_UserName $TD_tb_sanUserNameTwo.Text -TD_Password $TD_tb_sanPasswordTwo
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 4 -TD_ConnectionTyp $TD_cb_sanConnectionTypThree.Text -TD_IPAdresse $TD_tb_sanIPAdrThree.Text -TD_UserName $TD_tb_sanUserNameThree.Text -TD_Password $TD_tb_sanPasswordThree
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    foreach($TD_Credential in $TD_Credentials){
        <# QaD needs a Codeupdate #>
        $TD_FOS_PortLicenseShow =@()
        #Write-Debug -Message $TD_Credential
        switch ($TD_Credential.ID) {
            {($_ -eq 1)} 
            {   Write-Host $TD_Credential.ID -ForegroundColor Green
                $TD_FOS_PortLicenseShow += FOS_PortLicenseShowInfo -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text -TD_FOSVersion $TD_cb_FOS_Version.Text
                Start-Sleep -Seconds 1
                $TD_lb_SANInfoOne.Text = (Out-String -InputObject $TD_FOS_PortLicenseShow)
            }
            {($_ -eq 2) } <# -or ($_ -eq 3) -or ($_ -eq 4)}  for later use maybe #>
            {            
                $TD_FOS_PortLicenseShow += FOS_PortLicenseShowInfo -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text -TD_FOSVersion $TD_cb_FOS_Version.Text
                Start-Sleep -Seconds 1
                $TD_lb_SANInfoTwo.Text = (Out-String -InputObject $TD_FOS_PortLicenseShow)
            }
            {($_ -eq 3) } <# -or ($_ -eq 3) -or ($_ -eq 4)}  for later use maybe #>
            {            
                $TD_FOS_PortLicenseShow += FOS_PortLicenseShowInfo -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text -TD_FOSVersion $TD_cb_FOS_Version.Text
                Start-Sleep -Seconds 1
                $TD_lb_SANInfoThree.Text = (Out-String -InputObject $TD_FOS_PortLicenseShow)
            }
            {($_ -eq 4) }
            {            
                $TD_FOS_PortLicenseShow += FOS_PortLicenseShowInfo -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text -TD_FOSVersion $TD_cb_FOS_Version.Text
                Start-Sleep -Seconds 1
                $TD_lb_SANInfoFour.Text = (Out-String -InputObject $TD_FOS_PortLicenseShow)
            }
            Default {Write-Debug "Nothing" }
        }
    }

    $TD_stp_sanBasicSwitchInfo.Visibility="Collapsed"
    $TD_stp_sanPortErrorShow.Visibility="Collapsed"
    $TD_stp_sanPortBufferShow.Visibility="Collapsed"
    $TD_stp_sanSwitchShow.Visibility="Collapsed"
    $TD_stp_sanZoneDetailsShow.Visibility="Collapsed"
    $TD_stp_sanLicenseShow.Visibility="Visible"

})

$TD_btn_FOS_PortErrorShow.add_click({
    $TD_Credentials=@()
    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 1 -TD_ConnectionTyp $TD_cb_sanConnectionTyp.Text -TD_IPAdresse $TD_tb_sanIPAdr.Text -TD_UserName $TD_tb_sanUserName.Text -TD_Password $TD_tb_sanPassword
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 2 -TD_ConnectionTyp $TD_cb_sanConnectionTypOne.Text -TD_IPAdresse $TD_tb_sanIPAdrOne.Text -TD_UserName $TD_tb_sanUserNameOne.Text -TD_Password $TD_tb_sanPasswordOne
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 3 -TD_ConnectionTyp $TD_cb_sanConnectionTypTwo.Text -TD_IPAdresse $TD_tb_sanIPAdrTwo.Text -TD_UserName $TD_tb_sanUserNameTwo.Text -TD_Password $TD_tb_sanPasswordTwo
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 4 -TD_ConnectionTyp $TD_cb_sanConnectionTypThree.Text -TD_IPAdresse $TD_tb_sanIPAdrThree.Text -TD_UserName $TD_tb_sanUserNameThree.Text -TD_Password $TD_tb_sanPasswordThree
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    foreach($TD_Credential in $TD_Credentials){
        <# QaD needs a Codeupdate #>
        $TD_FOS_PortErrShow =@()
        #Write-Debug -Message $TD_Credential
        switch ($TD_Credential.ID) {
            {($_ -eq 1)} 
            {   Write-Host $TD_Credential.ID -ForegroundColor Green
                $TD_FOS_PortErrShow += FOS_PortErrShowInfos -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_PortErrorShowOne.ItemsSource =$TD_FOS_PortErrShow
            }
            {($_ -eq 2) } <# -or ($_ -eq 3) -or ($_ -eq 4)}  for later use maybe #>
            {            
                $TD_FOS_PortErrShow += FOS_PortErrShowInfos -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_PortErrorShowTwo.ItemsSource =$TD_FOS_PortErrShow
            }
            {($_ -eq 3) } <# -or ($_ -eq 3) -or ($_ -eq 4)}  for later use maybe #>
            {            
                $TD_FOS_PortErrShow += FOS_PortErrShowInfos -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_PortErrorShowThree.ItemsSource =$TD_FOS_PortErrShow
            }
            {($_ -eq 4) }
            {            
                $TD_FOS_PortErrShow += FOS_PortErrShowInfos -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_PortErrorShowFour.ItemsSource =$TD_FOS_PortErrShow
            }
            Default {Write-Debug "Nothing" }
        }
    }

    <#Chang to correct Content etc.#>
    <#$TD_label_ExpPHVM.Content ="Export Path: $($TD_tb_ExportPath.Text)"#>
    Start-Sleep -Seconds 0.5
    $TD_stp_sanBasicSwitchInfo.Visibility="Collapsed"
    $TD_stp_sanLicenseShow.Visibility="Collapsed"
    $TD_stp_sanPortBufferShow.Visibility="Collapsed"
    $TD_stp_sanSwitchShow.Visibility="Collapsed"
    $TD_stp_sanZoneDetailsShow.Visibility="Collapsed"
    $TD_stp_sanPortErrorShow.Visibility="Visible"
})

$TD_btn_FOS_PortBufferShow.add_click({
    $TD_Credentials=@()
    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 1 -TD_ConnectionTyp $TD_cb_sanConnectionTyp.Text -TD_IPAdresse $TD_tb_sanIPAdr.Text -TD_UserName $TD_tb_sanUserName.Text -TD_Password $TD_tb_sanPassword
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 2 -TD_ConnectionTyp $TD_cb_sanConnectionTypOne.Text -TD_IPAdresse $TD_tb_sanIPAdrOne.Text -TD_UserName $TD_tb_sanUserNameOne.Text -TD_Password $TD_tb_sanPasswordOne
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 3 -TD_ConnectionTyp $TD_cb_sanConnectionTypTwo.Text -TD_IPAdresse $TD_tb_sanIPAdrTwo.Text -TD_UserName $TD_tb_sanUserNameTwo.Text -TD_Password $TD_tb_sanPasswordTwo
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    $TD_Credentials_Checked = Get_CredGUIInfos -STP_ID 4 -TD_ConnectionTyp $TD_cb_sanConnectionTypThree.Text -TD_IPAdresse $TD_tb_sanIPAdrThree.Text -TD_UserName $TD_tb_sanUserNameThree.Text -TD_Password $TD_tb_sanPasswordThree
    $TD_Credentials += $TD_Credentials_Checked
    Start-Sleep -Seconds 0.5

    foreach($TD_Credential in $TD_Credentials){
        <# QaD needs a Codeupdate #>
        $TD_FOS_PortbufferShow =@()
        #Write-Debug -Message $TD_Credential
        switch ($TD_Credential.ID) {
            {($_ -eq 1)} 
            {   Write-Host $TD_Credential.ID -ForegroundColor Green
                $TD_FOS_PortbufferShow += FOS_PortbufferShowInfo -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_PortBufferShowOne.ItemsSource =$TD_FOS_PortbufferShow
            }
            {($_ -eq 2) } <# -or ($_ -eq 3) -or ($_ -eq 4)}  for later use maybe #>
            {            
                $TD_FOS_PortbufferShow += FOS_PortbufferShowInfo -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_PortBufferShowTwo.ItemsSource =$TD_FOS_PortbufferShow
            }
            {($_ -eq 3) } <# -or ($_ -eq 3) -or ($_ -eq 4)}  for later use maybe #>
            {            
                $TD_FOS_PortbufferShow += FOS_PortbufferShowInfo -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_PortBufferShowThree.ItemsSource =$TD_FOS_PortbufferShow
            }
            {($_ -eq 4) }
            {            
                $TD_FOS_PortbufferShow += FOS_PortbufferShowInfo -TD_Line_ID $TD_Credential.ID -TD_Device_ConnectionTyp $TD_Credential.ConnectionTyp -TD_Device_UserName $TD_Credential.SANUserName -TD_Device_DeviceIP $TD_Credential.IPAddress -TD_Device_PW $TD_Credential.SANPassword -TD_Exportpath $TD_tb_ExportPath.Text
                Start-Sleep -Seconds 0.5
                $TD_lb_PortBufferShowFour.ItemsSource =$TD_FOS_PortbufferShow
            }
            Default {Write-Debug "Nothing" }
        }
    }

    <#Chang to correct Content etc.#>
    <#$TD_label_ExpPHVM.Content ="Export Path: $($TD_tb_ExportPath.Text)"#>
    Start-Sleep -Seconds 0.5
    $TD_stp_sanBasicSwitchInfo.Visibility="Collapsed"
    $TD_stp_sanLicenseShow.Visibility="Collapsed"
    $TD_stp_sanPortErrorShow.Visibility="Collapsed"
    $TD_stp_sanSwitchShow.Visibility="Collapsed"
    $TD_stp_sanZoneDetailsShow.Visibility="Collapsed"
    $TD_stp_sanPortBufferShow.Visibility="Visible"
})
 

$TD_btn_CloseAll.add_click({
    <#CleanUp before close #>
    Remove-Item -Path $Env:TEMP\* -Filter '*_Host_Vol_Map_Temp.txt' -Force

    $Mainform.Close()
})


Get-Variable TD_*


$Mainform.showDialog()
$Mainform.activate()