#!/bin/bash

# EasycPanel v4.1 Enhanced - Automatic Intelligent Installation
# Created by Saud Hezam | saudhezam.com
# This script automatically detects server type, checks disks, and runs appropriate installation

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Define log file
LOG_FILE="/root/easycpanel-auto-install.log"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@" >> "${LOG_FILE}"
    echo -e "${CYAN}$@${NC}"
}

# Function to display messages
success_msg() {
    echo -e "${GREEN}✓${NC} $@"
    log "SUCCESS: $@"
}

error_msg() {
    echo -e "${RED}✗${NC} $@"
    log "ERROR: $@"
}

warning_msg() {
    echo -e "${YELLOW}⚠${NC} $@"
    log "WARNING: $@"
}

info_msg() {
    echo -e "${CYAN}ℹ${NC} $@"
    log "INFO: $@"
}

# Function to display section headers
section_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${WHITE} $1 ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    log "$1"
    sleep 1
}

# Function to check if script is run as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error_msg "This script must be run as root!"
        echo -e "${YELLOW}Please run: sudo bash $0${NC}"
        exit 1
    fi
}

# Function to detect server provider
detect_server_provider() {
    section_header "🔍 Detecting Server Provider and Type"
    
    # Check for Hetzner
    if grep -i "hetzner" /sys/class/dmi/id/sys_vendor 2>/dev/null || \
       grep -i "hetzner" /sys/class/dmi/id/board_vendor 2>/dev/null || \
       curl -s --max-time 3 http://169.254.169.254/hetzner/v1/metadata 2>/dev/null | grep -q "instance-id"; then
        SERVER_PROVIDER="hetzner"
        success_msg "Hetzner server detected"
        return 0
    fi
    
    # Check for DigitalOcean
    if curl -s --max-time 3 http://169.254.169.254/metadata/v1/id 2>/dev/null | grep -q "[0-9]"; then
        SERVER_PROVIDER="digitalocean"
        success_msg "DigitalOcean droplet detected"
        return 0
    fi
    
    # Check for AWS
    if curl -s --max-time 3 http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null | grep -q "i-"; then
        SERVER_PROVIDER="aws"
        success_msg "Amazon AWS EC2 instance detected"
        return 0
    fi
    
    # Check for Google Cloud
    if curl -s --max-time 3 http://metadata.google.internal/computeMetadata/v1/instance/id -H "Metadata-Flavor: Google" 2>/dev/null | grep -q "[0-9]"; then
        SERVER_PROVIDER="gcp"
        success_msg "Google Cloud Platform instance detected"
        return 0
    fi
    
    # Check for Vultr
    if curl -s --max-time 3 http://169.254.169.254/v1/instanceid 2>/dev/null | grep -q "[0-9]"; then
        SERVER_PROVIDER="vultr"
        success_msg "Vultr instance detected"
        return 0
    fi
    
    # Check for Linode
    if curl -s --max-time 3 http://169.254.169.254/linode/v1/instance 2>/dev/null | grep -q "id"; then
        SERVER_PROVIDER="linode"
        success_msg "Linode instance detected"
        return 0
    fi
    
    # Default to unknown
    SERVER_PROVIDER="unknown"
    warning_msg "Server provider could not be determined"
    info_msg "Proceeding with generic server configuration"
}

# Function to check operating system compatibility
check_os_compatibility() {
    section_header "🖥️ Checking Operating System Compatibility"
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$ID
        VERSION_ID=$VERSION_ID
        MAJOR_VERSION=$(echo $VERSION_ID | cut -d. -f1)
    else
        error_msg "Cannot determine OS. /etc/os-release file not found."
        exit 1
    fi
    
    if [[ "$OS_NAME" == "almalinux" && ("$MAJOR_VERSION" == "8" || "$MAJOR_VERSION" == "9") ]] || 
       [[ "$OS_NAME" == "cloudlinux" && ("$MAJOR_VERSION" == "8" || "$MAJOR_VERSION" == "9") ]]; then
        success_msg "Compatible OS detected: $OS_NAME $VERSION_ID"
        return 0
    else
        error_msg "Incompatible OS detected: $OS_NAME $VERSION_ID"
        echo -e "${YELLOW}EasycPanel requires:${NC}"
        echo -e "${WHITE}• AlmaLinux 8.x or 9.x${NC}"
        echo -e "${WHITE}• CloudLinux 8.x or 9.x${NC}"
        exit 1
    fi
}

