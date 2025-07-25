"""
ðŸ”§ Prometheus Obfuscator API Configuration
Easy configuration file for your CHETOS LB Premium Bot

Update these settings when you deploy your Prometheus API server.
"""

# ============================================================================
# PROMETHEUS API CONFIGURATION
# ============================================================================

# ðŸš€ API Server URL - UPDATE THIS WHEN YOU DEPLOY YOUR API
# Examples:
# - Local development: "http://localhost:3000"
# - VPS/Server: "http://your-server-ip:3000" 
# - Domain: "https://api.yourdomain.com"
# - Heroku: "https://your-app-name.herokuapp.com"
# - Railway: "https://your-app-name.up.railway.app"
# - DigitalOcean: "https://your-droplet-ip:3000"
PROMETHEUS_API_URL = "http://localhost:3000"  # ðŸ”§ CHANGE THIS

# Enable/Disable Prometheus API
# True = Use Prometheus API (recommended)
# False = Use built-in obfuscation only
PROMETHEUS_API_ENABLED = True

# Default obfuscation preset for all scripts
# Options: "Minify", "Weak", "Medium", "Strong"
# - Minify: Basic compression (~1x size, very fast)
# - Weak: Light obfuscation (~8x size, fast)
# - Medium: String encryption + VM (~57x size, moderate)
# - Strong: Multiple VM layers (~101x size, slower but maximum security)
PROMETHEUS_DEFAULT_PRESET = "Strong"

# API timeout settings (in seconds)
PROMETHEUS_API_TIMEOUT = 30

# Fallback behavior when API is unavailable
# True = Use built-in obfuscation as fallback
# False = Return error if API is unavailable
PROMETHEUS_FALLBACK_ENABLED = True

# ============================================================================
# DEPLOYMENT QUICK CONFIGS
# ============================================================================

# Uncomment one of these sections for quick deployment setup:

# ðŸ  LOCAL DEVELOPMENT
# PROMETHEUS_API_URL = "http://localhost:3000"
# PROMETHEUS_API_ENABLED = True

# ðŸŒ VPS/SERVER DEPLOYMENT
# PROMETHEUS_API_URL = "http://YOUR_SERVER_IP:3000"  # Replace YOUR_SERVER_IP
# PROMETHEUS_API_ENABLED = True

# â˜ï¸ HEROKU DEPLOYMENT
# PROMETHEUS_API_URL = "https://YOUR_APP_NAME.herokuapp.com"  # Replace YOUR_APP_NAME
# PROMETHEUS_API_ENABLED = True

# ðŸš‚ RAILWAY DEPLOYMENT
# PROMETHEUS_API_URL = "https://YOUR_APP_NAME.up.railway.app"  # Replace YOUR_APP_NAME
# PROMETHEUS_API_ENABLED = True

# ðŸ³ DOCKER DEPLOYMENT
# PROMETHEUS_API_URL = "http://prometheus-api:3000"  # If using docker-compose
# PROMETHEUS_API_ENABLED = True

# ============================================================================
# ADVANCED SETTINGS
# ============================================================================

# Retry settings for API calls
PROMETHEUS_MAX_RETRIES = 3
PROMETHEUS_RETRY_DELAY = 1  # seconds

# Logging settings
PROMETHEUS_LOG_API_CALLS = True
PROMETHEUS_LOG_ERRORS = True

# Performance settings
PROMETHEUS_CACHE_PRESETS = True  # Cache available presets
PROMETHEUS_CACHE_DURATION = 300  # 5 minutes

# ============================================================================
# USAGE INSTRUCTIONS
# ============================================================================

"""
ðŸš€ QUICK SETUP GUIDE:

1. Deploy your Prometheus API server:
   - Extract prometheus-obfuscator-api.zip
   - Run: npm install && npm run build && npm run start:api
   - Or use Docker: docker-compose up prometheus-api

2. Update this file:
   - Change PROMETHEUS_API_URL to your deployed API URL
   - Set PROMETHEUS_API_ENABLED = True
   - Choose your preferred PROMETHEUS_DEFAULT_PRESET

3. Import in your bot:
   - Add: from prometheus_config import *
   - Use the settings in your Config class

4. Test the setup:
   - Use /prometheus-status command in Discord
   - Use /prometheus-test command (admin only)
   - Generate a script to see enhanced obfuscation

ðŸŽ¯ Your bot will automatically use the best available obfuscation!
"""
