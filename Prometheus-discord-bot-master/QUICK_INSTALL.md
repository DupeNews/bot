# âš¡ Quick Installation Guide

## ðŸš€ For Your Discord Bot (3 Steps)

### Step 1: Start the API Server
```bash
# Extract the zip file first, then:
cd prometheus-obfuscator-api

# Windows
start_api.bat

# Linux/Mac
chmod +x start_api.sh
./start_api.sh

# Or with Docker
docker-compose up prometheus-api
```

### Step 2: Install Python Dependencies
```bash
pip install requests discord.py aiohttp
# or
pip install -r requirements.txt
```

### Step 3: Add to Your Bot
Copy this code into your Discord bot:

```python
import requests
import io
import discord
from discord.ext import commands

class PrometheusObfuscatorClient:
    def __init__(self, base_url="http://localhost:3000"):
        self.base_url = base_url.rstrip('/')
    
    def obfuscate_code(self, lua_code, preset="Medium"):
        try:
            data = {'code': lua_code, 'preset': preset}
            response = requests.post(f"{self.base_url}/obfuscate-text", json=data)
            response.raise_for_status()
            return response.json()
        except:
            return {"error": "API connection failed"}

obfuscator = PrometheusObfuscatorClient()

@bot.command()
async def obfuscate(ctx, preset="Medium"):
    if not ctx.message.attachments:
        await ctx.send("âŒ Please attach a .lua file!")
        return
    
    attachment = ctx.message.attachments[0]
    if not attachment.filename.endswith('.lua'):
        await ctx.send("âŒ Please attach a .lua file!")
        return
    
    if attachment.size > 40000:
        await ctx.send("âŒ File too large! Max 40KB.")
        return
    
    if preset not in ["Weak", "Medium", "Strong", "Minify"]:
        await ctx.send("âŒ Invalid preset! Use: Weak, Medium, Strong, Minify")
        return
    
    try:
        file_content = await attachment.read()
        lua_code = file_content.decode('utf-8')
        
        await ctx.send(f"ðŸ”„ Obfuscating with **{preset}** preset...")
        result = obfuscator.obfuscate_code(lua_code, preset)
        
        if "error" in result:
            await ctx.send(f"âŒ Error: {result['error']}")
        else:
            obfuscated_file = io.BytesIO(result['obfuscatedCode'].encode('utf-8'))
            await ctx.send(
                f"âœ… Obfuscated with **{preset}** preset!",
                file=discord.File(obfuscated_file, f"obfuscated_{attachment.filename}")
            )
    except Exception as e:
        await ctx.send(f"âŒ Error: {str(e)}")

@bot.command()
async def presets(ctx):
    embed = discord.Embed(title="ðŸ”§ Available Presets", color=0x00ff00)
    embed.add_field(name="Minify", value="Basic minification", inline=False)
    embed.add_field(name="Weak", value="Light obfuscation", inline=False)
    embed.add_field(name="Medium", value="Moderate obfuscation", inline=False)
    embed.add_field(name="Strong", value="Heavy obfuscation", inline=False)
    await ctx.send(embed=embed)
```

## âœ… Test Your Setup

1. **Check API**: Visit `http://localhost:3000/health`
2. **Test bot**: Upload a .lua file and use `!obfuscate Medium`
3. **Check presets**: Use `!presets` command

## ðŸŽ¯ That's it!

Your Discord bot now has professional Lua obfuscation capabilities!

**Commands:**
- `!obfuscate [preset]` - Obfuscate uploaded .lua file
- `!presets` - Show available presets

**Need help?** Check `SETUP_GUIDE.md` for detailed instructions.
