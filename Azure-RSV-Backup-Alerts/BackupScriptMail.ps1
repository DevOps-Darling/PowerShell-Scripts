$Secret= "<Client Secret>"
$ApplicationId = "<Client ID>"
$TenantId = "<Tenant ID>"

$SecurePassword = ConvertTo-SecureString $Secret  -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecurePassword
$subs="/subscriptions/<subscription ID>/resourceGroups/<rg_name>/providers/Microsoft.RecoveryServices/vaults/<vault name>"
Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential

$job1=Get-AzRecoveryServicesBackupJob -From (Get-Date).AddDays(-1).ToUniversalTime()  -VaultId $subs -status Failed 
$fc=$job1.Count
write-host $fc 

$job2=Get-AzRecoveryServicesBackupJob -From (Get-Date).AddDays(-1).ToUniversalTime()  -VaultId $subs -status Completed 
$ccount=$job2.Count
write-host $ccount

$job3=Get-AzRecoveryServicesBackupJob -From (Get-Date).AddDays(-1).ToUniversalTime()  -VaultId $subs -status InProgress 
$ip=$job3.Count
write-host $ip


$email_smtp_host = "<relay server IP address>";
$email_smtp_port = 25;
$email_smtp_SSL = 0;
$email_from_address = "saxenasharad@outlook.com";
$email_to_addressArray = @("receiver@gmail.com");
$email_to_POC = @("myConcerto.Infra.Support@accenture.com");




if ((Get-Content -Path C:\BackupManagementProject\backupreport.csv).length -eq $null)
    {       
        
            Write-Output "Inside IF"
            
    }

else
{
            
            $message = new-object Net.Mail.MailMessage;
            $message.From = $email_from_address;

          
            #This loop to send    mail to Application Leads
             foreach ($to in $email_to_POC) {
            $message.To.Add($to);    
        }
            #This loop to send mail to Infra Team
             foreach ($CC in $email_to_addressArray) {
            $message.CC.Add($CC);
        }
        
            
            if($fc -gt 0 -or $ccount -eq 0){       
           $message.Subject = ("VM Backup Status | "+" Failed="+ $fc +", In-progress="+ $ip +", Completed="+ $ccount + " | Vault <vault name>")            
           }                            

        if($Ip -gt 0 -and $ccount -gt 0 ){
           $message.Subject =  ("VM Backup Status | " +" In-progress=" +$ip +", Completed="+ $ccount+" Failed="+ $fc +" | Vault <vault name>")
           }
        if($ccount -gt 0 -and $ip -eq 0 -and $fc -eq 0){
              
            $message.Subject =  ("VM Backup Status | "+" Completed="+ $ccount +", Failed="+ $fc +", In-progress=" +$ip + " | Vault <vault name>")
           }
            
             
            $message.body += Get-Content -Path C:\BackupManagementProject\backupreport.csv | out-string
        $message.Body +=    "`r`n";
        
        $message.Body +=    "`r`n`r`n";
        $message.Body +=    "Regards, `r`n`r`n";
        $message.Body +=    "Infrastructure Support`r`n";
    

        $smtp = new-object Net.Mail.SmtpClient($email_smtp_host, $email_smtp_port);
        $smtp.EnableSSL = $email_smtp_SSL;
        $smtp.Credentials = New-Object System.Net.NetworkCredential($email_username, $email_password);
        $smtp.send($message);
        $message.Dispose();
        write-host "... E-Mail sent!" ;
    }