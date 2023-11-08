# Drives to check: set to $null or empty to check all local (non-network) drives
#Created By : Sharad Saxena
# $drives = @("C","D","E","F");

$drives = $null;


# The minimum disk size to check for raising the warning
$min = (.05);
$minSize = (.05).tostring("P");

# SMTP configuration: username, password & so on
$email_smtp_host = "<SMTP_IP_ADDRESS>";
$email_smtp_port = 25;
$email_smtp_SSL = 0;
$email_from_address = "saxenasharad@outlook.com;
$email_to_addressArray = @("abc@gmail.com, xyz@gmail.com");

 
if ($drives -eq $null -Or $drives -lt 1) {
    $localVolumes = Get-WMIObject win32_volume;
    $drives = @();
    foreach ($vol in $localVolumes) {
        if ($vol.DriveType -eq 3 -And $vol.DriveLetter -ne $null ) {
            $drives += $vol.DriveLetter[0];
        }
    }
}
foreach ($d in $drives) {
    Write-Host ("`r`n");
    Write-Host ("Checking drive " + $d + " ...");
    $disk = Get-PSDrive $d;
              
              $a = $disk.Free
              $b = $disk.Used
              $t = $a + $b
              $b = $a/$t;
          
    $p = ($a/$t).tostring("P")

    #Write-Host ("value of a" +$a + "value of b" +$b+ "value of p" +$p+ ".... value of minsize" +$minSize+ "...")
        if ($b -lt $min)              
         { 
              echo $disk | Format-Table -Autosize >C:\disk_utilisation\drive_details.txt
        Write-Host ("Drive " + $d + " has less than " + $minSize `
            + " bytes free (" + $disk.free + "): sending e-mail...");
        
        $message = new-object Net.Mail.MailMessage;
        $message.From = $email_from_address;
        foreach ($to in $email_to_addressArray) {
            $message.To.Add($to);
        }
        $message.Subject =  ("Alert - Development - Low Disk Space - " + $env:computername + "-");
                             $i = Get-NetIPAddress -AddressFamily IPv4;
        foreach ($k in $i) {
            if ($k.IPAddress -like "127.0.0.1") {
                continue;
         }
            $message.Subject += ($k.IPAddress + " ");
        }
                             $message.Subject += (" drive " + $d);
        $message.Subject += ( " has less than 5% free space" );
        $message.body += Get-Content -Path C:\disk_utilisation\email_body.txt | out-string
        $message.Body +=    "`r`n";
                             $message.Body +=    (" Drive details are below: `r`n" );
                             $message.body += Get-Content -Path C:\disk_utilisation\drive_details.txt | out-string
        $message.Body +=    "`r`n`r`n";
        $message.Body +=    "Regards, `r`n`r`n";
        $message.Body +=    "Sharad Saxena (DevOps Team Lead)`r`n";
    
 
        $smtp = new-object Net.Mail.SmtpClient($email_smtp_host, $email_smtp_port);
        $smtp.EnableSSL = $email_smtp_SSL;
        $smtp.Credentials = New-Object System.Net.NetworkCredential($email_username, $email_password);
        $smtp.send($message);
        $message.Dispose();
        write-host "... E-Mail sent!" ; 
    }
    else {
        Write-Host ("Drive " + $d + " has more than " + $minSize + " bytes free: nothing to do.");
    }
}
