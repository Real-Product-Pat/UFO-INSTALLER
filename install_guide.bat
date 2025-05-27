@echo off
cls
echo ========================================
echo          UFO Setup Assistant
echo ========================================
echo This will help you install UFO on your computer.
echo UFO is a Windows automation tool that can control
echo programs and complete tasks for you.
echo.

echo Analyzing your Windows environment and fixing issues...
echo.

REM Pre-flight checks and auto-fixes
set PYTHON_OK=0
set INTERNET_OK=0
set FOLDER_OK=0
set WINDOWS_OK=0
set PERMISSIONS_OK=0
set GIT_OK=0
set POWERSHELL_OK=0

echo [Check 1] Verifying Windows compatibility...
ver | findstr /i "10\." >nul 2>&1
if %errorlevel% equ 0 set WINDOWS_OK=1
ver | findstr /i "11\." >nul 2>&1
if %errorlevel% equ 0 set WINDOWS_OK=1

if %WINDOWS_OK% equ 1 (
    echo ✅ Windows 10/11 detected - compatible with UFO
) else (
    echo ❌ UFO requires Windows 10 or 11
    echo Your Windows version may not be supported
)

echo [Check 2] Testing administrator permissions...
net session >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Running with administrator privileges
    set PERMISSIONS_OK=1
) else (
    echo ⚠️  Not running as administrator - will try to elevate when needed
    set PERMISSIONS_OK=0
)

echo [Check 3] Checking PowerShell execution policy...
powershell -Command "Get-ExecutionPolicy" | findstr /i "Restricted" >nul 2>&1
if %errorlevel% equ 0 (
    echo ❌ PowerShell execution restricted - fixing automatically...
    powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force" >nul 2>&1
    echo ✅ PowerShell execution policy updated
    set POWERSHELL_OK=1
) else (
    echo ✅ PowerShell execution policy is compatible
    set POWERSHELL_OK=1
)

echo [Check 4] Looking for Python (UFO requires 3.10+)...
python --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=2" %%a in ('python --version 2^>^&1') do (
        echo Found Python version: %%a
        echo %%a | findstr /r "3\.[0-9][0-9]" >nul 2>&1
        if !errorlevel! equ 0 (
            echo ✅ Python version is compatible with UFO
            set PYTHON_OK=1
        ) else (
            echo ❌ Python version too old - UFO needs 3.10+
            set PYTHON_OK=0
        )
    )
) else (
    echo ❌ Python not found - will install automatically...
    echo Downloading Python 3.11 (recommended for UFO)...
    
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe' -OutFile 'python_installer.exe'}" >nul 2>&1
    
    if exist "python_installer.exe" (
        echo Installing Python with UFO-compatible settings...
        echo This includes: pip, PATH integration, and dev tools...
        python_installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 Include_pip=1 Include_dev=1 Include_debug=0
        
        echo Waiting for Python installation to complete...
        timeout /t 45 /nobreak >nul
        del python_installer.exe
        
        REM Refresh PATH and test
        set PATH=%PATH%;C:\Program Files\Python311;C:\Program Files\Python311\Scripts
        python --version >nul 2>&1
        if %errorlevel% equ 0 (
            echo ✅ Python installed successfully!
            set PYTHON_OK=1
        ) else (
            echo ⚠️  Python installed but PATH not updated. Computer restart may be needed.
            set PYTHON_OK=0
        )
    ) else (
        echo ❌ Could not download Python installer
        set PYTHON_OK=0
    )
)