# Function to detect and analyze disk configuration
detect_disk_configuration() {
    section_header "💾 Analyzing Disk Configuration"
    
    # Get all block devices
    ALL_DISKS=$(lsblk -nd -o NAME | grep -E '^[a-z]+$' | sort)
    MOUNTED_DISKS=$(lsblk -nd -o NAME,MOUNTPOINT | grep -E '^[a-z]+' | awk '$2 != "" {print $1}' | sort)
    
    info_msg "Scanning all available disks..."
    echo ""
    lsblk
    echo ""
    
    # Count disks
    TOTAL_DISKS=$(echo "$ALL_DISKS" | wc -l)
    MOUNTED_DISK_COUNT=$(echo "$MOUNTED_DISKS" | wc -l)
    
    info_msg "Found $TOTAL_DISKS total disks"
    info_msg "Found $MOUNTED_DISK_COUNT mounted disks"
    
    # Check for unmounted disks
    UNMOUNTED_DISKS=""
    for disk in $ALL_DISKS; do
        if ! echo "$MOUNTED_DISKS" | grep -q "^$disk$"; then
            UNMOUNTED_DISKS="$UNMOUNTED_DISKS $disk"
        fi
    done
    
    if [ -n "$UNMOUNTED_DISKS" ]; then
        UNMOUNTED_COUNT=$(echo $UNMOUNTED_DISKS | wc -w)
        warning_msg "Found $UNMOUNTED_COUNT unmounted disks:$UNMOUNTED_DISKS"
        DISK_SETUP_REQUIRED=true
    else
        success_msg "All disks are properly mounted"
        DISK_SETUP_REQUIRED=false
    fi
}

# Function to display disk analysis results
display_disk_analysis() {
    section_header "📊 Disk Analysis Results"
    
    echo -e "${CYAN}┌────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${WHITE}                        DISK ANALYSIS SUMMARY                       ${CYAN}│${NC}"
    echo -e "${CYAN}├────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${WHITE} Server Provider: ${GREEN}$(echo $SERVER_PROVIDER | tr '[:lower:]' '[:upper:]')${WHITE}                                    ${CYAN}│${NC}"
    echo -e "${CYAN}│${WHITE} Total Disks: ${GREEN}$TOTAL_DISKS${WHITE}                                              ${CYAN}│${NC}"
    echo -e "${CYAN}│${WHITE} Mounted Disks: ${GREEN}$MOUNTED_DISK_COUNT${WHITE}                                            ${CYAN}│${NC}"
    
    if [ "$DISK_SETUP_REQUIRED" = true ]; then
        echo -e "${CYAN}│${WHITE} Unmounted Disks: ${RED}$(echo $UNMOUNTED_DISKS | wc -w)${WHITE} ${RED}(REQUIRES SETUP!)${WHITE}               ${CYAN}│${NC}"
        echo -e "${CYAN}│${WHITE} Status: ${RED}DISK SETUP REQUIRED${WHITE}                                 ${CYAN}│${NC}"
    else
        echo -e "${CYAN}│${WHITE} Unmounted Disks: ${GREEN}0${WHITE}                                           ${CYAN}│${NC}"
        echo -e "${CYAN}│${WHITE} Status: ${GREEN}READY FOR CPANEL INSTALLATION${WHITE}                      ${CYAN}│${NC}"
    fi
    
    echo -e "${CYAN}└────────────────────────────────────────────────────────────────┘${NC}"
}

