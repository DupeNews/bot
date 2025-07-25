# ðŸš€ Complete Setup Guide for Your Discord Bot

## ðŸ“¦ What's Included

This package contains everything you need to add Lua obfuscation to your Discord bot:

- **Prometheus Obfuscator API Server** (Node.js/Express)
- **Python Client Library** for easy integration
- **Complete Discord Bot Example**
- **Docker support** for easy deployment
- **All necessary dependencies and scripts**

## ðŸ”§ Quick Setup (3 Steps)

### Step 1: Start the API Server

**Option A: Using Node.js directly**
```bash
# Install dependencies
npm install

# Build the project
npm run build

# Start the API server
npm run start:api
```

**Option B: Using Docker (Recommended)**
```bash
# Start the API server
docker-compose up prometheus-api
```

**Option C: Using the startup script**
```bash
# Windows
start_api.bat

# Linux/Mac
chmod +x start_api.sh
./start_api.sh
```

### Step 2: Install Python Dependencies
```bash
pip install requests discord.py aiohttp
```

### Step 3: Add to Your Discord Bot
Copy the `PrometheusObfuscatorClient` class to your bot and use it!

## ðŸ Integration with Your Discord Bot

### Method 1: Copy the Client Class

Add this to your bot's code:

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
            response = requests.post(
                f"{self.base_url}/obfuscate-text",
                json=data,
                headers={'Content-Type': 'application/json'}
            )
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            return {"error": str(e)}

# Initialize the obfuscator client
obfuscator = PrometheusObfuscatorClient("http://localhost:3000")

@bot.command()
async def obfuscate(ctx, preset="Medium"):
    """Obfuscate a Lua file - attach a .lua file to your message"""
    
    if not ctx.message.attachments:
        await ctx.send("âŒ Please attach a .lua file!")
        return
    
    attachment = ctx.message.attachments[0]
    if not attachment.filename.endswith('.lua'):
        await ctx.send("âŒ Please attach a .lua file!")
        return
    
    if attachment.size > 40000:  # 40KB limit
        await ctx.send("âŒ File too large! Maximum size is 40KB.")
        return
    
    # Valid presets
    if preset not in ["Weak", "Medium", "Strong", "Minify"]:
        await ctx.send("âŒ Invalid preset! Use: Weak, Medium, Strong, or Minify")
        return
    
    try:
        # Download and obfuscate
        file_content = await attachment.read()
        lua_code = file_content.decode('utf-8')
        
        await ctx.send(f"ðŸ”„ Obfuscating with **{preset}** preset...")
        
        result = obfuscator.obfuscate_code(lua_code, preset)
        
        if "error" in result:
            await ctx.send(f"âŒ Obfuscation failed: {result['error']}")
        else:
            # Send obfuscated file back
            obfuscated_file = io.BytesIO(result['obfuscatedCode'].encode('utf-8'))
            await ctx.send(
                f"âœ… Obfuscated with **{preset}** preset!",
                file=discord.File(obfuscated_file, filename=f"obfuscated_{attachment.filename}")
            )
    except Exception as e:
        await ctx.send(f"âŒ Error: {str(e)}")

@bot.command()
async def presets(ctx):
    """Show available obfuscation presets"""
    embed = discord.Embed(title="ðŸ”§ Available Presets", color=0x00ff00)
    embed.add_field(name="Minify", value="Basic minification", inline=False)
    embed.add_field(name="Weak", value="Light obfuscation", inline=False)
    embed.add_field(name="Medium", value="Moderate obfuscation", inline=False)
    embed.add_field(name="Strong", value="Heavy obfuscation", inline=False)
    await ctx.send(embed=embed)
```

### Method 2: Use the Complete Example

Copy `discord_bot_integration.py` and modify it with your bot token:

```python
# Edit this line in discord_bot_integration.py
BOT_TOKEN = "your_actual_bot_token_here"

# Then run it
python discord_bot_integration.py
```

## ðŸŒ Deployment Options

### Local Development
- API runs on `http://localhost:3000`
- Perfect for testing and development

### VPS/Server Deployment
1. Upload the files to your server
2. Install Node.js and npm
3. Run the setup commands
4. Use a process manager like PM2:
```bash
npm install -g pm2
pm2 start api.js --name "prometheus-api"
```

### Docker Deployment (Recommended)
```bash
# Build and start
docker-compose up -d prometheus-api

# Check status
docker-compose ps

# View logs
docker-compose logs prometheus-api
```

### Cloud Deployment
- **Heroku**: Use the included `Dockerfile`
- **Railway**: Direct deployment from GitHub
- **DigitalOcean**: Use Docker deployment
- **AWS/GCP**: Container deployment

## ðŸ”§ Configuration

### Environment Variables
Create a `.env` file:
```env
API_PORT=3000
DISCORD_TOKEN=your_discord_bot_token_here
```

### API Settings
- **Port**: Default 3000 (change with `API_PORT` env var)
- **File size limit**: 40KB
- **Supported formats**: .lua files only
- **CORS**: Enabled for all origins

## ðŸ§ª Testing Your Setup

### 1. Test API Health
```bash
curl http://localhost:3000/health
```
Should return: `{"status":"ok","message":"Prometheus Obfuscator API is running"}`

### 2. Test Obfuscation
```bash
curl -X POST http://localhost:3000/obfuscate-text \
  -H "Content-Type: application/json" \
  -d '{"code":"print(\"Hello World\")","preset":"Medium"}'
```

### 3. Test Discord Commands
- Upload a .lua file and use `!obfuscate Medium`
- Use `!presets` to see available options

## ðŸ“ File Structure
```
prometheus-obfuscator-api/
â”œâ”€â”€ src/
â”‚   â”œâ”€â”€ api.ts              # Main API server
â”‚   â”œâ”€â”€ obfuscate.ts        # Obfuscation logic
â”‚   â””â”€â”€ logger.ts           # Logging utilities
â”œâ”€â”€ lua/                    # Lua obfuscator scripts
â”œâ”€â”€ bin/                    # Lua runtime
â”œâ”€â”€ python_client_example.py    # Python client
â”œâ”€â”€ discord_bot_integration.py  # Complete Discord bot
â”œâ”€â”€ package.json            # Node.js dependencies
â”œâ”€â”€ docker-compose.yml      # Docker configuration
â”œâ”€â”€ start_api.bat/sh        # Startup scripts
â””â”€â”€ README files and docs
```

## ðŸš¨ Troubleshooting

### API Won't Start
- Check if port 3000 is available
- Install Node.js 16+ and npm
- Run `npm install` first

### Python Import Errors
```bash
pip install requests discord.py aiohttp
```

### Docker Issues
```bash
# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up
```

### Bot Can't Connect to API
- Ensure API is running on correct port
- Check firewall settings
- Verify the API URL in your bot code

## ðŸŽ¯ Next Steps

1. **Start the API server** using one of the methods above
2. **Add the obfuscation commands** to your Discord bot
3. **Test with a simple .lua file**
4. **Deploy to your server** for production use

## ðŸ“ž Support

If you encounter issues:
1. Check the logs: `docker-compose logs prometheus-api`
2. Test the API directly with curl
3. Verify all dependencies are installed
4. Check the troubleshooting section above

**Your Discord bot is now ready to obfuscate Lua files! ðŸŽ‰**
