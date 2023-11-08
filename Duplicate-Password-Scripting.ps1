$ScriptVersion = "2022050301"
$Hostname = $env:computername
$Domain = (Get-ADDomain).DNSRoot
$Forest = (Get-ADDomain).Forest
$Platform = (Get-WmiObject -class Win32_OperatingSystem).Caption
$PSVersion = $PSVersionTable.PSVersion
$CLRVersion = $PSVersionTable.CLRVersion
$CurDir = Get-Location
$ActiveDirectoryPSModule = Get-Module -Name ActiveDirectory
$GroupPolicyPSModule = Get-Module -Name GroupPolicy

# DSInternals
$DSInternals = ".\DSInternals\DSInternals.psd1"
$PasswordQualityReport = "PasswordQualityReports_${Domain}.txt"
$WeakPasswordsFile = ".\Wordlists\WeakPasswordsFile.txt"

# TrimarcADChecks
$TrimarcADChecks = ".\TrimarcADChecks\Invoke-TrimarcADChecks.ps1"
$TrimarcReportDir = 'C:\Temp\Trimarc-ADReports'

# GPG
$GPG = ".\gpg-portable\bin\gpg.exe"
$GPGPublicKey = "sadf_project_public.key"
$GPGRecipient = "CBDC4C7D278FCCB2EEEFE5C89F1FEA73915CEBE7"
$GPGHomedir = $TrimarcReportDir

# Report
$TimeVal = Get-Date -UFormat "%Y-%m-%d-%H-%M"
$Archive = "${Domain}_${TimeVal}.zip"

# Exclusion(s)
# File(s) in TrimarcADChecks output that should not be part of the archive
$exclude = @("TrimarcADChecks-DomainUserReport-*")

function Get-TimeStamp {
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
}

Write-Host "$(Get-Timestamp) [INFO] SADF Checks Version: $ScriptVersion"
Write-Host "$(Get-Timestamp) [INFO]            Hostname: $Hostname"
Write-Host "$(Get-Timestamp) [INFO]              Domain: $Domain"
Write-Host "$(Get-Timestamp) [INFO]              Forest: $Forest"
Write-Host "$(Get-Timestamp) [INFO]            Platform: $Platform"
Write-Host "$(Get-Timestamp) [INFO]  PowerShell Version: $PSVersion"
Write-Host "$(Get-Timestamp) [INFO]          CLRVersion: $CLRVersion"

if ($ActiveDirectoryPSModule) {
    Write-Host "$(Get-Timestamp) [INFO]           AD Module: Found"
} else {
    Write-Host "$(Get-Timestamp) [INFO]           AD Module: Not Found"
}

if ($GroupPolicyPSModule) {
    Write-Host "$(Get-Timestamp) [INFO]           GP Module: Found"
} else {
    Write-Host "$(Get-Timestamp) [INFO]           GP Module: Not Found"
}

Write-Host "$(Get-Timestamp) [INFO]   Current Directory: $CurDir"

# Check if script is run directory from PowerShell ISE or in a directory not containing extracted "SADF_Checks.zip"
if (-not (Test-Path $GPG -PathType Leaf)) {
    Write-Host "$(Get-Timestamp) [ERROR] Cannot find script dependencies"
    Write-Host "$(Get-Timestamp) Please run the script from the directory where ""SADF_Checks.zip"" was extracted"
    break
}

# Check if .NET Framework 4.6 or later is installed
if ($CLRVersion -lt 4.0.30319.42000) {
    Write-Host "$(Get-Timestamp) [ERROR] .NET Framework 4.6 or later must be installed"
    Write-Host "$(Get-Timestamp) Please install .NET Framework 4.6 or later and re-run the script"
    break
}

Write-Host "$(Get-TimeStamp) Generating password quality report..."
# Remove Zone.Identifier ADS from DSInternals
Get-ChildItem -Path '.\DSInternals\' -Recurse | Unblock-File
Import-Module $DSInternals