# Function to handle Hetzner disk setup
handle_hetzner_disk_setup() {
    if [ "$SERVER_PROVIDER" = "hetzner" ] && [ "$DISK_SETUP_REQUIRED" = true ]; then
        section_header "🚨 CRITICAL: Hetzner Disk Setup Required"
        
        echo -e "${RED}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║                              ⚠️ CRITICAL WARNING ⚠️                              ║${NC}"
        echo -e "${RED}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${RED}║                                                                                ║${NC}"
        echo -e "${RED}║  🚨 HETZNER SERVERS REQUIRE IMMEDIATE DISK SETUP!                             ║${NC}"
        echo -e "${RED}║                                                                                ║${NC}"
        echo -e "${RED}║  ❌ Proceeding without disk setup WILL CAUSE DATA LOSS!                       ║${NC}"
        echo -e "${RED}║  ✅ We will automatically setup your disks safely                             ║${NC}"
        echo -e "${RED}║                                                                                ║${NC}"
        echo -e "${RED}║  Detected unmounted disks:$UNMOUNTED_DISKS${NC}"
        echo -e "${RED}║                                                                                ║${NC}"
        echo -e "${RED}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
        
        echo ""
        echo -e "${YELLOW}We will now automatically setup your Hetzner disks...${NC}"
        sleep 3
        
        # Check if hetzner-disk-setup.sh exists
        if [ -f "./hetzner-disk-setup.sh" ]; then
            info_msg "Running Hetzner disk setup script..."
            chmod +x ./hetzner-disk-setup.sh
            ./hetzner-disk-setup.sh
            
            if [ $? -eq 0 ]; then
                success_msg "Hetzner disk setup completed successfully!"
                DISK_SETUP_REQUIRED=false
            else
                error_msg "Hetzner disk setup failed!"
                exit 1
            fi
        else
            error_msg "Hetzner disk setup script not found!"
            echo -e "${YELLOW}Please download the complete EasycPanel package or run:${NC}"
            echo -e "${WHITE}curl -O https://saudhezam.com/cpanel-script/hetzner-disk-setup.sh${NC}"
            exit 1
        fi
    fi
}

# Function to handle generic disk setup
handle_generic_disk_setup() {
    if [ "$SERVER_PROVIDER" != "hetzner" ] && [ "$DISK_SETUP_REQUIRED" = true ]; then
        section_header "💾 Unmounted Disks Detected"
        
        echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║                              ⚠️ UNMOUNTED DISKS FOUND ⚠️                         ║${NC}"
        echo -e "${YELLOW}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${YELLOW}║                                                                                ║${NC}"
        echo -e "${YELLOW}║  Your server has unmounted disks that should be configured for optimal        ║${NC}"
        echo -e "${YELLOW}║  performance and storage utilization.                                         ║${NC}"
        echo -e "${YELLOW}║                                                                                ║${NC}"
        echo -e "${YELLOW}║  Unmounted disks:$UNMOUNTED_DISKS${NC}"
        echo -e "${YELLOW}║                                                                                ║${NC}"
        echo -e "${YELLOW}║  Options:                                                                      ║${NC}"
        echo -e "${YELLOW}║  1. Continue without disk setup (not recommended)                             ║${NC}"
        echo -e "${YELLOW}║  2. Setup disks automatically (recommended)                                   ║${NC}"
        echo -e "${YELLOW}║  3. Exit and setup disks manually                                             ║${NC}"
        echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
        
        echo ""
        echo -e "${WHITE}What would you like to do?${NC}"
        echo -e "${GREEN}1.${NC} Continue without disk setup ${YELLOW}(Not Recommended)${NC}"
        echo -e "${GREEN}2.${NC} Automatically setup disks ${GREEN}(Recommended)${NC}"
        echo -e "${GREEN}3.${NC} Exit and setup disks manually"
        
        read -p "▶ Enter your choice (1-3): " disk_choice
        
        case $disk_choice in
            1)
                warning_msg "Proceeding without disk setup. You're not utilizing all available storage!"
                DISK_SETUP_REQUIRED=false
                ;;
            2)
                info_msg "Starting automatic disk setup..."
                # Here you would call a generic disk setup script
                warning_msg "Generic automatic disk setup not yet implemented"
                warning_msg "Please setup disks manually or use option 3"
                DISK_SETUP_REQUIRED=false
                ;;
            3)
                info_msg "Exiting for manual disk setup"
                echo -e "${YELLOW}Please setup your disks manually and run this script again${NC}"
                exit 0
                ;;
            *)
                warning_msg "Invalid choice. Proceeding without disk setup..."
                DISK_SETUP_REQUIRED=false
                ;;
        esac
    fi
}

