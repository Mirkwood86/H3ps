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
    Write-Host "1:  Backup this computer to server" -ForegroundColor darkyellow
    Write-Host "2:  Restore this computer from server" -ForegroundColor darkyellow
    Write-Host "3:  Empty" -ForegroundColor darkyellow
    Write-Host "4:  Empty" -ForegroundColor darkyellow
    Write-Host "======================================" -ForegroundColor cyan
    Write-Host "--------------- Scripts ----------------"
    $task_list = get-childitem c:/bscript/scripts/ | Select-Object -expandproperty basename
    Get-ScheduledTask -TaskName $task_list | Select-Object taskname, state
    Write-Host "----------------------------------------"
}

############################# The Backup script function #############################
## Asks for input on source and destination, task and script name, how often and when.
## Script for backup is then created, and scheduled windows task is created.

function backup-wiz {

    ### Input needed to create script and scheduledtask ###

    $folder_source = Read-host "What folder do you wish to backup?"
    $folder_dest = Read-host "Enter folder destination"
    $taskname = Read-host "Enter new task name"
    $T = Read-host "Daily? "
    $tid = Read-host "Time of day? xx:xx format"


    ### Write now to file. ###

    $name = get-item $folder_source | Select-Object -expandproperty name

    Add-Content -Path c:/Bscript/scripts/$taskname.ps1 -Value '$datee = get-date -f yyyy-MM-dd-hh-mm-ss'
    Add-Content -Path c:/Bscript/scripts/$taskname.ps1 -Value "copy -path $folder_source -Destination '$folder_dest" -NoNewline
    Add-Content -Path c:/Bscript/scripts/$taskname.ps1 -Value '$datee ' -NoNewline
    Add-Content -Path c:/Bscript/scripts/$taskname.ps1 -Value "backup_$name' -Recurse"

    Add-Content -Path c:/Bscript/scripts/$taskname.ps1 -Value '$ExecutingScript = $MyInvocation.MyCommand.Name'

    Add-Content -Path c:/Bscript/scripts/$taskname.ps1 -Value 'add-content -Path c:/bscript/backup_logs.txt -value "$datee - backup $ExecutingScript has run"'



    ### Write to log that script is created.

    Add-Content -path C:/bscript/scripter-log.txt -Value "$datoo Script $taskname created"

    ### Output what was written in the backup script.

    Write-host "------- SCRIPT OUTPUT -------"
    get-content -Path c:/Bscript/scripts/$taskname.ps1

    ### Making scheduled task. ###

    Write-host "------- TASK OUTPUT -------"

    $A = New-ScheduledTaskAction -Execute "c:/Bscript/scripts/$taskname.ps1"
    $T = New-ScheduledTaskTrigger -Daily -At $tid
    # weekly, daily, monthly
    $S = New-ScheduledTaskSettingsSet
    $D = New-ScheduledTask -Action $A -Trigger $T -Settings $S
    Register-ScheduledTask $taskname -InputObject $D


    ### Write to log that scheduledtask is created

    Add-Content -path C:/bscript/scripter-log.txt -Value "$datoo Scheduledtask $taskname created"


}

############################# Backup now (non-scheduled backup) #############################

function backup-this-pc {
    $keyword = read-host "Please enter search word"
}

############################# Restore from a backup #############################

function restore-this-pc {
    $keyword = read-host "Please enter search word"
}

############################# empty #############################

function empty {
    $keyword = read-host "Please enter search word"
}

############################# Menu Selector Loop #############################
## "Do", "Show-Menu" function until input is equal to "q"

do {
    Show-Menu
    $input = Read-Host "Please make a selection"
    switch ($input) {
        'a' {
            Clear-Host
            'You chose option #a'
            backup-wiz
        }
        '1' {
            Clear-Host
            'You chose option #1'
            backup-this-pc
        }
        '2' {
            Clear-Host
            'You chose option #2'
            restore-this-pc
        }
        '3' {
            Clear-Host
            'You chose option #3'
        }
        'q' {
            return
        }
    }
    pause
}
until ($input -eq 'q')
