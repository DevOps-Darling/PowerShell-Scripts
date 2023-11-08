
$email_smtp_host = "10.51.21.66";
$email_smtp_port = 25;
$email_smtp_SSL = 0;
$email_from_address = "saxenasharad@outlook.com";
$email_to_addressArray = @("saxenasharad@outlook.com");
$email_to_POC =  @("saxenasharad@outlook.com");

$lockedusers = Search-ADAccount -LockedOut | Select SamAccountName



if ($lockedusers -ne $null)
	{
			Write-Output "Inside IF"
            Write-Output $lockedusers
			
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
			
			
			$message.Subject =  ("Account Locked ALERT 10.51.21.73 "  )
	
			
			$message.body += Get-Content -Path C:\AccountLockedScripting\email_body.txt | out-string
        $message.Body +=    "`r`n";
	    foreach($currentuser in $lockedusers)
        {
        Write-Output $currentuser
	    $message.Body +=    ($currentuser);
        $message.Body +=    "`n";
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
