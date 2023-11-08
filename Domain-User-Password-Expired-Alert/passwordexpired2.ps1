# This script is to trigger e-mail to the users who's domain password is going to expire.
 
$email_smtp_host = "<SMTP Ip address>";
$email_smtp_port = 25;
$email_smtp_SSL = 0;
$email_from_address = "saxenasharad@outlook.com";
$email_to_addressArray = @("saxenasharad@outlook.com");



$MaxPwdAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days
$expiredDate = (Get-Date).addDays(-$MaxPwdAge)

$ExpiredUsers = Get-ADUser -Filter {(PasswordNeverExpires -eq $false) } -Properties PasswordNeverExpires, PasswordLastSet | select name, samaccountname, PasswordLastSet, @{name = "DaysUntilExpired"; Expression = {$_.PasswordLastSet - $ExpiredDate | select -ExpandProperty Days}} | Sort-Object PasswordLastSet


foreach($ExpiredUser in $ExpiredUsers)
{
  if($ExpiredUser.DaysUntilExpired -eq 10)

  {
  
    $email_to_POC =  @();
    $message = new-object Net.Mail.MailMessage;
    $message.From = $email_from_address;
    
    $message.Subject =  ("Please Read***myConcerto Domain Password Expiring in " + $ExpiredUser.DaysUntilExpired + " Days !")

    $useremail = $ExpiredUser.samaccountname + "@xyz.com"
    $email_to_POC +=  $useremail

    #This loop to send	mail to  User
    foreach ($to in $email_to_POC) {
            $message.To.Add($to);	
        }

    #This loop to send mail to Infra Team
	foreach ($CC in $email_to_addressArray) {
            $message.CC.Add($CC);
        }

    $message.Body += "Hi " + $ExpiredUser.name + ","
    $message.Body +=    "`r`n`r`n";
    $message.Body +=  "Your password will expire in "+ $ExpiredUser.DaysUntilExpired +" days ! `n"
    $message.Body +=    "`r`n";
    $message.Body +=    "Please follow any of the method listed below to reset your password. `n" 
    $message.Body += 	"Noncompliance will result in losing access to the Domain Account mentioned below. `n"
    $message.Body += 	"Also, other myConcerto resources like - server access, task scheduler, services etc."
    $message.Body +=    "`r`n`r`n";
    $message.Body +=    "myConcerto Domain User ID: myConcerto\" + $ExpiredUser.samaccountname
    $message.Body +=    "`r`n`r`n";

    
    $message.Body += Get-Content -Path C:\PasswordExpiredScripting\email_body.txt | out-string


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


if($ExpiredUser.DaysUntilExpired -eq 5)

  {

        $email_to_POC =  @();
    $message = new-object Net.Mail.MailMessage;
    $message.From = $email_from_address;
    
    $message.Subject =  ("Please Read***myConcerto Domain Password Expiring in " + $ExpiredUser.DaysUntilExpired + " Days !")

    $useremail = $ExpiredUser.samaccountname + "@xyz.com"
    $email_to_POC +=  $useremail

    #This loop to send	mail to  User
    foreach ($to in $email_to_POC) {
            $message.To.Add($to);	
        }

    #This loop to send mail to Infra Team
	foreach ($CC in $email_to_addressArray) {
            $message.CC.Add($CC);
        }

    $message.Body += "Hi " + $ExpiredUser.name + ","
    $message.Body +=    "`r`n`r`n";
    $message.Body +=  "Your password will expire in "+ $ExpiredUser.DaysUntilExpired +" days ! `n"
    $message.Body +=    "`r`n"
    $message.Body +=    "Please follow any of the method listed below to reset your password. `n" 
    $message.Body += 	"Noncompliance will result in losing access to the Domain Account mentioned below. `n"
    $message.Body += 	"Also, other myConcerto resources like - server access, task scheduler, services etc."
    $message.Body +=    "`r`n`r`n";
    $message.Body +=    "myConcerto Domain User ID: myConcerto\" + $ExpiredUser.samaccountname
    $message.Body +=    "`r`n`r`n";

   
    
    $message.Body += Get-Content -Path C:\PasswordExpiredScripting\email_body.txt | out-string


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

  if($ExpiredUser.DaysUntilExpired -eq 2)

  {

    $email_to_POC =  @();
    $message = new-object Net.Mail.MailMessage;
    $message.From = $email_from_address;
    
    $message.Subject =  ("Please Read***myConcerto Domain Password Expiring in " + $ExpiredUser.DaysUntilExpired + " Days !")

    $useremail = $ExpiredUser.samaccountname + "@xyz.com"
    $email_to_POC +=  $useremail

    #This loop to send	mail to  User
    foreach ($to in $email_to_POC) {
            $message.To.Add($to);	
        }

    #This loop to send mail to Infra Team
	foreach ($CC in $email_to_addressArray) {
            $message.CC.Add($CC);
        }

    $message.Body +=    "Hi " + $ExpiredUser.name + ", `n `n "
    $message.Body +=    "This is the final Reminder before your password expires in 2 days !"
    $message.Body +=    "`r`n`r`n";
    $message.Body +=    "Please follow any of the method listed below to reset your password. `n" 
    $message.Body += 	"Noncompliance will result in losing access to the Domain Account mentioned below. `n"
    $message.Body += 	"Also, other myConcerto resources like - server access, task scheduler, services etc."
    $message.Body +=    "`r`n`r`n";
    $message.Body +=    "myConcerto Domain User ID: myConcerto\" + $ExpiredUser.samaccountname
    $message.Body +=    "`r`n`r`n";

   
    $message.Body += Get-Content -Path C:\PasswordExpiredScripting\email_body.txt | out-string


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


