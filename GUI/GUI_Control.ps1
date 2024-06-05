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
$TD_btn_IBM_HostVolumeMap.add_click({
    IBM_Host_Volume_Map
    #if(!($TD_UserControl1.IsLoaded)){$TD_User_Contr_Area.Children.Add($TD_UserControl1)}
    #$TD_User_Contr_Area.Children.Remove($TD_UserControl2)
    #$TD_User_Contr_Area.Children.Remove($TD_UserControl3)
})
$TD_btn_IBM_DriveInfo.add_click({
    IBM_DriveInfo 
    #$TD_User_Contr_Area.Children.Add($TD_UserControl2)
    #$TD_User_Contr_Area.Children.Remove($TD_UserControl1)
    #$TD_User_Contr_Area.Children.Remove($TD_UserControl3)
})
$TD_btn_IBM_FCPortStats.add_click({
    IBM_FCPortStats
    #$TD_User_Contr_Area.Children.Remove($TD_UserControl1)
    #$TD_User_Contr_Area.Children.Remove($TD_UserControl2)
    #$TD_User_Contr_Area.Children.Add($TD_UserControl3)
})
 
$TD_btn_CloseAll.add_click({
    $Mainform.Close()
})

Get-Variable TD_*


$Mainform.showDialog()
$Mainform.activate()