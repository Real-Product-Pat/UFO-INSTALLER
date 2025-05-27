# Install Chocolatey if not present
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install Python
choco install -y python --version=3.10.9

# Add Python to PATH (if needed)
$env:Path += ";$([System.Environment]::GetEnvironmentVariable('ProgramFiles'))\Python310\Scripts;$([System.Environment]::GetEnvironmentVariable('ProgramFiles'))\Python310\"

# Install git
choco install -y git

# Clone UFO repo
git clone https://github.com/microsoft/UFO.git C:\UFO

# Install UFO requirements
cd C:\UFO
pip install -r requirements.txt

# Copy your pre-filled config.yaml (assume you SCP it or include in repo)
# Example: copy from a shared folder or download from your Mac
# Copy-Item \\Mac\Home\UFO\config.yaml C:\UFO\ufo\config\config.yaml -Force

# Optionally, run initial Windows setup (disable firewall, etc.)
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Launch UFO in batch/headless mode with a predefined task/request
python -m ufo --task "autostart" --mode normal --request "Set up Windows for UFO automation"
