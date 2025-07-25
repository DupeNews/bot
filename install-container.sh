#!/bin/bash

# ðŸš€ CHETOS Bot - Prometheus API Container Installer
# This script installs the Prometheus Obfuscator API in container environments
# Compatible with Pterodactyl, Docker containers, and environments without sudo

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/DupeNews/bot.git"
PROJECT_DIR="bot"
API_DIR="Prometheus-discord-bot-master"
API_PORT=3000

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check Node.js
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_success "Node.js is installed: $NODE_VERSION"
    else
        print_error "Node.js is not installed!"
        exit 1
    fi
    
    # Check npm
    if command -v npm &> /dev/null; then
        NPM_VERSION=$(npm --version)
        print_success "npm is installed: $NPM_VERSION"
    else
        print_error "npm is not installed!"
        exit 1
    fi
    
    # Check Git
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version)
        print_success "Git is installed: $GIT_VERSION"
    else
        print_error "Git is not installed!"
        exit 1
    fi
}

# Function to install PM2 locally (without sudo)
install_pm2_local() {
    print_header "Installing PM2 (Local)"
    
    if command -v pm2 &> /dev/null; then
        print_success "PM2 is already installed: $(pm2 --version)"
        return
    fi
    
    print_status "Installing PM2 locally (no sudo required)..."
    npm install -g pm2 --prefix ~/.local
    
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        print_status "Added PM2 to PATH"
    fi
    
    # Verify installation
    if command -v pm2 &> /dev/null || [ -f "$HOME/.local/bin/pm2" ]; then
        print_success "PM2 installed successfully"
    else
        print_warning "PM2 installation may have failed, but we'll continue without it"
        USE_PM2=false
    fi
}

# Function to clone repository
clone_repository() {
    print_header "Cloning Repository"
    
    if [ -d "$PROJECT_DIR" ]; then
        print_warning "Directory $PROJECT_DIR already exists"
        print_status "Removing existing directory..."
        rm -rf "$PROJECT_DIR"
    fi

    print_status "Cloning repository from $REPO_URL..."
    git clone "$REPO_URL" "$PROJECT_DIR"
    
    if [ -d "$PROJECT_DIR" ]; then
        print_success "Repository cloned successfully"
    else
        print_error "Failed to clone repository"
        exit 1
    fi
}

# Function to fix esbuild configuration
fix_esbuild_config() {
    if [ -f "esbuild.js" ]; then
        print_status "Updating esbuild.js for Node.js platform..."

        # Create a backup
        cp esbuild.js esbuild.js.backup

        # Fix the esbuild configuration
        cat > esbuild.js << 'EOF'
const esbuild = require('esbuild');

esbuild.build({
  entryPoints: ['src/index.ts'],
  bundle: true,
  platform: 'node',
  target: 'node16',
  outfile: 'index.js',
  external: ['fs', 'path', 'crypto', 'os', 'util', 'events', 'stream', 'buffer'],
  format: 'cjs',
  sourcemap: false,
  minify: false,
}).catch(() => process.exit(1));
EOF

        print_success "esbuild.js updated for Node.js platform"
    else
        print_warning "esbuild.js not found, skipping configuration fix"
    fi
}

# Function to install dependencies
install_dependencies() {
    print_header "Installing Project Dependencies"

    cd "$PROJECT_DIR/$API_DIR"

    if [ ! -f "package.json" ]; then
        print_error "package.json not found in $API_DIR"
        exit 1
    fi

    print_status "Installing npm dependencies..."
    npm install

    print_status "Installing TypeScript runtime dependencies..."
    npm install ts-node typescript @types/node

    print_status "Fixing esbuild configuration for Node.js..."
    fix_esbuild_config

    print_status "Attempting to build the project..."
    if npm run build 2>/dev/null; then
        print_success "Project built successfully"
        BUILD_SUCCESS=true
    else
        print_warning "Build failed, will use TypeScript runtime instead"
        BUILD_SUCCESS=false
    fi

    print_success "Dependencies installed successfully"
    cd - > /dev/null
}

# Function to start services (container-friendly)
start_services() {
    print_header "Starting Services"

    cd "$PROJECT_DIR/$API_DIR"

    # Determine which start command to use
    if [ "$BUILD_SUCCESS" = true ] && [ -f "index.js" ]; then
        START_CMD="node index.js"
        print_status "Using compiled JavaScript version"
    elif [ -f "src/index.ts" ]; then
        START_CMD="npx ts-node src/index.ts"
        print_status "Using TypeScript runtime version"
    else
        print_error "No valid entry point found!"
        exit 1
    fi

    if command -v pm2 &> /dev/null || [ -f "$HOME/.local/bin/pm2" ]; then
        print_status "Starting API with PM2..."

        # Use full path if needed
        PM2_CMD="pm2"
        if [ -f "$HOME/.local/bin/pm2" ]; then
            PM2_CMD="$HOME/.local/bin/pm2"
        fi

        # Start with the appropriate command
        $PM2_CMD start "$START_CMD" --name "prometheus-api"
        $PM2_CMD save

        print_success "API started with PM2"
    else
        print_status "Starting API in background..."
        nohup $START_CMD > api.log 2>&1 &
        API_PID=$!
        echo $API_PID > api.pid
        print_success "API started in background (PID: $API_PID)"
        print_status "Logs are being written to api.log"
        print_status "Start command: $START_CMD"
    fi

    cd - > /dev/null
}

