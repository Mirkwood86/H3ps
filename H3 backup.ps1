############################# The Menu Function #############################
## Menu function shows the options and lists created scripts and tasks.

function Show-Menu {
    Clear-Host
    Write-host "User: " -NoNewline -ForegroundColor Cyan
    Write-host "$env:UserName " -NoNewline
    Write-host "Computername: " -NoNewline -ForegroundColor Cyan
    Write-host "$env:ComputerName " -NoNewline
    Write-host "Domain: " -NoNewline -ForegroundColor Cyan
    Write-host "$env:UserDomain"
    Get-Date
    Write-Host "================ Menu ================" -ForegroundColor cyan
    Write-Host "a:  Generate backup script" -ForegroundColor darkyellow
    Write-Host "b:  Delete a backup script" -ForegroundColor darkyellow
    Write-Host "--------------- Other ----------------"
    Write-Host "1:  Empty" -ForegroundColor darkyellow
    Write-Host "2:  Empty" -ForegroundColor darkyellow
    Write-Host "3:  Empty" -ForegroundColor darkyellow
    Write-Host "4:  Empty" -ForegroundColor darkyellow
    Write-Host "======================================" -ForegroundColor cyan
    Write-Host "--------------- Scripts ----------------"

    ### Check if there are scripts, and print from taskmanager
    
    $Result = Get-ChildItem -Path "C:\bscript\scripts\*" | Measure-Object

    if ($Result.Count -lt '1')
    {
    write-host "Found no scripts"
    Write-Host "----------------------------------------"
    }
    elseif ($Result.Count -gt '0')
    {
    $task_list = get-childitem c:/bscript/scripts/ | Select-Object -expandproperty basename
    Get-ScheduledTaskInfo -TaskName $task_list | Select-Object taskname, lastruntime, nextruntime, numberofmissedruns
    Write-Host "----------------------------------------"
    }



}

############################# The Backup script function #############################
## Asks for input on source and destination, task and script name, how often and when. Compression and level.
## Script for backup is then created, and scheduled windows task is created.

function backup-wiz {

    ### Input needed to create script and scheduledtask ###

    $folder_source = Read-host "Enter source folder. (Don't end with /)"
    $folder_dest = Read-host "Enter destination folder. (Don't end with /)"
    $taskname = Read-host "Enter new task name."
    $T = Read-host "Daily? (Only option)."
    $tid = Read-host "Time of day? xx:xx format"
    $compress = Read-host "Do you wish for compression? y/n"
    $compress_level = Read-host "Compression level?. (NoCompression, Optimal, Fastest)"


    ### Write now to script file. ###

    $name = get-item $folder_source | Select-Object -expandproperty name

    Add-Content -Path c:/Bscript/scripts/$taskname.ps1 -Value '$datee = get-date -f yyyy-MM-dd-hh-mm-ss'

    if ($compress -eq 'n')
    {
    Add-Content -Path c:/Bscript/scripts/$taskname.ps1 -Value "copy -path $folder_source -Destination $folder_dest/" -NoNewline
    Add-Content -Path c:/Bscript/scripts/$taskname.ps1 -Value '$datee-' -NoNewline
    Add-Content -Path c:/Bscript/scripts/$taskname.ps1 -Value "backup-$name -Recurse"
    }
    elseif ($compress -eq 'y')
    {
    Add-Content -Path c:/Bscript/scripts/$taskname.ps1 -Value "Compress-Archive -path $folder_source -Destination $folder_dest/" -NoNewline
    Add-Content -Path c:/Bscript/scripts/$taskname.ps1 -Value '$datee-' -NoNewline
    Add-Content -Path c:/Bscript/scripts/$taskname.ps1 -Value "backup-$name -compressionlevel $compress_level"
    }

    Add-Content -Path c:/Bscript/scripts/$taskname.ps1 -Value '$ExecutingScript = $MyInvocation.MyCommand.Name'

    Add-Content -Path c:/Bscript/scripts/$taskname.ps1 -Value 'add-content -Path c:/bscript/backup_logs.txt -value "$datee backup $ExecutingScript has run"'




    ### Write to log that script is created.

    $datoo = get-date -f yyyy-MM-dd-hh-mm-ss

    Add-Content -path C:/bscript/backup_logs.txt -Value "$datoo Script $taskname created"

    ### Outputs what was written in the backup script.

    Write-host "------- SCRIPT OUTPUT -------"
    get-content -Path c:/Bscript/scripts/$taskname.ps1





    ### Making scheduled task.

    Write-host "------- TASK OUTPUT -------"

    $A = New-ScheduledTaskAction -Execute "c:/Bscript/scripts/$taskname.ps1"
    $T = New-ScheduledTaskTrigger -Daily -At $tid
    # weekly, daily, monthly
    $S = New-ScheduledTaskSettingsSet

    $D = New-ScheduledTask -Action $A -Trigger $T -Settings $S
    Register-ScheduledTask $taskname -InputObject $D


    ### Write to log that scheduledtask is created

    Add-Content -path C:/bscript/backup_logs.txt -Value "$datoo Scheduledtask $taskname created"


}

############################# Delete script and task #############################

function delete-backup-script {

    Write-Host "================ Scripts ================" -ForegroundColor cyan
    get-item C:\bscript\scripts\* | Select-Object -expandproperty name
    Write-Host "================ END ================" -ForegroundColor cyan

    $keyword = read-host "Please enter name of script you want to delete"

    ### Removes .ps1 from the end of the string, so it can remove task which is spelled without.

    $NewString = $keyword -replace ".ps1" -replace ""


    ### Removes script file and task.

    remove-item c:/bscript/scripts/$keyword -force
    Unregister-ScheduledTask $NewString -Confirm:$false

    Write-Host "Deleted $keyword" -ForegroundColor cyan

    ### Write to the log that both are deleted.

    Add-Content -path C:/bscript/backup_logs.txt -Value "$datoo Script $keyword deleted."
    Add-Content -path C:/bscript/backup_logs.txt -Value "$datoo Scheduledtask $taskname deleted."



}


############################# Menu Selector Loop #############################
## "Do", "Show-Menu" function "until" input is equal to "q"

do {
    Show-Menu
    $input = Read-Host "Please make a selection"
    switch ($input) {
        'a' {
            Clear-Host
            'You chose option #a'
            backup-wiz
        }
        'b' {
            Clear-Host
            'You chose option #b'
            Delete-backup-script
        }
        '2' {
            Clear-Host
            'You chose option #1'
            run-normal
        }
        '3' {
            Clear-Host
            'You chose option #2'
        }
        'q' {
            return
        }
    }
    pause
}
until ($input -eq 'q')
