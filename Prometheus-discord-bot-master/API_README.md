# Prometheus Obfuscator API

This project has been converted from a Discord bot to include an HTTP API server that you can use to obfuscate Lua code from any application, including Python bots.

## Features

- ðŸš€ HTTP REST API for Lua code obfuscation
- ðŸ“ Support for file uploads and direct code input
- ðŸ”§ Multiple obfuscation presets (Weak, Medium, Strong, Minify)
- ðŸ Python client library included
- ðŸ”’ CORS enabled for web applications
- ðŸ“Š Health check endpoint

## Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Build the Project

```bash
npm run build
```

### 3. Start the API Server

```bash
npm run start:api
```

The API server will start on port 3000 by default. You can change this by setting the `API_PORT` environment variable.

### 4. Test the API

```bash
# Health check
curl http://localhost:3000/health

# Get available presets
curl http://localhost:3000/presets
```

## API Endpoints

### GET /health
Check if the API server is running.

**Response:**
```json
{
  "status": "ok",
  "message": "Prometheus Obfuscator API is running"
}
```

### GET /presets
Get available obfuscation presets.

**Response:**
```json
{
  "presets": ["Weak", "Medium", "Strong", "Minify"]
}
```

### POST /obfuscate
Upload a .lua file for obfuscation.

**Request:**
- Content-Type: `multipart/form-data`
- Body:
  - `file`: The .lua file to obfuscate
  - `preset`: (optional) Obfuscation preset (default: "Medium")

**Response:**
```json
{
  "success": true,
  "preset": "Medium",
  "originalFilename": "script.lua",
  "obfuscatedCode": "-- Obfuscated Lua code here"
}
```

### POST /obfuscate-text
Send Lua code directly for obfuscation.

**Request:**
- Content-Type: `application/json`
- Body:
```json
{
  "code": "print('Hello, World!')",
  "preset": "Medium"
}
```

**Response:**
```json
{
  "success": true,
  "preset": "Medium",
  "obfuscatedCode": "-- Obfuscated Lua code here"
}
```

## Obfuscation Presets

- **Minify**: Basic minification without obfuscation
- **Weak**: Light obfuscation with VM and constant arrays
- **Medium**: Moderate obfuscation with string encryption and anti-tamper
- **Strong**: Heavy obfuscation with multiple VM layers and all features

## Python Integration

Use the included Python client to integrate with your Python applications:

```python
from python_client_example import PrometheusObfuscatorClient

# Initialize client
client = PrometheusObfuscatorClient("http://localhost:3000")

# Obfuscate code directly
result = client.obfuscate_code("""
print("Hello, World!")
""", "Medium")

if "error" not in result:
    print(result["obfuscatedCode"])
```

### Discord Bot Integration

Here's how to integrate it into a Discord bot:

```python
import discord
from discord.ext import commands
from python_client_example import PrometheusObfuscatorClient

bot = commands.Bot(command_prefix='!')
obfuscator = PrometheusObfuscatorClient("http://localhost:3000")

@bot.command()
async def obfuscate(ctx, preset="Medium"):
    if not ctx.message.attachments:
        await ctx.send("Please attach a .lua file!")
        return
    
    attachment = ctx.message.attachments[0]
    if not attachment.filename.endswith('.lua'):
        await ctx.send("Please attach a .lua file!")
        return
    
    # Download and obfuscate
    file_content = await attachment.read()
    lua_code = file_content.decode('utf-8')
    
    result = obfuscator.obfuscate_code(lua_code, preset)
    
    if "error" in result:
        await ctx.send(f"âŒ Error: {result['error']}")
    else:
        # Send obfuscated file back
        import io
        obfuscated_file = io.BytesIO(result['obfuscatedCode'].encode('utf-8'))
        await ctx.send(
            f"âœ… Obfuscated with {preset} preset!",
            file=discord.File(obfuscated_file, filename=f"obfuscated_{attachment.filename}")
        )
```

## Configuration

### Environment Variables

- `API_PORT`: Port for the API server (default: 3000)
- `DISCORD_TOKEN`: Discord bot token (only needed for Discord bot mode)

### File Size Limits

- Maximum file size: 40KB
- Only .lua files are accepted

## Running Both Discord Bot and API

You can run both the Discord bot and the API server:

```bash
# Terminal 1: Start Discord bot
npm run dev

# Terminal 2: Start API server
npm run dev:api
```

## Error Handling

The API returns appropriate HTTP status codes:

- `200`: Success
- `400`: Bad request (invalid file, preset, etc.)
- `500`: Internal server error (obfuscation failed)

Error responses include details:
```json
{
  "error": "Error description",
  "details": "Additional error details"
}
```

## Development

### Building

```bash
npm run build
```

### Running in Development Mode

```bash
# Discord bot
npm run dev

# API server
npm run dev:api
```

## License

ISC License - see the original project for details.
