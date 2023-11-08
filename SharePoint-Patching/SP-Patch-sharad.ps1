
<#
    ##############################################################################################################
	##############################################################################################################
	################################# Script Developed by Sharad Saxena ##########################################
	#############################  & Chandana  Created Date 23-June-2022      ##########################################
	##############################################################################################################
	##############################################################################################################
#>

#Add-PSSnapin Microsoft.SharePoint.PowerShell -EA Continue

<#
    .SYNOPSIS
        Get-SPPatchInfo retrieves information about a knowledge base article or build number.
    .DESCRIPTION
        Get-SPPatch retreives the patch metadata from https://sharepointupdates.com/patches from the supplied knowledge base article number 
        or SharePoint patch build number. Additional information can be found at https://github.com/Nauplius.
    .PARAMETER Build
        The build number to retrieve metadata for.
    .PARAMETER KnowledgeBaseArticle
        The knowledge base article to retrieve metadata for.
    .EXAMPLE
        Get-SPPatchInfo -Build 16.0.10354.20001

        Retrieves the patch information for build number 16.0.10354.20001.
    .EXAMPLE
        Get-SPPatchInfo -KnowledgeBaseArticle 4484224

        Retrieves the patch information for the knowledge base article 4484224.
    .NOTES
        Author: Trevor Seward
        Date: 06/23/2022
    .LINK
        https://thesharepointfarm.com
    .LINK
        https://github.com/Nauplius
    .LINK
        https://sharepointupdates.com
#>



<#
    .SYNOPSIS
        Install-SPPatch
    .DESCRIPTION
        Install-SPPatch reduces the amount of time it takes to install SharePoint patches. This cmdlet supports SharePoint 2013 and above. Additional information
        can be found at https://github.com/Nauplius.
    .PARAMETER Path
        The folder where the patch file(s) reside.
    .PARAMETER Pause
        Pauses the Search Service Application(s) prior to stopping the SharePoint Search Services.
    .PARAMETER Stop
        Stop the SharePoint Search Services without pausing the Search Service Application(s).
    .PARAMETER SilentInstall
        Silently installs the patches without user input. Not specifying this parameter will cause each patch to prompt to install.
    .PARAMETER KeepSearchPaused
        Keeps the Search Service Application(s) in a paused state after the installation of the patch has completed. Useful for when applying the patch to multiple
        servers in the farm. Default to false.
    .PARAMETER OnlySTS
        Only apply the STS (non-language dependent) patch. This switch may be used when only an STS patch is available.
    .EXAMPLE
        Install-SPPatch -Path C:\Updates -Pause -SilentInstall

        Install the available patches in C:\Updates, pauses the Search Service Application(s) on the farm, and performs a silent installation.
    .EXAMPLE
        Install-SPPatch -Path C:\Updates -Pause -KeepSearchPaused:$true -SilentInstall

        Install the available patches in C:\Updates, pauses the Search Service Application(s) on the farm, 
        does not resume the Search Service Application(s) after the installation is complete, and performs a silent installation.
    .NOTES
        Author: Trevor Seward
        Date: 01/16/2020
    .LINK
        https://thesharepointfarm.com
    .LINK
        https://github.com/Nauplius
    .LINK
        https://sharepointupdates.com
#>

#Function Install-SPPatch {

 param
    (
		#[string]
        #[Parameter(Mandatory = $true)]
        #[ValidateNotNullOrEmpty()]
        #$Path,
		#[switch]
        #[Parameter(Mandatory = $false)]
        #$SilentInstall,
        [switch]
        [Parameter(Mandatory = $false)]
        $OnlySTS
		
    )



	$email_smtp_host = "<SMTP IP ADDRESS>";
    $email_smtp_port = 25;
    $email_smtp_SSL = 0;
    $email_from_address = "saxenasharad@outlook.com";
    $email_to_addressArray = @("saxenasharad@outlook.com");
    $email_to_POC = @("saxenasharad@outlook.com");


	$path = "C:\SharePoint\Common"
	$SilentInstall = 1
    ####################### 
    ##Stop Other Services## 
    ####################### 
    Set-Service -Name 'IISADMIN' -StartupType Disabled 
       
    Write-Host -ForegroundColor Green 'Gracefully stopping IIS...'
    Write-Host 
    iisreset -stop -noforce 
    
    
    Write-Host -ForegroundColor Green 'Services are Stopped'
    
    
    
    ################## 
    ##Start patching## 
    ##################
    Write-Host -ForegroundColor Yellow 'Working on it... Please keep this PowerShell window open...'
    Write-Host
	
	
    $exitRebootCodes = @(3010, 17022, 17025)
