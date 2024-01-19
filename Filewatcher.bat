@echo off
cd\
::Global Variables
set ERRORLEVEL = 0
::Check if PMSAdapter folder has been created, if not create it.
if exist C:\ProgramData\PMSAdapter goto :Start
mkdir C:\ProgramData\PMSAdapter
::-----------------------------------------------------------------------------------------------::  Start
:Start
cls
::Check array to see if that PMSAdapter is installed
::If no instance name was made during the initial install, it has no '$' in the name
SETLOCAL ENABLEDELAYEDEXPANSION
::If PMSAdapter found search folder for json files and report them back here.
set "fileIndex=0"
for %%F in (C:\ProgramData\PMSAdapter\*.json) do (
    set /a "fileIndex+=1"
    for %%A in ("%%F") do (
        set "jsonFile[!fileIndex!]=%%~nA"
    )
)
::List reuested PMSAdapters
FOR /L %%i IN (1,1,%fileIndex%) DO ( 
    if !jsonFile[%%i]! equ config (
        call echo OpenTechPMSAdapter is Installed.
    ) else (
        call echo OpenTechPMSAdapter$!jsonFile[%%i]! is Installed.
    )
)
ENDLOCAL
::Clear screen
cls
::UI for options
echo -------------------------------
echo 1 - New Installation
echo 2 - Configure Existing Instance
echo 3 - Uninstall Existing Instance
echo 4 - Stop/Start Existing Services
echo 5 - List Off Exising Instances
echo -------------------------------
::Prompt user for input on option choice
set /p menu=Please select an option listed above.  
if %menu%==1 goto :install_Menu
if %menu%==2 goto :config_Install
if %menu%==3 goto :uninstall
if %menu%==4 goto :stop/start
if %menu%==5 goto :list
::Incorrect option was made
echo you have entered an incorect option.
goto :start
pause
::Close program if something doesn't work
exit
:install_Menu
cls
::UI for options
echo -------------------------------
echo 1 - Digi
echo 2 - Falcon
echo 3 - PTIStorLogix
echo Any - To go back
echo -------------------------------
::Prompt user for input on option choice
set /p install_Menu=Please select an option listed above.  
if %install_Menu%==1 goto :new_Install
if %install_Menu%==2 goto :new_Install_PTI
if %install_Menu%==3 goto :new_Install_PTI
::Incorrect option was made
echo you have entered an incorect option.
goto :start
pause
::Close program if something doesn't work
exit
::################################################################################
::################################################################################
::#################                                              #################
::#################                  uninstall                   #################
::#################                                              #################
::################################################################################
::################################################################################
::-----------------------------------------------------------------------------------------------::  uninstall
:uninstall
cls
::Check to see if user selected correct option
set uninstall_Check=0
set /p uninstall_Check=Are you sure you want to uninstall pmsadapterclients? [y/n]  
if /I %uninstall_Check% NEQ Y (
    echo Going back to the menu.
    goto :Start
)
cd c:/Filewatcher
::Check array if installed then prompt user for deletion
SETLOCAL ENABLEDELAYEDEXPANSION
::If PMSAdapter found search folder for json files and report them back here.
set "fileIndex=0"
for %%F in (C:\ProgramData\PMSAdapter\*.json) do (
    set /a "fileIndex+=1"
    for %%A in ("%%F") do (
        set "jsonFile[!fileIndex!]=%%~nA"
    )
)
::Prompt user for deletion
for /l %%i in (1,1,%fileIndex%) do (
    if !jsonFile[%%i]! equ config (
        echo Do you want to uninstall OpenTechPMSAdapter? [y/n]
        set /p !jsonFile[%%i].uninstallWanted= 
    ) else (
        echo Do you want to uninstall OpenTechPMSAdapter$!jsonFile[%%i]!? [y/n]
        set /p !jsonFile[%%i].uninstallWanted= 
    )  
)
::Delete requested PMSAdapters
FOR /L %%i IN (0 1 10) DO ( 
   if /I !jsonFile[%%i].uninstallWanted! EQU y (
        if !jsonFile[%%i]! equ config (
            call sc stop OpenTechPMSAdapter
            call pmsadapterclient.exe uninstall
            pause
            call echo OpenTechPMSAdapter has been uninstalled.
        ) else (
            call sc stop OpenTechPMSAdapter$!jsonFile[%%i]!
            call pmsadapterclient.exe uninstall -instance:!jsonFile[%%i]!
            pause
            call echo OpenTechPMSAdapter$!jsonFile[%%i]! has been uninstalled.
        ) 
   )
)
ENDLOCAL
echo ##############################################################################################
echo ##############################################################################################
echo ##########                                                                          ##########
echo ##########                            Uninstall Complete                            ##########
echo ##########                                                                          ##########
echo ##############################################################################################
echo ##############################################################################################
pause
::Uninstall complete go back to :start
goto :start
::Close program if something doesn't work
exit

