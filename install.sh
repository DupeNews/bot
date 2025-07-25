#!/bin/bash

# ðŸš€ CHETOS Bot - Prometheus API Auto-Installer
# This script automatically installs and sets up the Prometheus Obfuscator API
# Compatible with Ubuntu, Debian, CentOS, and most Linux distributions

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
NODE_VERSION="18"

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

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            OS="debian"
            print_status "Detected Debian/Ubuntu system"
        elif [ -f /etc/redhat-release ]; then
            OS="redhat"
            print_status "Detected RedHat/CentOS system"
        else
            OS="linux"
            print_status "Detected generic Linux system"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        print_status "Detected macOS system"
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_warning "Running as root. This is not recommended for security reasons."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Exiting..."
            exit 1
        fi
    fi
}

# Function to install Node.js
install_nodejs() {
    print_header "Installing Node.js $NODE_VERSION"
    
    if command -v node &> /dev/null; then
        NODE_CURRENT=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$NODE_CURRENT" -ge "$NODE_VERSION" ]; then
            print_success "Node.js $NODE_CURRENT is already installed"
            return
        else
            print_warning "Node.js $NODE_CURRENT is installed but version $NODE_VERSION+ is required"
        fi
    fi

    case $OS in
        "debian")
            print_status "Installing Node.js via NodeSource repository..."
            curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        "redhat")
            print_status "Installing Node.js via NodeSource repository..."
            curl -fsSL https://rpm.nodesource.com/setup_${NODE_VERSION}.x | sudo bash -
            sudo yum install -y nodejs
            ;;
        "macos")
            if command -v brew &> /dev/null; then
                print_status "Installing Node.js via Homebrew..."
                brew install node@${NODE_VERSION}
            else
                print_error "Homebrew not found. Please install Node.js manually from https://nodejs.org/"
                exit 1
            fi
            ;;
        *)
            print_error "Please install Node.js $NODE_VERSION+ manually from https://nodejs.org/"
            exit 1
            ;;
    esac

    # Verify installation
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        print_success "Node.js $(node --version) and npm $(npm --version) installed successfully"
    else
        print_error "Node.js installation failed"
        exit 1
    fi
}

# Function to install Git
install_git() {
    print_header "Checking Git Installation"
    
    if command -v git &> /dev/null; then
        print_success "Git is already installed: $(git --version)"
        return
    fi

    print_status "Installing Git..."
    case $OS in
        "debian")
            sudo apt-get update
            sudo apt-get install -y git
            ;;
        "redhat")
            sudo yum install -y git
            ;;
        "macos")
            if command -v brew &> /dev/null; then
                brew install git
            else
                print_error "Please install Git manually"
                exit 1
            fi
            ;;
        *)
            print_error "Please install Git manually"
            exit 1
            ;;
    esac

    print_success "Git installed successfully"
}

# Function to install PM2
install_pm2() {
    print_header "Installing PM2 Process Manager"
    
    if command -v pm2 &> /dev/null; then
        print_success "PM2 is already installed: $(pm2 --version)"
        return
    fi

    print_status "Installing PM2 globally..."
    sudo npm install -g pm2
    
    if command -v pm2 &> /dev/null; then
        print_success "PM2 installed successfully"
    else
        print_error "PM2 installation failed"
        exit 1
    fi
}

# Function to clone repository
clone_repository() {
    print_header "Cloning Repository"

    if [ -d "$PROJECT_DIR" ]; then
        print_warning "Directory $PROJECT_DIR already exists"
        read -p "Remove and re-clone? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$PROJECT_DIR"
        else
            print_status "Using existing directory"
            return
        fi
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

    print_status "Building the project..."
    npm run build

    print_success "Dependencies installed and project built successfully"
    cd - > /dev/null
}

# Function to configure firewall
configure_firewall() {
    print_header "Configuring Firewall"

    if command -v ufw &> /dev/null; then
        print_status "Configuring UFW firewall..."
        sudo ufw allow $API_PORT/tcp
        print_success "UFW firewall configured for port $API_PORT"
    elif command -v firewall-cmd &> /dev/null; then
        print_status "Configuring firewalld..."
        sudo firewall-cmd --permanent --add-port=$API_PORT/tcp
        sudo firewall-cmd --reload
        print_success "Firewalld configured for port $API_PORT"
    else
        print_warning "No supported firewall found. Please manually open port $API_PORT"
    fi
}

# Function to create systemd service
create_systemd_service() {
    print_header "Creating Systemd Service"

    SERVICE_FILE="/etc/systemd/system/prometheus-api.service"
    CURRENT_USER=$(whoami)
    CURRENT_DIR=$(pwd)

    print_status "Creating systemd service file..."

    sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Prometheus Obfuscator API
After=network.target

[Service]
Type=simple
User=$CURRENT_USER
WorkingDirectory=$CURRENT_DIR/$PROJECT_DIR/$API_DIR
ExecStart=/usr/bin/npm run start:api
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=PORT=$API_PORT

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable prometheus-api

    print_success "Systemd service created and enabled"
}