#	$version = (Get-SPFarm).BuildVersion 
	$majorVersion = 16
    $patchStartTime = Get-Date
	$startTime = Get-Date
    $stspath = "C:\SharePoint\Common\sts2019-kb5002472-fullfile-x64-glb.exe"
    $wslocpath = "C:\SharePoint\Common\wssloc2019-kb5002471-fullfile-x64-glb.exe"
    
    #$patchfiles = $stspath , $wslocpath.
	Write-Host -for Yellow "Installing $sts and $wssloc"
	
	  Write-Host -ForegroundColor Green "Current build: $version"

    ########################### 
    ##Ensure Patch is Present## 
    ###########################

    if ($majorVersion -eq '16') {
        $sts = Get-ChildItem -LiteralPath $path  -Filter *.exe | ? { $_.Name -match 'sts([A-Za-z0-9\-]+).exe' }
		#$sts = $stspath
        $wssloc = Get-ChildItem -LiteralPath $path  -Filter *.exe | ? { $_.Name -match 'wssloc([A-Za-z0-9\-]+).exe' }
		#$wssloc = $wslocpath
			
        if ($OnlySTS) {
            if ($sts -eq $null) {
                Write-Host 'Missing the sts patch. Please make sure the sts patch present in the specified directory.' -ForegroundColor Red
                return            
            }
        }
        else {
            if ($sts -eq $null -and $wssloc -eq $null) {
                Write-Host 'Missing the sts and wssloc patch. Please make sure both patches are present in the specified directory.' -ForegroundColor Red
                return
            }

            if ($sts -eq $null -or $wssloc -eq $null) {
                Write-Host '[Warning] Either the sts and wssloc patch is not available. Please make sure both patches are present in the same directory or safely ignore if only single patch is available.' -ForegroundColor Yellow
                return
            }
        }

        if ($OnlySTS) {
            $patchfiles = $sts
            Write-Host -for Yellow "Installing $sts"
        }
        else {
            $patchfiles = $sts, $wssloc
            Write-Host -for Yellow "Installing $sts and $wssloc"
        }
    }
    elseif ($majorVersion -eq '15') {
        $patchfiles = Get-ChildItem -LiteralPath $Path  -Filter *.exe | ? { $_.Name -match '([A-Za-z0-9\-]+)2013-kb([A-Za-z0-9\-]+)glb.exe' }
        
        if ($patchfiles -eq $null) { 
            Write-Host 'Unable to retrieve the file(s).  Exiting Script' -ForegroundColor Red 
            return 
        }

        Write-Host -ForegroundColor Yellow "Installing $patchfiles"
    }
    elseif ($majorVersion -lt '15') {
        throw 'This cmdlet supports SharePoint 2013 and above.'
    }

	
    foreach ($patchfile in $patchfiles) {
           $filename = $patchfile.Fullname
          # unblock the file, to get rid of the prompts
           Unblock-File -Path $filename -Confirm:$false
		   Write-Host  $filename
    
            if ($SilentInstall) {
				Write-Host "Inside silent install"
                $process = Start-Process $filename -ArgumentList '/passive /quiet' -PassThru -Wait
            }
            else {
                $process = Start-Process $filename -ArgumentList '/norestart' -PassThru -Wait
            }
    
            if ($exitRebootCodes.Contains($process.ExitCode)) {
                $reboot = $true
            }
    
            Write-Host -ForegroundColor Yellow "Patch $patchfile installed with Exit Code $($process.ExitCode)"
        }
    	
    
    
        Write-Host 
        Write-Host -ForegroundColor Yellow ('Patch installation completed in {0:g}' -f ($patchEndTime - $patchStartTime))
        Write-Host
		$duration = $patchEndTime - $patchStartTime
		
		
		################## 
        ##Start Services## 
        ################## 
		
		Write-Host -ForegroundColor Yellow 'Starting Services'
        Set-Service -Name 'IISADMIN' -StartupType Automatic

        Start-Service 'IISAdmin'
		
		###Resuming IIS###
        iisreset -start
    
	$endTime = Get-Date
    Write-Host -ForegroundColor Green 'Services are Started'
  #  Write-Host -ForegroundColor Yellow ('Script completed in {0:g}' -f ($endTime - $startTime))
    Write-Host -ForegroundColor Yellow 'Started:'  $startTime 
    Write-Host -ForegroundColor Yellow 'Finished:'  $endTime 

    if ($reboot)
     {
	
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
		
		
		$message.Subject =  ( "SharePoint Patch Information for this Month | " + $env:env_name +" | ")
			 $i = Get-NetIPAddress -AddressFamily IPv4;
			  foreach ($k in $i) {
            if ($k.IPAddress -like "127.0.0.1") {
                continue;
         }
		 $message.Subject += ($k.IPAddress + " ");
		 }
	
	
	
		$message.body += Get-Content -Path C:\SharePoint\Common\email_body.txt | out-string
        $message.Body +=    "`r`n";
		foreach ($k in $i) {
		  if ($k.IPAddress -like "127.0.0.1") {
                continue;
         }
		        $message.Body +=    ("SharePoint patch has been successfully completed in Ip: "+$k.IPAddress +"`r`n ");
				$message.Body +=     "`r`n`r";
				$message.Body +=     ("SharePoint Patch Started at "+$startTime+ " GMT");
				$message.Body +=     "`r`n`r";			
				$message.Body +=     ("SharePoint Patch completed at "+$endTime+ " GMT");
				
				$message.Body +=    "`r`n`r";	
				
					
				$message.Body +=    ("Intiating restart, It will take 5mins to restart with all updated patches `r`nIMP: Please verify manually all the changes after restart. `r`n" );

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
		
		shutdown /r /f
        Write-Host -ForegroundColor Yellow 'A reboot is required'
    }