::################################################################################
::################################################################################
::#################                                              #################
::#################               Config Installs                #################
::#################                                              #################
::################################################################################
::################################################################################
::-----------------------------------------------------------------------------------------------::  config_Install
:config_Install
cls
::Check to see if user selected correct option
set config_Check=0
set /p config_Check=Are you sure you want to configure pmsadapterclients? [y/n]  
if /I %config_Check% NEQ Y (
    echo Going back to the menu.
    goto :Start
)
cd c:/Filewatcher
::Check array if installed then prompt user for config
SETLOCAL ENABLEDELAYEDEXPANSION
::If PMSAdapter found search folder for json files and report them back here.
set "fileIndex=0"
for %%F in (C:\ProgramData\PMSAdapter\*.json) do (
    set /a "fileIndex+=1"
    for %%A in ("%%F") do (
        set "jsonFile[!fileIndex!]=%%~nA"
    )
)
::Prompt user for config
for /l %%i in (1,1,%fileIndex%) do (
    if !jsonFile[%%i]! equ config (
        echo Do you want to configure OpenTechPMSAdapter? [y/n]
        set /p !jsonFile[%%i].configWanted= 
    ) else (
        echo Do you want to configure OpenTechPMSAdapter$!jsonFile[%%i]!? [y/n]
        set /p !jsonFile[%%i].configWanted= 
    )    
)
::Configure/Stop reuested PMSAdapters
FOR /L %%i IN (1,1,%fileIndex%) DO ( 
   if /I !jsonFile[%%i].configWanted! EQU y (
        if !jsonFile[%%i]! equ config (
            call sc stop OpenTechPMSAdapter
            call pmsadapterclient.exe config
            pause
            call echo OpenTechPMSAdapter has been configured.
        ) else (
            call sc stop OpenTechPMSAdapter$!jsonFile[%%i]!
            call pmsadapterclient.exe config -instance:!jsonFile[%%i]!
            pause
            call echo OpenTechPMSAdapter$!jsonFile[%%i]! has been configured.
        )   
   )
)
::Start configured PMSAdapters
FOR /L %%i IN (1,1,%fileIndex%) DO ( 
   if /I !jsonFile[%%i].configWanted! EQU y (
        if !jsonFile[%%i]! equ config (
            call sc start OpenTechPMSAdapter
            call set !jsonFile[%%i].configWanted=n
        ) else (
            call sc start OpenTechPMSAdapter$!jsonFile[%%i]!
            call set !jsonFile[%%i].configWanted=n
        )  
   )
)
ENDLOCAL
echo -------------------------------
set /p configMore=Would you like to config again? [y/n]  
if /I %configMore%==Y (
    goto :config_Install
)
if /I %configMore%==N (
    goto :start
)
echo you entered an invalid response. Going back.
pause
goto :start
exit
echo ##############################################################################################
echo ##############################################################################################
echo ##########                                                                          ##########
echo ##########                          Configuration Complete                          ##########
echo ##########                                                                          ##########
echo ##############################################################################################
echo ##############################################################################################
::Configuration complete go back to :start
goto :start
::Close program if something doesn't work
exit