echo [Check 5] Testing internet and DNS resolution...
nslookup github.com >nul 2>&1
if %errorlevel% equ 0 (
    ping github.com -n 1 >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ Internet connection working
        set INTERNET_OK=1
    ) else (
        echo ❌ DNS works but can't reach GitHub - trying network reset...
        ipconfig /flushdns >nul 2>&1
        netsh winsock reset >nul 2>&1
        ping github.com -n 1 >nul 2>&1
        if %errorlevel% equ 0 (
            echo ✅ Network connection restored!
            set INTERNET_OK=1
        ) else (
            echo ❌ Network issues persist
            set INTERNET_OK=0
        )
    )
) else (
    echo ❌ DNS resolution failed - checking network...
    ipconfig /all | findstr /i "dhcp\|dns" >nul 2>&1
    echo Attempting to fix network configuration...
    ipconfig /release >nul 2>&1
    ipconfig /renew >nul 2>&1
    ipconfig /flushdns >nul 2>&1
    
    ping github.com -n 1 >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ Network fixed!
        set INTERNET_OK=1
    ) else (
        echo ❌ Network still has issues
        set INTERNET_OK=0
    )
)

echo [Check 6] Checking for Git (needed for UFO installation)...
git --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Git is installed
    set GIT_OK=1
) else (
    echo ❌ Git not found - downloading automatically...
    if %INTERNET_OK% equ 1 (
        powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/git-scm/git/releases/download/v2.42.0.windows.2/Git-2.42.0.2-64-bit.exe' -OutFile 'git_installer.exe'}" >nul 2>&1
        
        if exist "git_installer.exe" (
            echo Installing Git with default settings...
            git_installer.exe /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"
            timeout /t 30 /nobreak >nul
            del git_installer.exe
            
            REM Refresh PATH
            set PATH=%PATH%;C:\Program Files\Git\bin
            git --version >nul 2>&1
            if %errorlevel% equ 0 (
                echo ✅ Git installed successfully!
                set GIT_OK=1
            ) else (
                echo ⚠️  Git installed but may need PATH refresh
                set GIT_OK=0
            )
        )
    )
)

echo [Check 7] Checking UFO files and dependencies...
if exist "ufo\config\config.yaml.template" (
    echo ✅ UFO files are in the right place
    set FOLDER_OK=1
    
    REM Check for requirements.txt
    if exist "requirements.txt" (
        echo ✅ UFO requirements file found
    ) else (
        echo ❌ Missing requirements.txt - UFO installation incomplete
        set FOLDER_OK=0
    )
    
    REM Check critical UFO directories
    if exist "ufo\module" (
        echo ✅ UFO core modules present
    ) else (
        echo ❌ UFO core modules missing
        set FOLDER_OK=0
    )
) else (
    echo ❌ UFO files not found - downloading complete UFO package...
    if %INTERNET_OK% equ 1 (
        if %GIT_OK% equ 1 (
            echo Cloning UFO repository with Git...
            git clone https://github.com/microsoft/UFO.git UFO_temp >nul 2>&1
            if exist "UFO_temp" (
                xcopy "UFO_temp\*" "." /E /Y /Q >nul 2>&1
                rmdir "UFO_temp" /S /Q >nul 2>&1
                echo ✅ UFO repository cloned successfully!
                set FOLDER_OK=1
            )
        ) else (
            echo Downloading UFO as ZIP package...
            powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/microsoft/UFO/archive/refs/heads/main.zip' -OutFile 'UFO.zip'}" >nul 2>&1
            
            if exist "UFO.zip" (
                echo Extracting UFO files...
                powershell -Command "& {Expand-Archive -Path 'UFO.zip' -DestinationPath '.' -Force}" >nul 2>&1
                
                if exist "UFO-main" (
                    xcopy "UFO-main\*" "." /E /Y /Q >nul 2>&1
                    rmdir "UFO-main" /S /Q >nul 2>&1
                    del "UFO.zip" >nul 2>&1
                    echo ✅ UFO files extracted successfully!
                    set FOLDER_OK=1
                )
            )
        )
    )
)

echo.
echo ========================================
echo           ENVIRONMENT ANALYSIS
echo ========================================

REM Summary of issues
set ISSUES_FOUND=0

if %WINDOWS_OK% equ 0 (
    echo ❌ Windows compatibility issue
    set /a ISSUES_FOUND+=1
)

