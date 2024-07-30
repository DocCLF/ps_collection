function IBM_BackUpConfig {
    <#
    .SYNOPSIS


    .DESCRIPTION
        Used as a placeholder for the moment, but can also be used as a standalone function!
        Version 1.0.0 | 20240730
    .EXAMPLE


    .LINK

    #>
    [CmdletBinding()]
    param (
        [Int16]$TD_Line_ID,
        [string]$TD_Device_ConnectionTyp,
        [string]$TD_Device_UserName,
        [string]$TD_Device_DeviceIP,
        [string]$TD_Device_PW,
        [string]$TD_Exportpath

    )
    
    begin{
        $ErrorActionPreference="Stop"
        Write-Debug -Message "IBM_BackUpConfig Begin block |$(Get-Date)"

        if($TD_Device_ConnectionTyp -eq "ssh"){
            try {
                ssh $TD_Device_UserName@$TD_Device_DeviceIP "svcconfig backup"
                Start-Sleep -Seconds 2
                pscp -unsafe -pw $TD_Device_PW $TD_Device_UserName@$($TD_Device_DeviceIP):/dumps/svc.config.backup.* $TD_Exportpath
            }
            catch {
                <#Do this if a terminating exception happens#>
                Write-Host "Somethign went wrong" -ForegroundColor DarkMagenta
                Write-Host $_.Exception.Message
            }
        }else {
            try {
                plink $TD_Device_UserName@$TD_Device_DeviceIP -pw $TD_Device_PW -batch "svcconfig backup"
                Start-Sleep -Seconds 2
                pscp -unsafe -pw $TD_Device_PW $TD_Device_UserName@$($TD_Device_DeviceIP):/dumps/svc.config.backup.* $TD_Exportpath
            }
            catch {
                <#Do this if a terminating exception happens#>
                Write-Host "Somethign went wrong" -ForegroundColor DarkMagenta
                Write-Host $_.Exception.Message
            }
            
        }

    }

    process{
        Write-Debug -Message "IBM_BackUpConfig Process block |$(Get-Date)"
        try {
            $TD_ExportFiles = Get-ChildItem -Path $TD_Exportpath
            <# maybe add a filter #>
        }
        catch {
            <#Do this if a terminating exception happens#>
            Write-Host "Somethign went wrong" -ForegroundColor DarkMagenta
            Write-Host $_.FullyQualifiedErrorId
        }
    }
    end {

        Write-Debug -Message "IBM_BackUpConfig End block |$(Get-Date) `n"
        return $TD_ExportFiles
        Clear-Variable TD* -Scope Global

    }
}