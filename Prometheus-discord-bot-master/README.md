# ðŸš€ Prometheus Obfuscator API

Transform your Discord bot into a powerful Lua obfuscation service! This package converts the Prometheus Discord bot into a REST API that any Python bot can use.

## âœ¨ Features

- ðŸ”§ **4 Obfuscation Levels**: Minify, Weak, Medium, Strong
- ðŸŒ **REST API**: Easy HTTP integration
- ðŸ **Python Client**: Ready-to-use Discord bot integration
- ðŸ³ **Docker Support**: One-command deployment
- ðŸ“ **File Upload**: Support for .lua file uploads
- ðŸ’¬ **Direct Input**: Send code directly via API
- ðŸ›¡ï¸ **Security**: 40KB file size limit, input validation

## ðŸŽ¯ Quick Start

### 1. Start the API Server

**Option A: Node.js**
```bash
npm run setup    # Install dependencies and build
npm run start:api
```

**Option B: Docker (Recommended)**
```bash
docker-compose up prometheus-api
```

**Option C: One-click scripts**
```bash
# Windows
start_api.bat

# Linux/Mac
./start_api.sh
```

### 2. Add to Your Discord Bot

```bash
pip install -r requirements.txt
```

Copy the code from `bot_integration_simple.py` into your Discord bot:

```python
# Add these commands to your bot
@bot.command()
async def obfuscate(ctx, preset="Medium"):
    # Full implementation in bot_integration_simple.py
    pass

@bot.command()
async def presets(ctx):
    # Show available obfuscation presets
    pass
```

### 3. Test It!

- Upload a .lua file and use `!obfuscate Medium`
- Check status with `!obf_status`
- See presets with `!presets`

## ðŸ“¡ API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Check API status |
| GET | `/presets` | Get available presets |
| POST | `/obfuscate` | Upload .lua file |
| POST | `/obfuscate-text` | Send code directly |

### Example Usage

```bash
# Health check
curl http://localhost:3000/health

# Obfuscate code
curl -X POST http://localhost:3000/obfuscate-text \
  -H "Content-Type: application/json" \
  -d '{"code":"print(\"Hello\")", "preset":"Medium"}'
```

## ðŸ”§ Obfuscation Presets

| Preset | Description | Use Case |
|--------|-------------|----------|
| **Minify** | Basic minification | Reduce file size |
| **Weak** | Light obfuscation | Basic protection |
| **Medium** | String encryption + VM | Moderate security |
| **Strong** | Multiple VM layers | Maximum protection |

## ðŸ“ Files Included

```
ðŸ“¦ prometheus-obfuscator-api/
â”œâ”€â”€ ðŸš€ Quick Setup
â”‚   â”œâ”€â”€ start_api.bat/sh           # One-click startup
â”‚   â”œâ”€â”€ docker-compose.yml         # Docker deployment
â”‚   â””â”€â”€ SETUP_GUIDE.md            # Detailed instructions
â”œâ”€â”€ ðŸŒ API Server
â”‚   â”œâ”€â”€ src/api.ts                # Main API server
â”‚   â”œâ”€â”€ src/obfuscate.ts          # Obfuscation logic
â”‚   â””â”€â”€ package.json              # Dependencies
â”œâ”€â”€ ðŸ Python Integration
â”‚   â”œâ”€â”€ bot_integration_simple.py # Copy into your bot
â”‚   â”œâ”€â”€ discord_bot_integration.py # Complete example
â”‚   â”œâ”€â”€ python_client_example.py  # Client library
â”‚   â””â”€â”€ requirements.txt          # Python dependencies
â”œâ”€â”€ ðŸ§ª Testing
â”‚   â”œâ”€â”€ test_obfuscation_direct.py # Test core functionality
â”‚   â”œâ”€â”€ test_api_curl.bat         # API testing
â”‚   â””â”€â”€ test_summary.md           # Test results
â””â”€â”€ ðŸ“š Documentation
    â”œâ”€â”€ README.md                 # This file
    â”œâ”€â”€ API_README.md             # API documentation
    â””â”€â”€ SETUP_GUIDE.md            # Setup instructions
```

## ðŸ³ Docker Deployment

```bash
# Start API only
docker-compose up prometheus-api

# Start with Discord bot
docker-compose --profile discord up

# Background mode
docker-compose up -d prometheus-api
```

## ðŸŒ Production Deployment

### VPS/Server
```bash
# Install Node.js 16+
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# Deploy
git clone <your-repo>
cd prometheus-obfuscator-api
npm run setup
npm run start:api

# Use PM2 for production
npm install -g pm2
pm2 start api.js --name "prometheus-api"
pm2 startup
pm2 save
```

### Cloud Platforms
- **Heroku**: Use included `Dockerfile`
- **Railway**: Direct GitHub deployment
- **DigitalOcean**: Docker deployment
- **AWS/GCP**: Container services

## ðŸ”§ Configuration

### Environment Variables
```env
API_PORT=3000                    # API server port
DISCORD_TOKEN=your_token_here    # For Discord bot mode
```

### API Settings
- **Port**: 3000 (configurable)
- **File limit**: 40KB
- **Timeout**: 30 seconds
- **CORS**: Enabled

## ðŸ§ª Testing

### Test Core Functionality
```bash
python test_obfuscation_direct.py
```

### Test API Server
```bash
npm run test
# or
test_api_curl.bat
```

### Test Discord Integration
1. Start API server
2. Add commands to your bot
3. Upload a .lua file with `!obfuscate`

## ðŸš¨ Troubleshooting

### API Won't Start
- âœ… Check Node.js version (16+)
- âœ… Run `npm install`
- âœ… Check port 3000 availability
- âœ… Check firewall settings

### Bot Can't Connect
- âœ… Verify API is running: `curl http://localhost:3000/health`
- âœ… Check API URL in bot code
- âœ… Install Python dependencies: `pip install -r requirements.txt`

### Docker Issues
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up
```

## ðŸ“Š Performance

- **Weak preset**: ~8x size increase, fast processing
- **Medium preset**: ~57x size increase, moderate processing
- **Strong preset**: ~101x size increase, slower processing
- **File limit**: 40KB (configurable)
- **Concurrent requests**: Supported

## ðŸ”’ Security Features

- Input validation and sanitization
- File size limits
- Timeout protection
- Error handling
- CORS configuration

## ðŸ“ž Support

1. Check `SETUP_GUIDE.md` for detailed instructions
2. Review `test_summary.md` for test results
3. Use `!obf_status` command to check API connectivity
4. Check logs: `docker-compose logs prometheus-api`

## ðŸ“„ License

ISC License - See original Prometheus project for details.

---

**ðŸŽ‰ Your Discord bot is now ready to obfuscate Lua files with enterprise-grade security!**

Made with â¤ï¸ for the Discord bot community.
