function IBM_FCPortStats {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$TD_UserName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ipaddress]$TD_DeviceIP,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","no")]
        [string]$TD_export = "no"
    )
    begin {
        <# Connect to Device and get all needed Data #>
        $TD_CollectInfo = ssh $UserName@$DeviceIP "lsnodecanister -nohdr |while read id name IO_group_id;do lsnodecanister $id;echo;done"
    }
    
    process {
        
    }
    
    end {
        
    }
}