::################################################################################
::################################################################################
::#################                                              #################
::#################            New Digi Installation             #################
::#################                                              #################
::################################################################################
::################################################################################
::-----------------------------------------------------------------------------------------------::  new_Install
:new_Install
cls
::Check to see if user selected correct option
set install_Check=0
set /p install_Check=Are you sure you want to install new Digi PMSAdapterClients? [y/n]  
if /I %install_Check% NEQ Y (
    echo Going back to the menu.
    goto :Start
)
::Declaring all variables.
set exist_Scheduler=0
set gateways=0
set gateway_Var_One=main
set gateway_Var_Two=annex
set gateway_Var_Three=annex2
set gateway_Var_Four=annex3
set gateway_Var_Five=annex4
set custom_Install=0
::Digi Specific variables
set exist_Digi=0
set exist_Digi_YN=0
set exist_OLD_Digi=0
set exist_DigiSend1=0
set exist_DigiSend2=0
set exist_DigiSend3=0
set exist_DigiSend4=0
set exist_DigiSend5=0
::-----------------------------------------------------------------------------------------------::  Check1
:Check1
::Checking to see there is an existing DIGI folder or OLD_DIGI
echo Checking to see if this has been run...
if exist C:\Digi (
    set exist_Digi=1
    echo DIGI found.
) else (
    set exist_Digi=0
    echo No DIGI found.
)
if exist C:\OLD_DIGI (
    set exist_OLD_Digi=1
    echo OLD_DIGI found.
) else (
    set exist_OLD_Digi=0
    echo No OLD_DIGI found.
)
::Check to see if OLD_DIGI has been made. If so restart. If not continue.
if %exist_OLD_Digi%==1 (
    if %exist_Digi%==1 (
        echo This has been run! Please check/rename/remove your Digi folders.
        pause
        goto :Check1
    )
)
::Checking to see if Digi structure is correct.
echo Checking if Digi structure is correct...
if exist C:\FileWatcher\DigiSend\DigiSend1.exe (
    set exist_DigiSend1=1
) else set exist_DigiSend1=0
if exist C:\FileWatcher\DigiSend\DigiSend2.exe (
    set exist_DigiSend2=1
) else set exist_DigiSend2=0
if exist C:\FileWatcher\DigiSend\DigiSend3.exe (
    set exist_DigiSend3=1
) else set exist_DigiSend3=0
if exist C:\FileWatcher\DigiSend\DigiSend4.exe (
    set exist_DigiSend4=1
) else set exist_DigiSend4=0
if exist C:\FileWatcher\DigiSend\DigiSend5.exe (
    set exist_DigiSend5=1
) else set exist_DigiSend5=0
if %exist_DigiSend1%==0 (
    echo Missing Dependency 'DigiSend1'. Please Fix this before you continue.
    pause
    Exit
) else echo DigiSend1 found
if %exist_DigiSend2%==0 (
    echo Missing Dependency 'DigiSend2'. Please Fix this before you continue.
    pause
    Exit
) else echo DigiSend2 found
if %exist_DigiSend3%==0 (
    echo Missing Dependency 'DigiSend3'. Please Fix this before you continue.
    pause
    Exit
) else echo DigiSend3 found
if %exist_DigiSend4%==0 (
    echo Missing Dependency 'DigiSend4'. Please Fix this before you continue.
    pause
    Exit
) else echo DigiSend4 found
if %exist_DigiSend5%==0 (
    echo Missing Dependency 'DigiSend5'. Please Fix this before you continue.
    pause
    Exit
) else echo DigiSend5 found
echo All Digisend files found.
::-----------------------------------------------------------------------------------------------::  Restart
:Restart
set ERRORLEVEL = 0
::Prompt to see if they are okay with renaming existing Digi folder
if %exist_Digi%==1 set /p exist_Digi_YN=Do you want to rename the existing "Digi" directory to "OLD_DIGI"? [Y/N]  
cd C:\
::Response to the renaming.
if /I %exist_Digi_YN%==Y (
    echo Renaming the existing Digi Folder to OLD_Digi.
    move Digi OLD_Digi
)
if %ERRORLEVEL% GTR 0 (
    echo Something went wrong when renaming the Digi Folder. Please fix before you continue.
    pause
    cd C:\
    move OLD_Digi Digi
    goto :Restart
)
if /I %exist_Digi_YN%==Y (
    goto :Cond
)
if /I %exist_Digi_YN%==N (
    echo Please rename or move the existing Digi directory.
    pause
    goto :Check1
)
::If no DIGI or OLD_DIGI continue.
if %exist_Digi%==0 goto :Cond
::If the User does not put a valid response restart the script.
echo You entered a non valid response.
pause
goto :Restart
::-----------------------------------------------------------------------------------------------::  Cond
:Cond
::Create Digi Folder
echo Creating new Digi folder.
mkdir c:\Digi
::-----------------------------------------------------------------------------------------------::  Custom
:Custom
SETLOCAL ENABLEDELAYEDEXPANSION
::If PMSAdapter found search folder for json files and report them back here.
set "fileIndex=0"
for %%F in (C:\ProgramData\PMSAdapter\*.json) do (
    set /a "fileIndex+=1"
    for %%A in ("%%F") do (
        set "jsonFile[!fileIndex!]=%%~nA"
    )
)
::List reuested PMSAdapters
FOR /L %%i IN (1,1,%fileIndex%) DO ( 
    if !jsonFile[%%i]! equ config (
        call echo OpenTechPMSAdapter is Installed.
    ) else (
        call echo OpenTechPMSAdapter$!jsonFile[%%i]! is already Installed.
    )
)
ENDLOCAL
::Ask for custom install/Naming of the instances
set /p custom_Install=Would you like a custom install? [Y/N]  
::Responce to the custom install.
if /I %custom_Install%==Y (
    set custom_Install=1
    goto :Gateways
)
if /I %custom_Install%==N (
    set custom_Install=0
    goto :Gateways
)
echo You entered a non valid response.
pause
goto :Custom
::-----------------------------------------------------------------------------------------------::  Gateways
:Gateways
::Ask for how many instances.
set /p gateways=How many Gateways do you have (1 to 5)?  
::Variable check. If number is too high ask again. If incorrect variable ask again.
if %gateways%==1 goto :DigiSend
if %gateways%==2 goto :DigiSend
if %gateways%==3 goto :DigiSend
if %gateways%==4 goto :DigiSend
if %gateways%==5 goto :DigiSend
if %gateways%>=6 (
    echo You have entered too high of a number...
) else echo You entered an incorrect number...
pause
goto :Gateways
::-----------------------------------------------------------------------------------------------::  DigiSend
:DigiSend
::Moving correct DigiSend.exe to Digi folder
echo Creating DigiSend file.
copy C:\FileWatcher\DigiSend\DigiSend%gateways%.exe c:\digi
cd c:\digi
rename digisend%gateways%.exe digisend.exe
::Error Check
if %ERRORLEVEL% equ 1 (
    echo Something went wrong when finding/naming the DigiSend.exe. Please fix before you continue.
    pause
    cd C:\
    rmdir c:\Digi
    goto :Start
)
::Check for custom install
if %custom_Install%==0 (
    goto :Install
)
::Name custom install
if %gateways%==1 (
    set /p gateway_Var_One=What is the name of the First Gateway? 
)
if %gateways%==2 (
    set /p gateway_Var_One=What is the name of the First Gateway? 
    set /p gateway_Var_Two=What is the name of the Second Gateway? 
)
if %gateways%==3 (
    set /p gateway_Var_One=What is the name of the First Gateway? 
    set /p gateway_Var_Two=What is the name of the Second Gateway? 
    set /p gateway_Var_Three=What is the name of the Third Gateway? 
)
if %gateways%==4 (
    set /p gateway_Var_One=What is the name of the First Gateway? 
    set /p gateway_Var_Two=What is the name of the Second Gateway? 
    set /p gateway_Var_Three=What is the name of the Third Gateway? 
    set /p gateway_Var_Four=What is the name of the Fourth Gateway? 
)
if %gateways%==5 (
    set /p gateway_Var_One=What is the name of the First Gateway? 
    set /p gateway_Var_Two=What is the name of the Second Gateway? 
    set /p gateway_Var_Three=What is the name of the Third Gateway? 
    set /p gateway_Var_Four=What is the name of the Fourth Gateway? 
    set /p gateway_Var_Five=What is the name of the Fifth Gateway? 
)
::-----------------------------------------------------------------------------------------------::  Install
:Install
set ERRORLEVEL = 0
if exist C:\FileWatcher\Installer\Configuration goto :NonConfigSkip
goto :ConfigSkip
::-----------------------------------------------------------------------------------------------::  NonConfigSkip
:NonConfigSkip
::Install requested gateways
cd c:\filewatcher
if %gateways%==1 (
    cd C:\ProgramData\PMSAdapter
    copy C:\FileWatcher\Installer\Configuration\config.noinstance.1.main.json C:\ProgramData\PMSAdapter
    ren config.noinstance.1.main.json %gateway_Var_One%.json
)
if %gateways%==2 (
    cd C:\ProgramData\PMSAdapter
    copy C:\FileWatcher\Installer\Configuration\config.instance.1.main.json C:\ProgramData\PMSAdapter
    ren config.instance.1.main.json %gateway_Var_One%.json
    copy C:\FileWatcher\Installer\Configuration\config.instance.2.annexes.json C:\ProgramData\PMSAdapter
    ren config.instance.2.annexes.json %gateway_Var_Two%.json
)
if %gateways%==3 (
    cd C:\ProgramData\PMSAdapter
    copy C:\FileWatcher\Installer\Configuration\config.instance.1.main.json C:\ProgramData\PMSAdapter
    ren config.instance.1.main.json %gateway_Var_One%.json
    copy C:\FileWatcher\Installer\Configuration\config.instance.2.annexes.json C:\ProgramData\PMSAdapter
    ren config.instance.2.annexes.json %gateway_Var_Two%.json
    copy C:\FileWatcher\Installer\Configuration\config.instance.3.annexes.json C:\ProgramData\PMSAdapter
    ren config.instance.2.annexes.json %gateway_Var_Three%.json
)
if %gateways%==4 (
    cd C:\ProgramData\PMSAdapter
    copy C:\FileWatcher\Installer\Configuration\config.instance.1.main.json C:\ProgramData\PMSAdapter
    ren config.instance.1.main.json %gateway_Var_One%.json
    copy C:\FileWatcher\Installer\Configuration\config.instance.2.annexes.json C:\ProgramData\PMSAdapter
    ren config.instance.2.annexes.json %gateway_Var_Two%.json
    copy C:\FileWatcher\Installer\Configuration\config.instance.3.annexes.json C:\ProgramData\PMSAdapter
    ren config.instance.2.annexes.json %gateway_Var_Three%.json
    copy C:\FileWatcher\Installer\Configuration\config.instance.4.annexes.json C:\ProgramData\PMSAdapter
    ren config.instance.2.annexes.json %gateway_Var_Four%.json
)
if %gateways%==5 (
    cd C:\ProgramData\PMSAdapter
    copy C:\FileWatcher\Installer\Configuration\config.instance.1.main.json C:\ProgramData\PMSAdapter
    ren config.instance.1.main.json %gateway_Var_One%.json
    copy C:\FileWatcher\Installer\Configuration\config.instance.2.annexes.json C:\ProgramData\PMSAdapter
    ren config.instance.2.annexes.json %gateway_Var_Two%.json
    copy C:\FileWatcher\Installer\Configuration\config.instance.3.annexes.json C:\ProgramData\PMSAdapter
    ren config.instance.2.annexes.json %gateway_Var_Three%.json
    copy C:\FileWatcher\Installer\Configuration\config.instance.4.annexes.json C:\ProgramData\PMSAdapter
    ren config.instance.2.annexes.json %gateway_Var_Four%.json
    copy C:\FileWatcher\Installer\Configuration\config.instance.5.annexes.json C:\ProgramData\PMSAdapter
    ren config.instance.2.annexes.json %gateway_Var_Five%.json
)
::-----------------------------------------------------------------------------------------------::  ConfigSkip
:ConfigSkip
cd C:\FileWatcher
if %gateways%==1 (
    echo Installing 1/1 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_One%
    pause
)
if %gateways%==2 (
    echo Installing 1/2 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_One%
    pause
    echo Installing 2/2 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_Two%
    pause
)
if %gateways%==3 (
    echo Installing 1/3 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_One%
    pause
    echo Installing 2/3 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_Two%
    pause
    echo Installing 3/3 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_Three%
    pause
)
if %gateways%==4 (
    echo Installing 1/4 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_One%
    pause
    echo Installing 2/4 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_Two%
    pause
    echo Installing 3/4 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_Three%
    pause
    echo Installing 4/4 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_Four%
    pause
)
if %gateways%==5 (
    echo Installing 1/5 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_One%
    pause
    echo Installing 2/5 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_Two%
    pause
    echo Installing 3/5 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_Three%
    pause
    echo Installing 4/5 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_Four%
    pause
    echo Installing 5/5 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_Five%
    pause
)
echo FileWatcher setup complete.
::Set recovery setting and startup for services
echo Configuring Services...
if %gateways%==1 (
    sc failure OpenTechPMSAdapter$%gateway_Var_One% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc config OpenTechPMSAdapter$%gateway_Var_One% start=delayed-auto
    sc start OpenTechPMSAdapter$%gateway_Var_One%
)
if %gateways%==2 (
    sc failure OpenTechPMSAdapter$%gateway_Var_One% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc failure OpenTechPMSAdapter$%gateway_Var_Two% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc config OpenTechPMSAdapter$%gateway_Var_One% start=delayed-auto
    sc config OpenTechPMSAdapter$%gateway_Var_Two% start=delayed-auto
    sc start OpenTechPMSAdapter$%gateway_Var_One%
    sc start OpenTechPMSAdapter$%gateway_Var_Two%
)
if %gateways%==3 (
    sc failure OpenTechPMSAdapter$%gateway_Var_One% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc failure OpenTechPMSAdapter$%gateway_Var_Two% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc failure OpenTechPMSAdapter$%gateway_Var_Three% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc config OpenTechPMSAdapter$%gateway_Var_One% start=delayed-auto
    sc config OpenTechPMSAdapter$%gateway_Var_Two% start=delayed-auto
    sc config OpenTechPMSAdapter$%gateway_Var_Three% start=delayed-auto
    sc start OpenTechPMSAdapter$%gateway_Var_One%
    sc start OpenTechPMSAdapter$%gateway_Var_two%
    sc start OpenTechPMSAdapter$%gateway_Var_Three%
)
if %gateways%==4 (
    sc failure OpenTechPMSAdapter$%gateway_Var_One% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc failure OpenTechPMSAdapter$%gateway_Var_Two% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc failure OpenTechPMSAdapter$%gateway_Var_Three% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc failure OpenTechPMSAdapter$%gateway_Var_Four% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc config OpenTechPMSAdapter$%gateway_Var_One% start=delayed-auto
    sc config OpenTechPMSAdapter$%gateway_Var_Two% start=delayed-auto
    sc config OpenTechPMSAdapter$%gateway_Var_Three% start=delayed-auto
    sc config OpenTechPMSAdapter$%gateway_Var_Four% start=delayed-auto
    sc start OpenTechPMSAdapter$%gateway_Var_One%
    sc start OpenTechPMSAdapter$%gateway_Var_two%
    sc start OpenTechPMSAdapter$%gateway_Var_Three%
    sc start OpenTechPMSAdapter$%gateway_Var_Four%
)
if %gateways%==5 (
    sc failure OpenTechPMSAdapter$%gateway_Var_One% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc failure OpenTechPMSAdapter$%gateway_Var_Two% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc failure OpenTechPMSAdapter$%gateway_Var_Three% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc failure OpenTechPMSAdapter$%gateway_Var_Four% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc failure OpenTechPMSAdapter$%gateway_Var_Five% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc config OpenTechPMSAdapter$%gateway_Var_One% start=delayed-auto
    sc config OpenTechPMSAdapter$%gateway_Var_Two% start=delayed-auto
    sc config OpenTechPMSAdapter$%gateway_Var_Three% start=delayed-auto
    sc config OpenTechPMSAdapter$%gateway_Var_Four% start=delayed-auto
    sc config OpenTechPMSAdapter$%gateway_Var_Five% start=delayed-auto
    sc start OpenTechPMSAdapter$%gateway_Var_One%
    sc start OpenTechPMSAdapter$%gateway_Var_two%
    sc start OpenTechPMSAdapter$%gateway_Var_Three%
    sc start OpenTechPMSAdapter$%gateway_Var_Four%
    sc start OpenTechPMSAdapter$%gateway_Var_Five%
)
echo Configuration complete.
::If there are more than 2 gateways we need to run system scheduler
if %gateways% GTR 2 (
    echo There is more than two gateways. In order to complete this install
    echo we need to install system scheduler.
    pause
    echo Starting the installer...
    start C:\filewatcher\installer\TimeScheduler\TimeScheduler.exe
    echo Please complete the installer before continuing.
    :Scheduler
    pause
    if exist C:\"Program Files (x86)"\SystemScheduler\Events set exist_Scheduler=1
    if exist C:\"Program Files"\SystemScheduler\Events set exist_Scheduler=1
    if %exist_Scheduler%==0 (
        echo Please finish installing System Scheduler
        pause
        goto :Scheduler
    )
    echo Configuring Scheduler...
    ::Move ini file to scheduler
    if exist C:\"Program Files"\SystemScheduler\Events copy c:\filewatcher\installer\TimeScheduler\20233110443.ini C:\"Program Files"\SystemScheduler\Events
    if exist C:\"Program Files (x86)"\SystemScheduler\Events copy c:\filewatcher\installer\TimeScheduler\20233110443.ini C:\"Program Files (x86)"\SystemScheduler\Events
    echo Scheduler configured.
    echo Please leave scheduler running. However you can close out of the scheduler window.
    pause
)
::Hiding files that the user will not need
attrib +h c:\filewatcher\Digisend
attrib +h c:\filewatcher\Installer
attrib +h c:\filewatcher\PTISend
attrib +h c:\FileWatcher\Filewatcher.bat
::Deleting files that the user will not need
rmdir /s c:\filewatcher\installer\Configuration
echo ##############################################################################################
echo ##############################################################################################
echo ##########                                                                          ##########
echo ##########                           Installation Complete                          ##########
echo ##########                                                                          ##########
echo ##############################################################################################
echo ##############################################################################################
pause
goto :start
exit

