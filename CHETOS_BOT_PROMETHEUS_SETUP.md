# ðŸš€ CHETOS LB Premium Bot - Prometheus Obfuscator Integration

## ðŸ“‹ What's Been Added

Your Discord bot now has **enterprise-grade Lua obfuscation** powered by the Prometheus Obfuscator API! Here's what's new:

### âœ¨ **New Features Added:**

1. **ðŸ”§ Prometheus API Integration**
   - Automatic fallback to built-in obfuscation if API is offline
   - Configurable API URL for easy deployment
   - Multiple obfuscation presets (Weak, Medium, Strong, Minify)

2. **ðŸŽ® New Discord Commands:**
   - `/prometheus-status` - Check API status and configuration
   - `/prometheus-presets` - View available obfuscation levels
   - `/prometheus-test` - [ADMIN] Test API with sample code

3. **âš™ï¸ Enhanced Configuration:**
   - Easy API URL placeholder for hosting
   - Toggle between API and built-in obfuscation
   - Configurable default obfuscation preset

## ðŸ”§ Setup Instructions

### Step 1: Deploy the Prometheus API

**Option A: Local Development**
```bash
# Extract the prometheus-obfuscator-api.zip
cd prometheus-obfuscator-api
npm install
npm run build
npm run start:api
# API will run on http://localhost:3000
```

**Option B: VPS/Server Deployment**
```bash
# Upload files to your server
scp prometheus-obfuscator-api.zip user@your-server:/path/to/deployment/
ssh user@your-server
cd /path/to/deployment/
unzip prometheus-obfuscator-api.zip
cd prometheus-obfuscator-api
npm install
npm run build

# Start with PM2 (recommended)
npm install -g pm2
pm2 start api.js --name "prometheus-api"
pm2 startup
pm2 save
```

**Option C: Docker Deployment**
```bash
# Upload docker-compose.yml to your server
docker-compose up -d prometheus-api
```

### Step 2: Update Your Bot Configuration

In your `botpython.lua` file, find this section and update it:

```python
# ============================================================================
# PROMETHEUS OBFUSCATOR API CONFIGURATION
# ============================================================================
# ðŸš€ PLACEHOLDER: Replace with your hosted API URL when deployed
PROMETHEUS_API_URL = "http://localhost:3000"  # ðŸ”§ CHANGE THIS TO YOUR HOSTED URL
PROMETHEUS_API_ENABLED = True  # Set to False to use built-in obfuscation
PROMETHEUS_DEFAULT_PRESET = "Strong"  # Weak, Medium, Strong, Minify
```

**Examples of API URLs:**
- **Local development:** `"http://localhost:3000"`
- **VPS/Server:** `"http://your-server-ip:3000"`
- **Domain:** `"https://api.yourdomain.com"`
- **Heroku:** `"https://your-app-name.herokuapp.com"`
- **Railway:** `"https://your-app-name.up.railway.app"`
- **DigitalOcean:** `"https://your-droplet-ip:3000"`

### Step 3: Test the Integration

1. **Start your bot** with the updated configuration
2. **Use `/prometheus-status`** to check if the API is reachable
3. **Use `/prometheus-test`** (admin only) to test obfuscation
4. **Generate a script** to see the enhanced obfuscation in action

## ðŸŽ¯ How It Works

### **Automatic Obfuscation Enhancement:**
1. When users generate scripts with `/generate-growagarden`
2. The bot first tries to use the Prometheus API
3. If API is available: Uses professional-grade obfuscation
4. If API is offline: Falls back to built-in obfuscation
5. Users get the best possible obfuscation automatically

### **Obfuscation Levels:**
- **Minify**: Basic compression (~1x size)
- **Weak**: Light obfuscation (~8x size)
- **Medium**: String encryption + VM (~57x size)
- **Strong**: Multiple VM layers (~101x size)

## ðŸ“Š New Commands for Users

### `/prometheus-status`
- Shows API connection status
- Displays current configuration
- Available to all users

### `/prometheus-presets`
- Lists all available obfuscation presets
- Shows security levels and performance info
- Available to all users

### `/prometheus-test` (Admin Only)
- Tests API with sample Lua code
- Shows obfuscation statistics
- Helps troubleshoot API issues

## ðŸ› ï¸ Configuration Options

### Enable/Disable API
```python
PROMETHEUS_API_ENABLED = True   # Use Prometheus API
PROMETHEUS_API_ENABLED = False  # Use built-in obfuscation only
```

### Change Default Preset
```python
PROMETHEUS_DEFAULT_PRESET = "Strong"  # Maximum security
PROMETHEUS_DEFAULT_PRESET = "Medium"  # Balanced
PROMETHEUS_DEFAULT_PRESET = "Weak"    # Fast processing
```

### Update API URL
```python
PROMETHEUS_API_URL = "https://your-api-server.com"
```

## ðŸš¨ Troubleshooting

### API Not Connecting
1. Check if the API server is running
2. Verify the `PROMETHEUS_API_URL` is correct
3. Test with `/prometheus-status` command
4. Check firewall settings on your server

### Obfuscation Failing
1. Use `/prometheus-test` to diagnose issues
2. Check API server logs
3. Verify the API has enough resources
4. Bot will automatically fall back to built-in obfuscation

### Performance Issues
1. Consider using "Medium" instead of "Strong" preset
2. Monitor API server resources
3. Use built-in obfuscation for high-volume periods

## ðŸŽ‰ Benefits for Your Users

### **Enhanced Security:**
- Professional-grade obfuscation
- Multiple security levels
- Enterprise-level protection

### **Better Performance:**
- Optimized obfuscation algorithms
- Faster processing for complex scripts
- Automatic fallback ensures reliability

### **Improved User Experience:**
- Transparent integration
- No changes to existing commands
- Better obfuscated script quality

## ðŸ“ˆ Deployment Examples

### **Free Hosting (Railway):**
1. Push prometheus-obfuscator-api to GitHub
2. Connect Railway to your repository
3. Deploy automatically
4. Update `PROMETHEUS_API_URL` to Railway URL

### **VPS Deployment:**
1. Upload files to your VPS
2. Install Node.js and npm
3. Run setup commands
4. Use PM2 for process management
5. Update bot configuration

### **Docker Deployment:**
1. Upload docker-compose.yml
2. Run `docker-compose up -d`
3. API runs in container
4. Easy scaling and management

## ðŸŽ¯ Next Steps

1. **Deploy the API** using your preferred method
2. **Update the configuration** with your API URL
3. **Test the integration** with the new commands
4. **Monitor performance** and adjust presets as needed
5. **Enjoy enhanced obfuscation** for your users!

---

**Your CHETOS LB Premium Bot now has enterprise-grade Lua obfuscation! ðŸš€**
