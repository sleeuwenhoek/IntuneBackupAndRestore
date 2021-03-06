function Invoke-IntuneBackupClientApp {
    <#
    .SYNOPSIS
    Backup Intune Client Apps
    
    .DESCRIPTION
    Backup Intune Client Apps as JSON files per Device Compliance Policy to the specified Path.
    
    .PARAMETER Path
    Path to store backup files
    
    .EXAMPLE
    Invoke-IntuneBackupClientApp -Path "C:\temp"
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet("v1.0", "Beta")]
        [string]$ApiVersion = "Beta"
    )

    # Set the Microsoft Graph API endpoint
    if (-not ((Get-MSGraphEnvironment).SchemaVersion -eq $apiVersion)) {
        Update-MSGraphEnvironment -SchemaVersion $apiVersion -Quiet
        Connect-MSGraph -ForceNonInteractive -Quiet
    }

    # Create folder if not exists
    if (-not (Test-Path "$Path\Client Apps")) {
        $null = New-Item -Path "$Path\Client Apps" -ItemType Directory
    }

    # Get all Client Apps
    $clientApps = Get-DeviceAppManagement_MobileApps | Get-MSGraphAllPages

    foreach ($clientApp in $clientApps) {
        Write-Output "Backing Up - Client App: $($clientApp.displayName)"
        $clientAppType = $clientApp.'@odata.type'.split('.')[-1]

        $fileName = ($clientApp.displayName).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
        $clientAppDetails = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceAppManagement/mobileApps/$($clientApp.id)"
        $clientAppDetails | ConvertTo-Json | Out-File -LiteralPath "$path\Client Apps\$($clientAppType)_$($fileName).json"
    }
}