::################################################################################
::################################################################################
::#################                                              #################
::#################             New PTI Installation             #################
::#################                                              #################
::################################################################################
::################################################################################
::-----------------------------------------------------------------------------------------------::  new_Install_PTI
:new_Install_PTI
cls
set install_Check=0
set /p install_Check=Are you sure you want to install new PTI PMSAdapterClients? [y/n]  
if /I %install_Check% NEQ Y (
    echo Going back to the menu.
    goto :Start
)
::Declaring all variables.
set exist_Scheduler=0
set gateways=0
set gateway_Var_One=main
set gateway_Var_Two=annex
set gateway_Var_Three=annex2
set custom_Install=0
::PTI Specific variables
set exist_F2000=0
set exist_PTI=0
set exist_PTI_YN=0
set exist_OLD_F2000=0
set exist_OLD_PTI=0
set exist_PTISend1=0
set exist_PTISend2=0
set exist_PTISend3=0
::-----------------------------------------------------------------------------------------------::  PTI_Check1
:PTI_Check1
::Checking to see there is an existing PTI folder or OLD_PTI
echo Checking to see if this has been run...
if exist C:\F2000 (
    set exist_F2000=1
    echo F2000 found.
) else (
    set exist_F2000=0
    echo No F2000 found.
)
if exist C:\PTI (
    set exist_PTI=1
    echo PTI found.
) else (
    set exist_PTI=0
    echo No PTI found.
)
if exist C:\OLD_F2000 (
    set exist_OLD_F2000=1
    echo OLD_F2000 found.
) else (
    set exist_OLD_F2000=0
    echo No OLD_F2000 found.
)
if exist C:\OLD_PTI (
    set exist_OLD_PTI=1
    echo OLD_PTI found.
) else (
    set exist_OLD_PTI=0
    echo No OLD_PTI found.
)
::Check to see if OLD_PTI has been made. If so restart. If not continue.
if %exist_OLD_F2000%==1 (
    if %exist_F2000%==1 (
        echo This has been run! Please check/rename/remove your PTI folders.
        pause
        goto :PTI_Check1
    )
)
::Checking to see if PTI structure is correct.
echo Checking if PTI structure is correct...
if exist C:\FileWatcher\PTISend\PTISend1.bat (
    set exist_PTISend1=1
) else set exist_PTISend1=0
if exist C:\FileWatcher\PTISend\PTISend2.bat (
    set exist_PTISend2=1
) else set exist_PTISend2=0
if exist C:\FileWatcher\PTISend\PTISend3.bat (
    set exist_PTISend3=1
) else set exist_PTISend3=0
if %exist_PTISend1%==0 (
    echo PTISend1 not found... Please Fix this before you continue.
    pause
    Exit
) else echo PTISend1 found
if %exist_PTISend2%==0 (
    echo PTISend2 not found... Please Fix this before you continue.
    pause
    Exit
) else echo PTISend2 found
if %exist_PTISend3%==0 (
    echo PTISend3 not found... Please Fix this before you continue.
    pause
    Exit
) else echo PTISend3 found
echo All PTISend files found.
::-----------------------------------------------------------------------------------------------::  PTI_Restart
:PTI_Restart
set ERRORLEVEL = 0
::Prompt to see if they are okay with renaming existing PTI folder
if %exist_PTI%==1 set /p exist_PTI_YN=Do you want to rename the existing PTI and the F2000 directories to OLD? [Y/N]  
::Response to the renaming.
if /I %exist_PTI_YN%==Y (
    echo Renaming the existing PTI and F2000 Folders to OLD.
    move PTI OLD_PTI
    move F2000 OLD_F2000
)
if %ERRORLEVEL% GTR 0 (
    echo Something went wrong when renaming the Digi Folder. Please fix before you continue.
    pause
    cd C:\
    move OLD_PTI PTI
    move OLD_F2000 F2000
    goto :PTI_Restart
)
if /I %exist_PTI_YN%==Y (
    goto :PTI_Cond
)
if /I %exist_PTI_YN%==N (
    echo Please rename or move the existing PTI directory.
    pause
    goto :PTI_Check1
)
::If no PTI or OLD_PTI continue.
if %exist_PTI%==0 goto :PTI_Cond
::If the User does not put a valid response restart the script.
echo You entered a non valid response.
pause
goto :PTI_Restart
::-----------------------------------------------------------------------------------------------::  PTI_Cond
:PTI_Cond
::Create Digi Folder
echo Creating new F2000 and PTI folders.
mkdir c:\F2000
mkdir c:\PTI
::-----------------------------------------------------------------------------------------------::  PTI_Custom
:PTI_Custom
SETLOCAL ENABLEDELAYEDEXPANSION
::If PMSAdapter found search folder for json files and report them back here.
set "fileIndex=0"
for %%F in (C:\ProgramData\PMSAdapter\*.json) do (
    set /a "fileIndex+=1"
    for %%A in ("%%F") do (
        set "jsonFile[!fileIndex!]=%%~nA"
    )
)
::List reuested PMSAdapters
FOR /L %%i IN (1,1,%fileIndex%) DO ( 
    if !jsonFile[%%i]! equ config (
        call echo OpenTechPMSAdapter is Installed.
    ) else (
        call echo OpenTechPMSAdapter$!jsonFile[%%i]! is already Installed.
    )
)
ENDLOCAL
::Ask for custom install/Naming of the instances
set /p custom_Install=Would you like a custom install? [Y/N]  
::Responce to the custom install.
if /I %custom_Install%==Y (
    set custom_Install=1
    goto :PTI_Gateways
)
if /I %custom_Install%==N (
    set custom_Install=0
    goto :PTI_Gateways
)
echo You entered a non valid response.
pause
goto :PTI_Custom
::-----------------------------------------------------------------------------------------------::  PTI_Gateways
:PTI_Gateways
::Ask for how many instances.
set /p gateways=How many Gateways do you have?  
::Variable check. If number is too high ask again. If incorrect variable ask again.
if %gateways%==1 goto :PTISend
if %gateways%==2 goto :PTISend
if %gateways%==3 goto :PTISend
if %gateways%>=4 (
    echo You have entered too high of a number...
) else echo You entered an incorrect number...
pause
goto :PTI_Gateways
::-----------------------------------------------------------------------------------------------::  PTISend
:PTISend
::Moving correct PTISend.bat to PTI folder
echo Creating PTISend file.
copy C:\FileWatcher\PTISend\PTISend%gateways%.bat c:\PTI
if %ERRORLEVEL% equ 1 (
    echo Something went wrong when finding/naming the PTISend.bat. Please fix before you continue.
    pause
    cd C:\
    rmdir c:\PTI
    rmdir c:\F2000
    goto :Start
)
cd c:\PTI
rename PTISend%gateways%.bat PTIsend.bat
::Error Check
if %ERRORLEVEL% equ 1 (
    echo Something went wrong when finding/naming the PTISend.bat. Please fix before you continue.
    pause
    cd C:\
    rmdir c:\Digi
    goto :Start
)
::Check for custom install
if %custom_Install%==0 (
    goto :PTI_Custom_Check
)
::Single Gateway install
if %gateways%==1 (
    set /p gateway_Var_One=What is the name of the first Gateway? 
)
::Double Gateway install
if %gateways%==2 (
    set /p gateway_Var_One=What is the name of the first Gateway? 
    set /p gateway_Var_Two=What is the name of the seCond Gateway? 
)
::Triple Gateway install
if %gateways%==3 (
    set /p gateway_Var_One=What is the name of the first Gateway? 
    set /p gateway_Var_Two=What is the name of the seCond Gateway? 
    set /p gateway_Var_Three=What is the name of the Third Gateway? 
)
::-----------------------------------------------------------------------------------------------::  PTI_Custom_Check
:PTI_Custom_Check
set ERRORLEVEL = 0
if exist C:\FileWatcher\Installer\Configuration goto :NonConfigSkip
goto :ConfigSkip
::-----------------------------------------------------------------------------------------------::  NonConfigSkip
:NonConfigSkip
::Install requested gateways
cd c:\filewatcher
if %gateways%==1 (
    cd C:\ProgramData\PMSAdapter
    copy C:\FileWatcher\Installer\Configuration\config.noinstance.1.main.pti.json C:\ProgramData\PMSAdapter
    ren config.noinstance.1.main.pti.json %gateway_Var_One%.json
)
if %gateways%==2 (
    cd C:\ProgramData\PMSAdapter
    copy C:\FileWatcher\Installer\Configuration\config.instance.1.main.pti.json C:\ProgramData\PMSAdapter
    ren config.instance.1.main.pti.json %gateway_Var_One%.json
    copy C:\FileWatcher\Installer\Configuration\config.instance.2.annexes.pti.json C:\ProgramData\PMSAdapter
    ren config.instance.2.annexes.pti.json %gateway_Var_Two%.json
)
if %gateways%==3 (
    cd C:\ProgramData\PMSAdapter
    copy C:\FileWatcher\Installer\Configuration\config.instance.1.main.pti.json C:\ProgramData\PMSAdapter
    ren config.instance.1.main.pti.json %gateway_Var_One%.json
    copy C:\FileWatcher\Installer\Configuration\config.instance.2.annexes.pti.json C:\ProgramData\PMSAdapter
    ren config.instance.2.annexes.pti.json %gateway_Var_Two%.json
    copy C:\FileWatcher\Installer\Configuration\config.instance.3.annexes.pti.json C:\ProgramData\PMSAdapter
    ren config.instance.2.annexes.pti.json %gateway_Var_Three%.json
)
::-----------------------------------------------------------------------------------------------::  ConfigSkip
:ConfigSkip
::Single Gateway install
cd c:\filewatcher
if %gateways%==1 (
    echo Installing 1/1 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_One%
    pause
)
::For some reason can't have user input and pmsadapterclient install in the same if statement
if %gateways%==2 (
    echo Installing 1/2 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_One%
    pause
    echo Installing 2/2 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_Two%
    pause
)
if %gateways%==3 (
    echo Installing 1/3 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_One%
    pause
    echo Installing 2/3 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_Two%
    pause
    echo Installing 3/3 Gateways...
    pmsadapterclient.exe install -instance:%gateway_Var_Three%
    pause
)
echo FileWatcher setup complete.
::Set recovery setting and startup for services
echo Configuring Services...
if %gateways%==1 (
    sc failure OpenTechPMSAdapter$%gateway_Var_One% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc config OpenTechPMSAdapter$%gateway_Var_One% start=delayed-auto
    sc start OpenTechPMSAdapter$%gateway_Var_One%
)
if %gateways%==2 (
    sc failure OpenTechPMSAdapter$%gateway_Var_One% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc failure OpenTechPMSAdapter$%gateway_Var_Two% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc config OpenTechPMSAdapter$%gateway_Var_One% start=delayed-auto
    sc config OpenTechPMSAdapter$%gateway_Var_Two% start=delayed-auto
    sc start OpenTechPMSAdapter$%gateway_Var_One%
    sc start OpenTechPMSAdapter$%gateway_Var_Two%
)
if %gateways%==3 (
    sc failure OpenTechPMSAdapter$%gateway_Var_One% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc failure OpenTechPMSAdapter$%gateway_Var_Two% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc failure OpenTechPMSAdapter$%gateway_Var_Three% reset=0 actions=restart/180000/restart/180000/restart/180000
    sc config OpenTechPMSAdapter$%gateway_Var_One% start=delayed-auto
    sc config OpenTechPMSAdapter$%gateway_Var_Two% start=delayed-auto
    sc config OpenTechPMSAdapter$%gateway_Var_Three% start=delayed-auto
    sc start OpenTechPMSAdapter$%gateway_Var_One%
    sc start OpenTechPMSAdapter$%gateway_Var_two%
    sc start OpenTechPMSAdapter$%gateway_Var_Three%
)
echo Services complete.
::If there are more than 2 gateways we need to run system scheduler
if %gateways% GTR 2 (
    echo There is more than two gateways. In order to complete this install
    echo we need to install system scheduler. We will then need to make a
    echo schedule for each server depending on how many gateways there are.
    pause
    echo Starting the installer...
    start C:\filewatcher\installer\TimeScheduler\TimeScheduler.exe
    echo Please complete the installer before continuing.
    :Scheduler
    pause
    if exist C:\"Program Files (x86)"\SystemScheduler\Events set exist_Scheduler=1
    if exist C:\"Program Files"\SystemScheduler\Events set exist_Scheduler=1
    if %exist_Scheduler%==0 (
        echo Please finish installing System Scheduler
        pause
        goto :Scheduler
    )
    echo Configuring Scheduler...
    if exist C:\"Program Files"\SystemScheduler\Events copy c:\filewatcher\installer\TimeScheduler\20233110443.ini C:\"Program Files"\SystemScheduler\Events
    if exist C:\"Program Files (x86)"\SystemScheduler\Events copy c:\filewatcher\installer\TimeScheduler\20233110443.ini C:\"Program Files (x86)"\SystemScheduler\Events
    echo Scheduler configured.
    echo Please leave scheduler running. However you can close out of the scheduler window.
    pause
)
::Hiding files that the user will not need
attrib +h c:\filewatcher\Digisend
attrib +h c:\filewatcher\Installer
attrib +h c:\filewatcher\PTISend
attrib +h c:\filewatcher\Filewatcher.bat
::Deleting files that the user will not need
rmdir /s c:\filewatcher\installer\Configuration
echo ##############################################################################################
echo ##############################################################################################
echo ##########                                                                          ##########
echo ##########                           Installation Complete                          ##########
echo ##########                                                                          ##########
echo ##############################################################################################
echo ##############################################################################################
pause
goto :start
exit