try
{
    Get-ADReplAccount -All -Server localhost | Test-PasswordQuality -WeakPasswordsFile $WeakPasswordsFile | Out-File $PasswordQualityReport
}
catch [System.UnauthorizedAccessException]
{
        Write-Output "$(Get-TimeStamp) Error: $($PSItem.ToString())"
        Write-Output "$(Get-TimeStamp) Please run the script with Domain Administrator privileges"
        Remove-Item $PasswordQualityReport
        break
}

# Gather additional information
$DomainNetBIOSName = (Get-ADDomain).NetBIOSName

$ADUserCount = (Get-ADUser -Filter *).Count
$EnabledADUserCount = (Get-ADUser -Filter * | Where {$_.Enabled -eq "True"}).Count

$DomainAdmins = ((Get-ADGroupMember -Identity "Domain Admins" | Select-Object -Expand SamAccountName | Sort-Object) -join ",")
$EnterpriseAdmins = ((Get-ADGroupMember -Identity "Enterprise Admins" | Select-Object -Expand SamAccountName | Sort-Object) -join ",")
$ProtectedUsers = ((Get-ADGroupMember -Identity "Protected Users" | Select-Object -Expand SamAccountName | Sort-Object) -join ",")
$SchemaAdmins = ((Get-ADGroupMember -Identity "Schema Admins" | Select-Object -Expand SamAccountName | Sort-Object) -join ",")

Add-Content $PasswordQualityReport "Script Version: $ScriptVersion"
Add-Content $PasswordQualityReport "Hostname: $Hostname"
Add-Content $PasswordQualityReport "Domain: $Domain"
Add-Content $PasswordQualityReport "Domain NetBIOS Name: $DomainNetBIOSName"
Add-Content $PasswordQualityReport "Forest: $Forest"
Add-Content $PasswordQualityReport "Platform: $Platform"
Add-Content $PasswordQualityReport "PowerShell Version: $PSVersion"
Add-Content $PasswordQualityReport "CLRVersion: $CLRVersion"
Add-Content $PasswordQualityReport "AD User Count: $ADUserCount"
Add-Content $PasswordQualityReport "Enabled AD User Count: $EnabledADUserCount"
Add-Content $PasswordQualityReport "Domain Admins: $DomainAdmins"
Add-Content $PasswordQualityReport "Enterprise Admins: $EnterpriseAdmins"
Add-Content $PasswordQualityReport "Protected Users: $ProctedUsers"
Add-Content $PasswordQualityReport "Schema Admins: $SchemaAdmins"

Write-Host "$(Get-TimeStamp) Running Trimarc AD Checks..."
. $TrimarcADChecks 6>&1 3>&1 2>&1 | Out-Null

Write-Host "$(Get-TimeStamp) Creating encrypted archive..."
# Get files to compress using exclusion(s)
$LogsToGather = "$TrimarcReportDir\*.csv", "$TrimarcReportDir\*.log", "$PasswordQualityReport"
$files = Get-ChildItem -Path $LogsToGather -Exclude $exclude
 
if ($PSVersionTable.PSVersion.Major -ge 5) {
    Compress-Archive -Path $files -DestinationPath $Archive -Force
} else {
    Add-Type -Assembly "System.IO.Compression.FileSystem"
    $zip = [System.IO.Compression.ZipFile]::Open($Archive, 'create')
    $zip.Dispose()
    $compressionLevel = [System.IO.Compression.CompressionLevel]::Fastest
    $zip = [System.IO.Compression.ZipFile]::Open($Archive, 'update')
    Get-ChildItem $files | ForEach-Object {[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, (Split-Path $_.FullName -Leaf), $compressionLevel)} | Out-Null
    $zip.Dispose()
}

# Import GPG public key
& $GPG --homedir=${GPGHomedir} --import ${GPGPublicKey} 2>&1 | Out-Null

# "Ultimately trust" GPG public key
Add-Content ${GPGHomedir}\gpg.conf "trusted-key ${GPGRecipient}"

& $GPG --batch --homedir=${GPGHomedir} -r "${GPGRecipient}" -e $Archive 2>&1 | Out-Null

Remove-Item $Archive

Write-Host "$(Get-TimeStamp) Done!"
