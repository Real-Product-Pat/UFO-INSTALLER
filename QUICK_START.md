# 🚀 UFO² Quick Start (60 seconds)

## One-Command Install

Open **Command Prompt** and run:

```powershell
curl -L https://raw.githubusercontent.com/microsoft/UFO/main/quick_install.bat -o quick_install.bat && quick_install.bat
```

That's it! The installer will:
- ✅ Install Python & Git (if needed)
- ✅ Clone UFO repository 
- ✅ Install all dependencies
- ✅ Create config file
- ✅ Open config editor

## Add Your API Key

When the config file opens, replace `YOUR_API_KEY` with your OpenAI key:

```yaml
HOST_AGENT:
  API_KEY: "sk-your-actual-key-here"  # 👈 Replace this
APP_AGENT:  
  API_KEY: "sk-your-actual-key-here"  # 👈 Replace this
```

💡 **Get a free API key**: https://platform.openai.com/api-keys

## Test It Out

```powershell
python -m ufo --task "test" -r "open calculator"
```

## What Next?

- 📖 **Full docs**: https://microsoft.github.io/UFO/
- 🎥 **Examples**: https://www.youtube.com/watch?v=QT_OhygMVXU  
- 🐛 **Issues**: https://github.com/microsoft/UFO/issues

---

**That's it!** You're ready to automate Windows with natural language! 🛸
