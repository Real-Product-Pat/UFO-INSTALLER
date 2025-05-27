@echo off
setlocal enabledelayedexpansion
echo.
echo ================================================
echo 🛸 UFO² - The Desktop AgentOS - Quick Installer
echo ================================================
echo.
echo This will automatically install UFO² and its dependencies.
echo Press Ctrl+C to cancel, or any key to continue...
pause >nul

REM Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Running as regular user. Some installations may need admin rights.
    echo    If you see permission errors, re-run as administrator.
    echo.
)

echo [1/5] Checking Python installation...
python --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
    echo ✅ Python !PYTHON_VERSION! is installed
) else (
    echo ❌ Python not found. Installing Python 3.11...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.0/python-3.11.0-amd64.exe' -OutFile 'python_installer.exe'}"
    python_installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    del python_installer.exe
    echo ✅ Python installed! Please restart Command Prompt and run this script again.
    pause
    exit /b 0
)

echo [2/5] Checking Git installation...
git --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Git is installed
) else (
    echo ❌ Git not found. Installing Git...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/git-scm/git/releases/download/v2.42.0.windows.2/Git-2.42.0.2-64-bit.exe' -OutFile 'git_installer.exe'}"
    git_installer.exe /VERYSILENT /NORESTART
    del git_installer.exe
    echo ✅ Git installed!
)

echo [3/5] Cloning UFO repository...
if exist "UFO" (
    echo UFO directory already exists. Updating...
    cd UFO
    git pull
) else (
    git clone https://github.com/microsoft/UFO.git
    cd UFO
)
echo ✅ Repository ready!

echo [4/5] Installing UFO dependencies...
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo ❌ Installation failed. Trying with --user flag...
    python -m pip install --user -r requirements.txt
)
echo ✅ Dependencies installed!

echo [5/5] Setting up configuration...
if not exist "ufo\config\config.yaml" (
    copy "ufo\config\config.yaml.template" "ufo\config\config.yaml"
    echo ✅ Config file created!
) else (
    echo ⚠️  Config file already exists, skipping...
)

echo.
echo ================================================
echo 🎉 UFO² Installation Complete! 
echo ================================================
echo.
echo 📝 Next Steps:
echo    1. Edit your config file: notepad ufo\config\config.yaml
echo    2. Add your OpenAI API key (get one at https://platform.openai.com/api-keys)
echo    3. Test UFO: python -m ufo --task "test" -r "open calculator"
echo.
echo 📚 Documentation: https://microsoft.github.io/UFO/
echo 🐛 Issues: https://github.com/microsoft/UFO/issues
echo.
echo Opening config file for you to add your API key...
notepad ufo\config\config.yaml
echo.
echo Ready to fly! 🛸
pause