# Function to test installation
test_installation() {
    print_header "Testing Installation"
    
    print_status "Waiting for API to start..."
    sleep 10
    
    # Test health endpoint
    if curl -s "http://localhost:$API_PORT/health" > /dev/null 2>&1; then
        print_success "API is responding on port $API_PORT"
        
        # Test presets endpoint
        if curl -s "http://localhost:$API_PORT/presets" > /dev/null 2>&1; then
            print_success "API endpoints are working correctly"
        else
            print_warning "Health endpoint works but presets endpoint failed"
        fi
    else
        print_warning "API test failed. It may still be starting up."
        print_status "You can test manually with: curl http://localhost:$API_PORT/health"
        return 1
    fi
}

# Function to display final information
display_final_info() {
    print_header "Installation Complete!"
    
    echo -e "${GREEN}ðŸŽ‰ Prometheus Obfuscator API has been successfully installed!${NC}"
    echo ""
    echo -e "${CYAN}ðŸ“‹ Installation Summary:${NC}"
    echo -e "  â€¢ Repository: $REPO_URL"
    echo -e "  â€¢ Installation Directory: $(pwd)/$PROJECT_DIR/$API_DIR"
    echo -e "  â€¢ API Port: $API_PORT"
    echo -e "  â€¢ Environment: Container (Pterodactyl compatible)"
    echo ""
    echo -e "${CYAN}ðŸ”— API Endpoints:${NC}"
    echo -e "  â€¢ Health Check: http://localhost:$API_PORT/health"
    echo -e "  â€¢ Available Presets: http://localhost:$API_PORT/presets"
    echo -e "  â€¢ Obfuscate Text: http://localhost:$API_PORT/obfuscate-text"
    echo -e "  â€¢ Obfuscate File: http://localhost:$API_PORT/obfuscate"
    echo ""
    echo -e "${CYAN}ðŸ› ï¸ Management Commands:${NC}"
    if command -v pm2 &> /dev/null || [ -f "$HOME/.local/bin/pm2" ]; then
        echo -e "  â€¢ Check Status: pm2 status"
        echo -e "  â€¢ View Logs: pm2 logs prometheus-api"
        echo -e "  â€¢ Restart API: pm2 restart prometheus-api"
        echo -e "  â€¢ Stop API: pm2 stop prometheus-api"
    else
        echo -e "  â€¢ View Logs: tail -f $PROJECT_DIR/$API_DIR/api.log"
        echo -e "  â€¢ Stop API: kill \$(cat $PROJECT_DIR/$API_DIR/api.pid)"
        if [ "$BUILD_SUCCESS" = true ] && [ -f "$PROJECT_DIR/$API_DIR/index.js" ]; then
            echo -e "  â€¢ Start API: cd $PROJECT_DIR/$API_DIR && node index.js"
        else
            echo -e "  â€¢ Start API: cd $PROJECT_DIR/$API_DIR && npx ts-node src/index.ts"
        fi
    fi
    echo ""
    echo -e "${CYAN}âš™ï¸ Configuration:${NC}"
    echo -e "  â€¢ Update your bot's prometheus_config.py file"
    echo -e "  â€¢ Set PROMETHEUS_API_URL = \"http://localhost:$API_PORT\""
    echo -e "  â€¢ Or use your container's external IP/domain"
    echo ""
    echo -e "${YELLOW}ðŸ“ Next Steps:${NC}"
    echo -e "  1. Update your Discord bot configuration"
    echo -e "  2. Test the API with: curl http://localhost:$API_PORT/health"
    echo -e "  3. Use /prometheus-status command in Discord to verify connection"
    echo ""
    echo -e "${GREEN}âœ… Your Prometheus API is now running and ready to use!${NC}"
}

# Main installation function
main() {
    print_header "ðŸš€ CHETOS Bot - Prometheus API Container Installer"
    echo -e "${CYAN}This script will install the Prometheus Obfuscator API${NC}"
    echo -e "${CYAN}Optimized for container environments (Pterodactyl, Docker)${NC}"
    echo -e "${CYAN}Repository: $REPO_URL${NC}"
    echo -e "${CYAN}Installation Directory: $PROJECT_DIR${NC}"
    echo -e "${CYAN}API Port: $API_PORT${NC}"
    echo ""
    
    # Run installation steps
    check_prerequisites
    install_pm2_local
    clone_repository
    install_dependencies
    start_services
    
    # Test the installation
    if test_installation; then
        display_final_info
    else
        print_warning "Installation completed but tests failed. The API may still be starting."
        display_final_info
    fi
}

# Error handling
trap 'print_error "Installation failed at line $LINENO. Check the output above for details."' ERR

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
