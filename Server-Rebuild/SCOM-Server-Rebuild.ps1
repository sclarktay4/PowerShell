<# Variable Declaration
    $Service - Text document with a list of services.
    $Machines - Text document with a list of servers.
    $Path - The generic path of the folder location that we will be changing to force the rebuild.
    $File - The changed name of the folder that will force the rebuild.
    $FinalFile - The generic path of the folder location indicating it has been rebuilt.
    $SVC - Getting the service name and the server name from text documents.
#>
$Service = Get-Content -Path "C:\Scripts\Services.txt"
$Machines = Get-Content -Path "C:\Scripts\Server_Test.txt"
$Path = "c$\Program Files\System Center Operations Manager\Agent\Health Service State"
$File = "Health Service State - SCOM"
$FinalFile = "\\$Machines\c$\Program Files\System Center Operations Manager\Agent\Health Service State - SCOM"
$SVC = (Get-Service -Name $Service -ComputerName $Machines)
 

# Loop through Server file to load each Server one-by-one.
$Machines | ForEach-Object {
                                # Verifies if Server exists
                                if (Test-Path \\$_\$Path)
                                {
                                    # Shows us the status of the service on the server.
                                    Write-Host "$Service on $_ is $($SVC.status)" 

                                    # Instructions on what to do if the service status is Stopped.
                                    if ($SVC.status -eq 'Stopped')
                                    {    
                                        # Check to see if rebuild has already been done.
                                        if (Test-Path $FinalFile -PathType Container)
                                        {
                                            # Output that file has already been created.
                                            Write-Host "File already exists on $_."
                                        }
                                        else
                                        {  
                                            # Changing the file name to force rebuild.
                                            Write-Host "...Changing file name for rebuild on $_."
                                            Rename-Item \\$_\$Path $File   
                                            Write-Host "...Renaming Done on $_!"       
                                        }  

                                        # Output to show the service is being started.
                                        Write-Host "...Starting $Service service on $_."
                                        $SVC.Start() 
                                        Write-Host "...Starting Done on $_!"      
                                    }

                                    # Instructions on what to do if the service status is Running.
                                    elseif ($SVC.Status -eq 'Running')
                                    {    
                                        # Check to see if rebuild has already been done.
                                        if (Test-Path $FinalFile -PathType Container)
                                        {
                                            # Output that file has already been created.
                                            Write-Host "File already exists on $_."
                                        }
                                        else
                                        {   
                                            # Output to show service is about to stop.
                                            Write-Host "...Stopping $Service service on $_."
                                            $SVC.Stop() 
                                            # Pause script to give service time to stop completely.
                                            Start-Sleep 5
                                            Start-Sleep -Seconds 5 
                                            Write-Host "...Stopping Done on $_!"  

                                            # Changing the file name to force rebuild.
                                            Write-Host "...Changing file name for rebuild on $_."
                                            Rename-Item \\$_\$Path $File
                                            Write-Host "...Renaming Done on $_!" 

                                            # Output to show the service is being started.
                                            Write-Host "...Starting $Service service on $_."
                                            $SVC.Start() 
                                            Write-Host "...Starting Done on $_!" 
                                        }    
       
                                    }

                                }
                                else 
                                 {
                                    # File does not exist so Server does not exist.
                                     Write-Host "Server does not exist!"
                                 }
                                    # Pause to display information when run in Powershell.
                                     Read-Host -Prompt "Press Enter to continue"
                            }



