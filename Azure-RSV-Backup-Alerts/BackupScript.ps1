
$Secret= "<Client Secret>"
$ApplicationId = "<Client ID>"
$TenantId = "<enant ID>"

$SecurePassword = ConvertTo-SecureString $Secret  -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecurePassword
Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential

Get-AzRecoveryServicesBackupJob -From (Get-Date).AddDays(-1).ToUniversalTime()  -VaultId /subscriptions/<subscriptions id>/resourceGroups/<resource Group name>/providers/Microsoft.RecoveryServices/vaults/<vault name>  | Format-table -property workloadname, Status,StartTime,EndTime >  C:\BackupManagementProject\backupreport.csv
