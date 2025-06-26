#!/bin/bash
# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to check OS compatibility
check_os_compatibility() {
    # Get OS details
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$ID
        VERSION_ID=$VERSION_ID
        # Extract major version number
        MAJOR_VERSION=$(echo $VERSION_ID | cut -d. -f1)
    else
        echo -e "${RED}✗${NC} Cannot determine OS. /etc/os-release file not found."
        exit 1
    fi

    # Check if OS is compatible
    if [[ "$OS_NAME" == "almalinux" && ("$MAJOR_VERSION" == "8" || "$MAJOR_VERSION" == "9") ]] || 
       [[ "$OS_NAME" == "cloudlinux" && ("$MAJOR_VERSION" == "8" || "$MAJOR_VERSION" == "9") ]]; then
        echo -e "${GREEN}✓${NC} Compatible OS detected: $OS_NAME $VERSION_ID"
        sleep 1
    else
        echo -e "${RED}✗${NC} Incompatible OS detected: $OS_NAME $VERSION_ID"
        echo -e "${YELLOW}This script is designed to work only with:${NC}"
        echo -e "${WHITE}- AlmaLinux 8.x${NC}"
        echo -e "${WHITE}- AlmaLinux 9.x${NC}"
        echo -e "${WHITE}- CloudLinux 8.x${NC}"
        echo -e "${WHITE}- CloudLinux 9.x${NC}"
        exit 1
    fi
}

# Clear the screen for a clean look
clear

# Check OS compatibility first
check_os_compatibility

# Display CRITICAL WARNING for Hetzner servers
echo -e "${RED}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║                          ⚠️  CRITICAL WARNING FOR HETZNER SERVERS ⚠️             ║${NC}"
echo -e "${RED}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${RED}║                                                                                ║${NC}"
echo -e "${RED}║  🚨 IMPORTANT: Hetzner servers require ALL disks to be setup BEFORE           ║${NC}"
echo -e "${RED}║      running EasycPanel to avoid data loss and ensure optimal performance!    ║${NC}"
echo -e "${RED}║                                                                                ║${NC}"
echo -e "${RED}║  📋 Required Steps:                                                           ║${NC}"
echo -e "${RED}║     1. Check available disks: lsblk                                           ║${NC}"
echo -e "${RED}║     2. Mount ALL available disks                                              ║${NC}"
echo -e "${RED}║     3. Setup RAID/LVM if needed                                               ║${NC}"
echo -e "${RED}║     4. Use option 5 below for automatic Hetzner disk setup                   ║${NC}"
echo -e "${RED}║                                                                                ║${NC}"
echo -e "${RED}║  ❌ DO NOT proceed with cPanel installation until disks are properly setup!   ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
sleep 3

# Display a compact banner
echo -e "${BLUE}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│${GREEN}        cPanel Configuration, Hardening & Security      ${BLUE}│${NC}"
echo -e "${BLUE}│${YELLOW}               Created by Saud Hezam                    ${BLUE}│${NC}"
echo -e "${BLUE}│${WHITE}       Website: saudhezam.com | me@saudhezam.com         ${BLUE}│${NC}"
echo -e "${BLUE}│${CYAN}       Support: ${WHITE}https://ko-fi.com/saudhezam ${CYAN}☕          ${BLUE}│${NC}"
echo -e "${BLUE}│${GREEN}              EasycPanel v4.1 - Enhanced               ${BLUE}│${NC}"
echo -e "${BLUE}└────────────────────────────────────────────────────────┘${NC}"

# Pause the script for 1 second
sleep 1

# Simplified menu for user choice
echo -e "\n${CYAN}┌────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${WHITE}           Please choose an option:             ${CYAN}│${NC}"
echo -e "${CYAN}├────────────────────────────────────────────────┤${NC}"
echo -e "${CYAN}│ ${GREEN}1.${WHITE} Install cPanel on a fresh server ${YELLOW}(AlmaLinux 8/9)${CYAN} │${NC}"
echo -e "${CYAN}│ ${GREEN}2.${WHITE} Secure and optimize existing cPanel server  ${CYAN}│${NC}"
echo -e "${CYAN}│ ${GREEN}3.${WHITE} Advanced monitoring and backup setup    ${CYAN}│${NC}"
echo -e "${CYAN}│ ${GREEN}4.${WHITE} Security audit and malware scan         ${CYAN}│${NC}"
echo -e "${CYAN}│ ${GREEN}5.${WHITE} Hetzner disk auto-mount and setup       ${CYAN}│${NC}"
echo -e "${CYAN}└────────────────────────────────────────────────┘${NC}"

# Read the user's choice
echo -e "\n${YELLOW}Enter your choice (1, 2, 3, 4, or 5):${NC}"
read -p "▶ " choice

# Process the user's choice
case $choice in
  1)
    echo -e "\n${GREEN}✓${NC} Option 1 selected: Installing fresh cPanel on AlmaLinux 8/9 and securing it."
    echo -e "${YELLOW}Executing installation script...${NC}"
    chmod +x fresh-install.sh && ./fresh-install.sh
    ;;
  2)
    echo -e "\n${GREEN}✓${NC} Option 2 selected: Optimizing and securing the current cPanel server on AlmaLinux 8/9."
    echo -e "${YELLOW}Executing optimization script...${NC}"
    chmod +x optimize-cpanel.sh && ./optimize-cpanel.sh
    ;;
  3)
    echo -e "\n${GREEN}✓${NC} Option 3 selected: Setting up advanced monitoring and backup system."
    echo -e "${YELLOW}Executing monitoring and backup setup...${NC}"
    chmod +x setup-monitoring.sh && ./setup-monitoring.sh
    ;;
  4)
    echo -e "\n${GREEN}✓${NC} Option 4 selected: Running security audit and malware scan."
    echo -e "${YELLOW}Executing security audit...${NC}"
    chmod +x security-audit.sh && ./security-audit.sh
    ;;
  5)
    echo -e "\n${GREEN}✓${NC} Option 5 selected: Hetzner disk auto-mount and setup."
    echo -e "${YELLOW}Executing Hetzner disk setup...${NC}"
    chmod +x hetzner-disk-setup.sh && ./hetzner-disk-setup.sh
    ;;
  *)
    echo -e "\n${RED}✗${NC} Invalid choice. Please select 1, 2, 3, 4, or 5."
    ;;
esac