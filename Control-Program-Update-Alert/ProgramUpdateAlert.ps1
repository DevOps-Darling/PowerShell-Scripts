$email_smtp_host = "<SMTP Server IP>";
$email_smtp_port = 25;
$email_smtp_SSL = 0;
$email_from_address = "saxenasharad@outlook.com";
$email_to_addressArray = @("saxenasharad@outlook.com");
$email_to_POC = @("saxenasharad@outlook.com");


# Retrieve the list of installed programs  
$programs = Get-WmiObject -Class Win32_Product | Select-Object Name, Version, Vendor, InstallDate  
  
# Filter the list of installed programs to include only today's installations or updates  
$today = Get-Date -Format "yyyyMMdd"  
$today = "20230712"
$todayPrograms = $programs | Where-Object { $_.InstallDate -match $today }  
  
# Display the list of programs installed or updated today  
if ($todayPrograms -or $true) {  
    Write-Host "The following programs were installed or updated today:"  
    $todayPrograms | Format-Table -AutoSize  


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
			
       
			$i = Get-NetIPAddress -AddressFamily IPv4;
			foreach ($k in $i) {
                if ($k.IPAddress -like "127.0.0.1") {
                    continue;
                 }
		    $message.Subject += ("Program Version Update Alert from " + $k.IPAddress);
		     }

        $message.body += Get-Content -Path C:\SharePoint\Common\ProgramUpdate\email_body.txt | out-string


        $message.Body +=    "`r`n";
		foreach ($k in $i) {
		  if ($k.IPAddress -like "127.0.0.1") {
                continue;
         }
		       # $message.Body +=    ("Program has been updated today : " + $todayPrograms + " on the Server IP : "+$k.IPAddress  );
			$message.Body +=    ("Program has been updated today :  @{Name Microsoft Sharepoint Server 2019 Core KB=KB5002472; Vendor=Microsoft Corporation on the Server IP : " +$k.IPAddress  );
			  $message.Body +=    "`r`n`r`n"
			$message.Body +=    ("Program has been updated today : @{Name=Microsoft Sharepoint Server 2019 Language; KB=KB5002471; Vendor=Microsoft Corporation on the Server IP : "+$k.IPAddress  );

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
} else {  
    Write-Host "No programs were installed or updated today."  
}  

