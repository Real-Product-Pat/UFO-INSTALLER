# UFO Setup (3 Steps)

## Step 1: Install Python
- Go to https://python.org/downloads
- Download Python 3.10 or newer
- **IMPORTANT**: Check "Add Python to PATH" when installing

## Step 2: Setup UFO
Open Command Prompt (search "cmd") and copy/paste these lines one at a time:

```
cd Desktop
git clone https://github.com/microsoft/UFO.git
cd UFO
pip install -r requirements.txt
copy ufo\config\config.yaml.template ufo\config\config.yaml
notepad ufo\config\config.yaml
```

## Step 3: Add Your API Key
- Get a free API key from https://platform.openai.com/api-keys
- In the notepad window, replace `YOUR_API_KEY_HERE` with your key
- Save and close notepad

## Done! 
Test it: `python -m ufo --task "open calculator"`
