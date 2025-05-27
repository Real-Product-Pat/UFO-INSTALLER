@echo off
echo Installing UFO...
pip install -r requirements.txt
copy ufo\config\config.yaml.template ufo\config\config.yaml
echo.
echo Setup complete! Now add your API key:
notepad ufo\config\config.yaml
echo.
echo After saving your API key, test with:
echo python -m ufo --task "open calculator"
pause