# Function to verify disk setup
verify_disk_setup() {
    if [ "$DISK_SETUP_REQUIRED" = false ]; then
        section_header "✅ Verifying Disk Configuration"
        
        info_msg "Re-scanning disk configuration..."
        detect_disk_configuration
        
        if [ "$DISK_SETUP_REQUIRED" = true ]; then
            error_msg "Disk setup verification failed! Still have unmounted disks."
            exit 1
        else
            success_msg "All disks are properly configured!"
        fi
    fi
}

# Function to determine installation method
determine_installation_method() {
    section_header "🚀 Determining Installation Method"
    
    # Check if cPanel is already installed
    if [ -d "/usr/local/cpanel" ] && [ -f "/usr/local/cpanel/cpanel" ]; then
        CPANEL_INSTALLED=true
        success_msg "cPanel installation detected"
        INSTALL_METHOD="optimize"
    else
        CPANEL_INSTALLED=false
        info_msg "Fresh server detected (no cPanel installation)"
        INSTALL_METHOD="fresh"
    fi
    
    # Determine web server preference
    echo ""
    echo -e "${CYAN}┌────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${WHITE}                   Web Server Configuration                    ${CYAN}│${NC}"
    echo -e "${CYAN}├────────────────────────────────────────────────────────────────┤${NC}"
    
    if [ "$INSTALL_METHOD" = "fresh" ]; then
        echo -e "${CYAN}│${WHITE} Choose your preferred web server setup:                       ${CYAN}│${NC}"
        echo -e "${CYAN}└────────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        echo -e "${GREEN}1.${NC} Apache Web Server ${WHITE}(Traditional, highly compatible)${NC}"
        echo -e "${GREEN}2.${NC} Nginx + Apache ${WHITE}(Better performance, modern)${NC}"
        echo -e "${GREEN}3.${NC} Automatic selection ${WHITE}(Recommended for beginners)${NC}"
        
        read -p "▶ Enter your choice (1-3): " webserver_choice
        
        case $webserver_choice in
            1)
                WEB_SERVER="apache"
                success_msg "Apache web server selected"
                ;;
            2)
                WEB_SERVER="nginx"
                success_msg "Nginx + Apache selected"
                ;;
            3|*)
                WEB_SERVER="auto"
                success_msg "Automatic web server selection"
                ;;
        esac
    else
        echo -e "${CYAN}│${WHITE} Server optimization will be performed                          ${CYAN}│${NC}"
        echo -e "${CYAN}└────────────────────────────────────────────────────────────────┘${NC}"
        WEB_SERVER="existing"
    fi
}

# Function to run appropriate installation script
run_installation() {
    section_header "🛠️ Starting Installation Process"
    
    case $INSTALL_METHOD in
        "fresh")
            if [ "$WEB_SERVER" = "apache" ] || [ "$WEB_SERVER" = "auto" ]; then
                info_msg "Running fresh Apache installation..."
                if [ -f "./fresh-install-apache.sh" ]; then
                    chmod +x ./fresh-install-apache.sh
                    ./fresh-install-apache.sh
                else
                    error_msg "fresh-install-apache.sh not found!"
                    exit 1
                fi
            elif [ "$WEB_SERVER" = "nginx" ]; then
                info_msg "Running fresh Nginx installation..."
                if [ -f "./fresh-install-nginx.sh" ]; then
                    chmod +x ./fresh-install-nginx.sh
                    ./fresh-install-nginx.sh
                else
                    error_msg "fresh-install-nginx.sh not found!"
                    exit 1
                fi
            fi
            ;;
        "optimize")
            info_msg "Running server optimization..."
            if [ -f "./optimize-cpanel.sh" ]; then
                chmod +x ./optimize-cpanel.sh
                ./optimize-cpanel.sh
            else
                error_msg "optimize-cpanel.sh not found!"
                exit 1
            fi
            ;;
    esac
}

