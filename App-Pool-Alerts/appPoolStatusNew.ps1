$email_smtp_host = "10.51.21.66";
$email_smtp_port = 25;
$email_smtp_SSL = 0;
$email_from_address = "saxenasharad@outlook.com";
$email_to_addressArray = @("saxenasharad@outlook.com");
$email_to_POC = @("saxenasharad@outlook.com");


$appPoolListArray = @("DefaultAppPool","Classic .NET AppPool",".NET v2.0 Classic",".NET v2.0",".NET v4.5 Classic",".NET v4.5","SharePoint Web Services Root","SecurityTokenServiceApplicationPool","SharePoint Central Administration v4","SharePoint - 1011","SharePoint - 1015","myConcertoPortalTestAutomation","SharePoint OCAutomation","SharePoint - 1021","ocautomation_dev_myconcerto_accenture_com","infra_dev_myconcerto_accenture_com")

foreach ($currentAppPool in $appPoolListArray)
{
$appPoolStatus = Get-WebAppPoolState $currentAppPool
Write-Output $currentAppPool
Write-Output $appPoolStatus.Value


if ($appPoolStatus.Value -eq "Stopped")
	{
			Write-Output "Inside IF"
			
			$message = new-object Net.Mail.MailMessage;
			$message.From = $email_from_address;

           
			#This loop to send	mail to Application Leads
			 foreach ($to in $email_to_POC) {
            $message.To.Add($to);	
        }
			#This loop to send mail to Infra Team
			 foreach ($CC in $email_to_addressArray) {
            $message.CC.Add($CC);
        }
		
			
			
			$message.Subject =  ("APP POOL ALERT(" + $appPoolStatus.Value +") | " + $currentAppPool + " | "  )
			 $i = Get-NetIPAddress -AddressFamily IPv4;
			  foreach ($k in $i) {
            if ($k.IPAddress -like "127.0.0.1") {
                continue;
         }
		 $message.Subject += ($k.IPAddress + " |"+ " Development Environment ");
		 }
			
			$message.body += Get-Content -Path C:\App_Pool_Alert\email_body.txt | out-string
        $message.Body +=    "`r`n";
		foreach ($k in $i) {
		  if ($k.IPAddress -like "127.0.0.1") {
                continue;
         }
		        $message.Body +=    ("We have found that App Pool name : " + $currentAppPool + " is at "+ $appPoolStatus.value +" State on the Server IP : "+$k.IPAddress +"`r`n Please take appropriate action. `r`n" );

		 }
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
	
}