::################################################################################
::################################################################################
::#################                                              #################
::#################              Start/Stop Service              #################
::#################                                              #################
::################################################################################
::################################################################################
::-----------------------------------------------------------------------------------------------::  stop/start
:stop/start
cls
SETLOCAL ENABLEDELAYEDEXPANSION
::If PMSAdapter found search folder for json files and report them back here.
set "fileIndex=0"
for %%F in (C:\ProgramData\PMSAdapter\*.json) do (
    set /a "fileIndex+=1"
    for %%A in ("%%F") do (
        set "jsonFile[!fileIndex!]=%%~nA"
    )
)
FOR /L %%i IN (1,1,%fileIndex%) DO (
    if !jsonFile[%%i]! equ config (
        echo Do you want to Start/Stop OpenTechPMSAdapter? [y/n]
        call set /p %%JsonFile[%%i].service=
    ) else (
        echo Do you want to Start/Stop OpenTechPMSAdapter$!jsonFile[%%i]!? [y/n]
        call set /p %%JsonFile[%%i].service=
    )
)

FOR /L %%i IN (1,1,%fileIndex%) DO ( 
    if /I !JsonFile[%%i].service! equ y (
        if /I !JsonFile[%%i]! neq config (
            call sc start OpenTechPMSAdapter$!jsonFile[%%i]!
            set %%JsonFile[%%i].log=!JsonFile[%%i]! has been started.
            if ERRORLEVEL 1056 (
                call sc stop OpenTechPMSAdapter$!jsonFile[%%i]!
                call set %%JsonFile[%%i].log=!JsonFile[%%i]! has been stopped.
            )
        )
        if /I !JsonFile[%%i]! equ config (
            call sc start OpenTechPMSAdapter
            set %%JsonFile[%%i].log=OpenTechPMSAdapter has been started.
            if ERRORLEVEL 1056 (
                call sc stop OpenTechPMSAdapter
                call set %%JsonFile[%%i].log=OpenTechPMSAdapter has been stopped.
            )
        )
    )
)