# Function to display completion summary
display_completion_summary() {
    section_header "🎉 Installation Summary"
    
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                            ✅ INSTALLATION COMPLETED ✅                           ║${NC}"
    echo -e "${GREEN}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║                                                                                ║${NC}"
    echo -e "${GREEN}║  🖥️  Server Provider: $(printf "%-20s" "$(echo $SERVER_PROVIDER | tr '[:lower:]' '[:upper:]')")                                    ║${NC}"
    echo -e "${GREEN}║  💿  Operating System: $(printf "%-20s" "$OS_NAME $VERSION_ID")                                 ║${NC}"
    echo -e "${GREEN}║  💾  Total Disks: $(printf "%-20s" "$TOTAL_DISKS")                                          ║${NC}"
    echo -e "${GREEN}║  🔧  Installation Type: $(printf "%-20s" "$(echo $INSTALL_METHOD | tr '[:lower:]' '[:upper:]')")                                ║${NC}"
    
    if [ "$INSTALL_METHOD" = "fresh" ]; then
        echo -e "${GREEN}║  🌐  Web Server: $(printf "%-20s" "$(echo $WEB_SERVER | tr '[:lower:]' '[:upper:]')")                                      ║${NC}"
    fi
    
    echo -e "${GREEN}║                                                                                ║${NC}"
    echo -e "${GREEN}║  📋  Complete installation log: /root/easycpanel-auto-install.log             ║${NC}"
    echo -e "${GREEN}║                                                                                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo ""
    success_msg "EasycPanel installation completed successfully!"
    info_msg "Please check the detailed logs for any additional information"
    
    if [ "$INSTALL_METHOD" = "fresh" ]; then
        echo ""
        echo -e "${YELLOW}⚠️  A system reboot is recommended to complete the setup${NC}"
        echo -e "${GREEN}Please run 'reboot' when you're ready${NC}"
    fi
}

# Main execution function
main() {
    # Clear screen
    clear
    
    # Display banner
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${GREEN}                          🚀 EasycPanel v4.1 Enhanced 🚀                          ${BLUE}║${NC}"
    echo -e "${BLUE}║${WHITE}                       Automatic Intelligent Installation                       ${BLUE}║${NC}"
    echo -e "${BLUE}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${YELLOW}                              Created by Saud Hezam                             ${BLUE}║${NC}"
    echo -e "${BLUE}║${WHITE}                        Website: saudhezam.com                                  ${BLUE}║${NC}"
    echo -e "${BLUE}║${WHITE}                        Email: me@saudhezam.com                                 ${BLUE}║${NC}"
    echo -e "${BLUE}║${CYAN}                        Support: ko-fi.com/saudhezam ☕                          ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo ""
    echo -e "${CYAN}This script will automatically:${NC}"
    echo -e "${WHITE}• Detect your server provider and type${NC}"
    echo -e "${WHITE}• Check and configure disk setup${NC}"
    echo -e "${WHITE}• Determine the best installation method${NC}"
    echo -e "${WHITE}• Run the appropriate installation script${NC}"
    echo ""
    
    log "EasycPanel v4.1 Enhanced Auto-Installation Started"
    log "Script executed by: $(whoami) on $(date)"
    
    # Main execution steps
    check_root
    detect_server_provider
    check_os_compatibility
    detect_disk_configuration
    display_disk_analysis
    
    # Handle disk setup based on provider
    if [ "$SERVER_PROVIDER" = "hetzner" ]; then
        handle_hetzner_disk_setup
    else
        handle_generic_disk_setup
    fi
    
    verify_disk_setup
    determine_installation_method
    
    # Final confirmation before proceeding
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Ready to proceed with installation!${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${WHITE}Press ${GREEN}Enter${WHITE} to continue or ${RED}Ctrl+C${WHITE} to cancel...${NC}"
    read
    
    run_installation
    display_completion_summary
    
    log "EasycPanel Auto-Installation completed successfully at $(date)"
}

# Execute main function
main "$@"