# Function to start services
start_services() {
    print_header "Starting Services"

    # Start with PM2
    cd "$PROJECT_DIR/$API_DIR"

    print_status "Starting API with PM2..."
    pm2 start npm --name "prometheus-api" -- run start:api
    pm2 save

    # Setup PM2 startup
    print_status "Setting up PM2 startup..."
    pm2 startup | grep -E '^sudo' | bash || true

    cd - > /dev/null

    print_success "Services started successfully"
}

# Function to test installation
test_installation() {
    print_header "Testing Installation"

    print_status "Waiting for API to start..."
    sleep 5

    # Test health endpoint
    if curl -s "http://localhost:$API_PORT/health" > /dev/null; then
        print_success "API is responding on port $API_PORT"

        # Test presets endpoint
        if curl -s "http://localhost:$API_PORT/presets" > /dev/null; then
            print_success "API endpoints are working correctly"
        else
            print_warning "Health endpoint works but presets endpoint failed"
        fi
    else
        print_error "API is not responding. Check the logs with: pm2 logs prometheus-api"
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
    echo -e "  â€¢ Process Manager: PM2"
    echo ""
    echo -e "${CYAN}ðŸ”— API Endpoints:${NC}"
    echo -e "  â€¢ Health Check: http://localhost:$API_PORT/health"
    echo -e "  â€¢ Available Presets: http://localhost:$API_PORT/presets"
    echo -e "  â€¢ Obfuscate Text: http://localhost:$API_PORT/obfuscate-text"
    echo -e "  â€¢ Obfuscate File: http://localhost:$API_PORT/obfuscate"
    echo ""
    echo -e "${CYAN}ðŸ› ï¸ Management Commands:${NC}"
    echo -e "  â€¢ Check Status: pm2 status"
    echo -e "  â€¢ View Logs: pm2 logs prometheus-api"
    echo -e "  â€¢ Restart API: pm2 restart prometheus-api"
    echo -e "  â€¢ Stop API: pm2 stop prometheus-api"
    echo ""
    echo -e "${CYAN}âš™ï¸ Configuration:${NC}"
    echo -e "  â€¢ Update your bot's prometheus_config.py file"
    echo -e "  â€¢ Set PROMETHEUS_API_URL = \"http://$(hostname -I | awk '{print $1}'):$API_PORT\""
    echo -e "  â€¢ Or use your server's public IP/domain"
    echo ""
    echo -e "${YELLOW}ðŸ“ Next Steps:${NC}"
    echo -e "  1. Update your Discord bot configuration"
    echo -e "  2. Test the API with: curl http://localhost:$API_PORT/health"
    echo -e "  3. Use /prometheus-status command in Discord to verify connection"
    echo ""
    echo -e "${GREEN}âœ… Your Prometheus API is now running and ready to use!${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -p, --port PORT     Set API port (default: 3000)"
    echo "  -d, --dir DIR       Set installation directory (default: bot)"
    echo "  --no-pm2           Skip PM2 installation and setup"
    echo "  --no-firewall      Skip firewall configuration"
    echo "  --no-systemd       Skip systemd service creation"
    echo "  --test-only        Only run tests (requires existing installation)"
    echo ""
    echo "Examples:"
    echo "  $0                  # Standard installation"
    echo "  $0 -p 8080          # Install with custom port"
    echo "  $0 --no-firewall    # Install without firewall configuration"
    echo "  $0 --test-only      # Test existing installation"
}

# Parse command line arguments
SKIP_PM2=false
SKIP_FIREWALL=false
SKIP_SYSTEMD=false
TEST_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -p|--port)
            API_PORT="$2"
            shift 2
            ;;
        -d|--dir)
            PROJECT_DIR="$2"
            shift 2
            ;;
        --no-pm2)
            SKIP_PM2=true
            shift
            ;;
        --no-firewall)
            SKIP_FIREWALL=true
            shift
            ;;
        --no-systemd)
            SKIP_SYSTEMD=true
            shift
            ;;
        --test-only)
            TEST_ONLY=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main installation function
main() {
    print_header "ðŸš€ CHETOS Bot - Prometheus API Installer"
    echo -e "${CYAN}This script will install the Prometheus Obfuscator API${NC}"
    echo -e "${CYAN}Repository: $REPO_URL${NC}"
    echo -e "${CYAN}Installation Directory: $PROJECT_DIR${NC}"
    echo -e "${CYAN}API Port: $API_PORT${NC}"
    echo ""

    if [ "$TEST_ONLY" = true ]; then
        print_status "Running tests only..."
        test_installation
        exit $?
    fi

    # Confirm installation
    read -p "Continue with installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Installation cancelled"
        exit 0
    fi

    # Run installation steps
    detect_os
    check_root
    install_git
    install_nodejs

    if [ "$SKIP_PM2" = false ]; then
        install_pm2
    fi

    clone_repository
    install_dependencies

    if [ "$SKIP_FIREWALL" = false ]; then
        configure_firewall
    fi

    if [ "$SKIP_SYSTEMD" = false ]; then
        create_systemd_service
    fi

    start_services

    # Test the installation
    if test_installation; then
        display_final_info
    else
        print_error "Installation completed but tests failed. Check the logs."
        exit 1
    fi
}

# Error handling
trap 'print_error "Installation failed at line $LINENO. Check the output above for details."' ERR

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
