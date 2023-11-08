$email_smtp_host = "<SMTP IP ADDRESS>";
$email_smtp_port = 25;
$email_smtp_SSL = 0;
$email_from_address = "saxenasharad@outlook.com";
#$email_to_addressArray = 
$email_to_POC = @("saxenasharad@outlook.com");

$a=1
$b=1

$activeuser = Get-Process -IncludeUserName -ProcessName rdpclip | select username
$Date = (Get-Date).AddHours(5.5)

$CurrentUserName = $env:USERNAME

write-host $CurrentUserName


if (!($activeuser -eq $null))
	{
			Write-Output "Inside IF"
			
			$message = new-object Net.Mail.MailMessage;
			$message.From = $email_from_address;
			
			#This loop to send	mail to Application Leads
			 foreach ($to in $email_to_POC) {
            $message.To.Add($to);	
        }
			
			
			
			
			 $i = Get-NetIPAddress -AddressFamily IPv4;
			  foreach ($k in $i) {
            if ($k.IPAddress -like "127.0.0.1") {
                continue;
         }
		 $message.Subject += ("Login Information from  " + $k.IPAddress + " |" + " DC Server ");
		 }
			
			$message.body += Get-Content -Path C:\DCLoginScripting\email_body.txt | out-string
        $message.Body +=    "`r`n";
		foreach ($k in $i) {
		  if ($k.IPAddress -like "127.0.0.1") {
                continue;
         }
		        $message.Body +=    ("This user: " + $CurrentUserName + " Logged in at " + $Date + " IST" );

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
	