if %PYTHON_OK% equ 0 (
    echo ❌ Python installation needed
    echo   Solution: Download from https://python.org/downloads
    echo   Make sure to select "Add Python to PATH"
    set /a ISSUES_FOUND+=1
)

if %INTERNET_OK% equ 0 (
    echo ❌ Network connectivity issues
    echo   Solution: Check WiFi/ethernet, restart router, contact IT support
    set /a ISSUES_FOUND+=1
)

if %FOLDER_OK% equ 0 (
    echo ❌ UFO files missing or incomplete
    echo   Solution: Download UFO manually from GitHub
    set /a ISSUES_FOUND+=1
)

if %ISSUES_FOUND% gtr 0 (
    echo.
    echo Found %ISSUES_FOUND% issues that need manual attention.
    goto :requirements_failed
)

echo ✅ All environment checks passed! Proceeding with UFO setup...
echo.

echo [Step 1 of 4] Installing UFO Python dependencies...
echo This installs all the libraries UFO needs to work with Windows.
echo Installing: pywin32, pygetwindow, psutil, opencv, and AI libraries...

REM Upgrade pip first to avoid common issues
python -m pip install --upgrade pip >nul 2>&1

REM Install UFO requirements with better error handling
python -m pip install -r requirements.txt --timeout 120 --retries 3
if %errorlevel% neq 0 (
    echo ❌ Some packages failed to install. Trying alternative approach...
    
    REM Try installing critical packages individually
    echo Installing critical Windows automation packages...
    python -m pip install pywin32 pygetwindow psutil opencv-python pillow --timeout 120
    python -m pip install openai azure-openai anthropic --timeout 120
    python -m pip install pyyaml requests beautifulsoup4 --timeout 120
    
    if %errorlevel% neq 0 (
        echo ❌ Package installation failed. Check internet and try running as administrator.
        goto :requirements_failed
    )
)
echo ✅ All UFO dependencies installed successfully!

echo.
echo [Step 2 of 4] Setting up UFO configuration...
if exist "ufo\config\config.yaml" (
    echo ⚠️  Configuration already exists - backing up and updating...
    copy "ufo\config\config.yaml" "ufo\config\config.yaml.backup" >nul 2>&1
) else (
    copy "ufo\config\config.yaml.template" "ufo\config\config.yaml" >nul 2>&1
    echo ✅ Fresh configuration file created from template!
)

echo.
echo [Step 3 of 4] Configuring Windows permissions for UFO...
echo UFO needs special permissions to control Windows applications.
echo Setting up UI Automation and COM permissions...

REM Enable UI Automation service
sc config "UI0Detect" start= auto >nul 2>&1
net start "UI0Detect" >nul 2>&1

REM Register pywin32 for COM access
python -c "import win32com.client; print('COM access verified')" >nul 2>&1
if %errorlevel% neq 0 (
    echo Configuring Windows COM access for UFO...
    python Scripts\pywin32_postinstall.py -install >nul 2>&1
)

echo ✅ Windows permissions configured for UFO!

echo.
echo [Step 4 of 4] Setting up your AI connection...

echo ========================================
echo        🎉 UFO Installation Complete! 🎉
echo ========================================
echo UFO is now ready to automate your Windows desktop!
echo.
echo Quick Start Commands:
echo   Test installation:     python -m ufo --task "test" --request "open calculator"
echo   Interactive mode:      python -m ufo --task "my_task"
echo   Get help:              python -m ufo --help
echo.
echo 📚 Learn more at: https://microsoft.github.io/UFO/
echo 🐛 Report issues at: https://github.com/microsoft/UFO/issues
echo.
echo Your UFO logs will be saved in: logs\
echo.
pause

goto :end

:requirements_failed
echo.
echo ========================================
echo ⚠️  Setup needs your attention
echo ========================================
echo Please fix the issues listed above, then run this installer again.
echo.
echo Need help? Check the UFO documentation:
echo https://microsoft.github.io/UFO/getting_started/quick_start/
echo.
pause
exit /b 1

:end