FOR /L %%i IN (1,1,%fileIndex%) DO ( 
    call sc query OpenTechPMSAdapter$!JsonFile[%%i]! > nul
    IF !JsonFile[%%i]! equ config (
        IF ERRORLEVEL 1060 (
            call echo OpenTechPMSAdapter is not installed properly.
            call set %%JsonFile[%%i].log=OpenTechPMSAdapter is not installed.
            set ERRORLEVEL = 0
        )
    )
    IF !JsonFile[%%i]! NEQ config (
        IF ERRORLEVEL 1060 (
            call echo OpenTechPMSAdapter is not installed properly.
            call set %%JsonFile[%%i].log=!JsonFile[%%i]! is not installed.
            set ERRORLEVEL = 0
        )
    )
)

FOR /L %%i IN (1,1,%fileIndex%) DO ( 
    if /I !JsonFile[%%i].service! equ y (
        echo !JsonFile[%%i].log!
    )
)

ENDLOCAL
set /p serviceMore=Would you like to Start/Stop again? [y/n]  
if /I %serviceMore%==Y (
    goto :stop/start
)
if /I %serviceMore%==N (
    goto :start
)
echo you entered an invalid response. Going back.
pause
goto :start
exit

::################################################################################
::################################################################################
::#################                                              #################
::#################           List PMSAdapterClients             #################
::#################                                              #################
::################################################################################
::################################################################################
::-----------------------------------------------------------------------------------------------::  List
:list
cls
echo -------------------------------
call sc query OpenTechPMSAdapter > nul
cd c:/Filewatcher
::Check array if installed then prompt user for config
SETLOCAL ENABLEDELAYEDEXPANSION
::If PMSAdapter found search folder for json files and report them back here.
set "fileIndex=0"
for %%F in (C:\ProgramData\PMSAdapter\*.json) do (
    set /a "fileIndex+=1"
    for %%A in ("%%F") do (
        set "jsonFile[!fileIndex!]=%%~nA"
    )
)
::List reuested PMSAdapters
FOR /L %%i IN (1,1,%fileIndex%) DO ( 
    if !jsonFile[%%i]! equ config (
        call echo OpenTechPMSAdapter is Installed.
    ) else (
        call echo OpenTechPMSAdapter$!jsonFile[%%i]! is Installed.
    )
)
ENDLOCAL
echo -------------------------------
set /p listMore=Would you like to list again? [y/n]  
if /I %listMore%==Y (
    goto :list
)
if /I %listMore%==N (
    goto :start
)
echo you entered an invalid response. Going back.
pause
goto :start
exit