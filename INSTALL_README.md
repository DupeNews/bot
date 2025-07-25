# ðŸš€ One-Click Installation Guide

## Quick Install (Recommended)

Run this single command to install everything automatically:

```bash
curl -fsSL https://raw.githubusercontent.com/DupeNews/bot/main/install.sh | bash
```

Or download and run manually:

```bash
wget https://raw.githubusercontent.com/DupeNews/bot/main/install.sh
chmod +x install.sh
./install.sh
```

## What the Script Does

âœ… **Automatically installs:**
- Node.js 18+ (if not present)
- Git (if not present)  
- PM2 process manager
- All project dependencies
- Configures firewall (port 3000)
- Sets up systemd service
- Starts the API server

âœ… **Supports:**
- Ubuntu/Debian
- CentOS/RHEL
- macOS (with Homebrew)

## Installation Options

### Standard Installation
```bash
./install.sh
```

### Custom Port
```bash
./install.sh --port 8080
```

### Skip Firewall Configuration
```bash
./install.sh --no-firewall
```

### Skip PM2 Setup
```bash
./install.sh --no-pm2
```

### Test Existing Installation
```bash
./install.sh --test-only
```

### Help
```bash
./install.sh --help
```

## After Installation

### 1. **Verify API is Running**
```bash
curl http://localhost:3000/health
```

### 2. **Check PM2 Status**
```bash
pm2 status
pm2 logs prometheus-api
```

### 3. **Update Your Bot Configuration**
Edit your `prometheus_config.py`:
```python
PROMETHEUS_API_URL = "http://YOUR_SERVER_IP:3000"
PROMETHEUS_API_ENABLED = True
```

### 4. **Test in Discord**
Use these commands in your Discord server:
- `/prometheus-status` - Check API connection
- `/prometheus-test` - Test obfuscation (admin only)

## Management Commands

### PM2 Commands
```bash
pm2 status                    # Check status
pm2 logs prometheus-api       # View logs
pm2 restart prometheus-api    # Restart API
pm2 stop prometheus-api       # Stop API
pm2 delete prometheus-api     # Remove from PM2
```

### Systemd Commands (if enabled)
```bash
sudo systemctl status prometheus-api    # Check status
sudo systemctl restart prometheus-api   # Restart
sudo systemctl stop prometheus-api      # Stop
sudo systemctl start prometheus-api     # Start
```

## API Endpoints

Once installed, your API will be available at:

- **Health Check:** `http://localhost:3000/health`
- **Available Presets:** `http://localhost:3000/presets`
- **Obfuscate Text:** `POST http://localhost:3000/obfuscate-text`
- **Obfuscate File:** `POST http://localhost:3000/obfuscate`

## Troubleshooting

### API Won't Start
```bash
# Check logs
pm2 logs prometheus-api

# Check if port is in use
sudo netstat -tlnp | grep :3000

# Restart the service
pm2 restart prometheus-api
```

### Permission Issues
```bash
# Fix npm permissions
sudo chown -R $(whoami) ~/.npm
sudo chown -R $(whoami) /usr/local/lib/node_modules
```

### Firewall Issues
```bash
# Ubuntu/Debian
sudo ufw allow 3000/tcp

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --reload
```

### Node.js Version Issues
```bash
# Check version
node --version

# Should be 16+ (18+ recommended)
# If not, the script will install the correct version
```

## Manual Installation (Alternative)

If the automatic script doesn't work, you can install manually:

```bash
# 1. Install Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. Clone repository
git clone https://github.com/DupeNews/bot.git
cd bot/Prometheus-discord-bot-master

# 3. Install dependencies
npm install
npm run build

# 4. Install PM2
sudo npm install -g pm2

# 5. Start the API
pm2 start npm --name "prometheus-api" -- run start:api
pm2 save
pm2 startup
```

## Security Notes

- The script can be run as a regular user (recommended)
- If run as root, it will warn you
- Firewall rules are automatically configured
- PM2 runs the process as your user account

## Support

If you encounter issues:

1. Check the installation logs
2. Run `./install.sh --test-only` to test
3. Check PM2 logs: `pm2 logs prometheus-api`
4. Verify Node.js version: `node --version`
5. Test API manually: `curl http://localhost:3000/health`

---

**ðŸŽ‰ Your Prometheus API will be ready in under 2 minutes!**
