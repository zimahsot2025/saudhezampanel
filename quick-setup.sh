#!/bin/bash

# EasycPanel v4.1 Enhanced - Quick Setup
# Created by Saud Hezam | saudhezam.com

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

clear

# Display CRITICAL WARNING for Hetzner servers FIRST
echo -e "${RED}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║                          ⚠️  CRITICAL WARNING FOR HETZNER SERVERS ⚠️             ║${NC}"
echo -e "${RED}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${RED}║                                                                                ║${NC}"
echo -e "${RED}║  🚨 HETZNER USERS: You MUST setup all disks BEFORE proceeding!                ║${NC}"
echo -e "${RED}║     Hetzner servers have unmounted disks that can cause data loss!            ║${NC}"
echo -e "${RED}║                                                                                ║${NC}"
echo -e "${RED}║  ✅ Use Option 6 below to automatically setup Hetzner disks                   ║${NC}"
echo -e "${RED}║  ❌ DO NOT use options 1-5 until disks are properly configured!               ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
sleep 2

# Enhanced welcome banner
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${GREEN}                     🚀 EasycPanel v4.1 Enhanced                   ${BLUE}║${NC}"
echo -e "${BLUE}║${WHITE}                   The Ultimate cPanel Management Suite            ${BLUE}║${NC}"
echo -e "${BLUE}╠════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BLUE}║${YELLOW}               👨‍💻 Created by: Saud Hezam                          ${BLUE}║${NC}"
echo -e "${BLUE}║${WHITE}               🌐 Website: saudhezam.com                           ${BLUE}║${NC}"
echo -e "${BLUE}║${WHITE}               📧 Email: me@saudhezam.com                          ${BLUE}║${NC}"
echo -e "${BLUE}║${CYAN}               ☕ Support: ko-fi.com/saudhezam                     ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${CYAN}┌────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${WHITE}                        ✨ NEW FEATURES IN v4.1                    ${CYAN}│${NC}"
echo -e "${CYAN}├────────────────────────────────────────────────────────────────┤${NC}"
echo -e "${CYAN}│${GREEN} 🎛️  Enhanced Management Console - Real-time monitoring          ${CYAN}│${NC}"
echo -e "${CYAN}│${GREEN} 🔒  Advanced Security Audit - Comprehensive security scanning   ${CYAN}│${NC}"
echo -e "${CYAN}│${GREEN} 📊  Smart Monitoring System - Automated alerts & backups       ${CYAN}│${NC}"
echo -e "${CYAN}│${GREEN} 🛡️  Enhanced Security Config - Advanced firewall & protection  ${CYAN}│${NC}"
echo -e "${CYAN}│${GREEN} 🔐  SSL Certificate Manager - Auto-renewal & management         ${CYAN}│${NC}"
echo -e "${CYAN}│${GREEN} 💾  Automated Backup System - Daily backups with retention     ${CYAN}│${NC}"
echo -e "${CYAN}│${GREEN} 👀  Real-time Malware Scanner - Live threat detection          ${CYAN}│${NC}"
echo -e "${CYAN}│${GREEN} ⚡  Performance Optimization - Enhanced caching & tuning       ${CYAN}│${NC}"
echo -e "${CYAN}└────────────────────────────────────────────────────────────────┘${NC}"

echo -e "\n${YELLOW}🔧 Quick Setup Options:${NC}"
echo -e "\n${WHITE}1.${NC} ${GREEN}Complete Setup${NC} - Install everything (Recommended)"
echo -e "${WHITE}2.${NC} ${BLUE}Security Only${NC} - Install security features only"
echo -e "${WHITE}3.${NC} ${YELLOW}Monitoring Only${NC} - Install monitoring and backup system"
echo -e "${WHITE}4.${NC} ${CYAN}Custom Setup${NC} - Choose specific components"
echo -e "${WHITE}5.${NC} ${WHITE}Standard cPanel Setup${NC} - Run original cPanel installation"
echo -e "${WHITE}6.${NC} ${RED}Hetzner Disk Setup${NC} - Auto-mount and setup all disks"

echo -e "\n${YELLOW}Select your preferred setup option (1-6):${NC}"
read -p "▶ " setup_choice

case $setup_choice in
    1)
        echo -e "\n${GREEN}🚀 Starting Complete Enhanced Setup...${NC}"
        echo -e "${CYAN}This will install all cPanel optimizations and enhanced features.${NC}"
        sleep 2
        chmod +x cPanel-v4.sh && ./cPanel-v4.sh
        ;;
    2)
        echo -e "\n${BLUE}🔒 Starting Security-Only Setup...${NC}"
        echo -e "${CYAN}Installing advanced security features...${NC}"
        sleep 2
        chmod +x enhanced-security.sh && ./enhanced-security.sh
        chmod +x security-audit.sh && ./security-audit.sh
        ;;
    3)
        echo -e "\n${YELLOW}📊 Starting Monitoring Setup...${NC}"
        echo -e "${CYAN}Installing monitoring and backup system...${NC}"
        sleep 2
        chmod +x setup-monitoring.sh && ./setup-monitoring.sh
        ;;
    4)
        echo -e "\n${CYAN}🎛️ Custom Setup Options:${NC}"
        echo -e "\n${WHITE}Available Components:${NC}"
        echo -e "${WHITE}a)${NC} Enhanced Security Configuration"
        echo -e "${WHITE}b)${NC} Monitoring and Backup System"
        echo -e "${WHITE}c)${NC} SSL Certificate Manager"
        echo -e "${WHITE}d)${NC} Security Audit Tool"
        echo -e "${WHITE}e)${NC} Enhanced Management Console"
        echo -e "${WHITE}f)${NC} All Components"
        
        echo -e "\n${YELLOW}Select components (e.g., 'abc' for multiple):${NC}"
        read -p "▶ " components
        
        if [[ $components == *"a"* ]] || [[ $components == *"f"* ]]; then
            echo -e "${BLUE}Installing Enhanced Security...${NC}"
            chmod +x enhanced-security.sh && ./enhanced-security.sh
        fi
        
        if [[ $components == *"b"* ]] || [[ $components == *"f"* ]]; then
            echo -e "${YELLOW}Installing Monitoring System...${NC}"
            chmod +x setup-monitoring.sh && ./setup-monitoring.sh
        fi
        
        if [[ $components == *"c"* ]] || [[ $components == *"f"* ]]; then
            echo -e "${GREEN}Installing SSL Manager...${NC}"
            chmod +x ssl-manager.sh && ./ssl-manager.sh
        fi
        
        if [[ $components == *"d"* ]] || [[ $components == *"f"* ]]; then
            echo -e "${CYAN}Running Security Audit...${NC}"
            chmod +x security-audit.sh && ./security-audit.sh
        fi
        
        if [[ $components == *"e"* ]] || [[ $components == *"f"* ]]; then
            echo -e "${WHITE}Installing Management Console...${NC}"
            chmod +x enhanced-console.sh
            echo -e "${GREEN}Management console ready! Run: ./enhanced-console.sh${NC}"
        fi
        ;;
    5)
        echo -e "\n${WHITE}🔧 Starting Standard cPanel Setup...${NC}"
        echo -e "${CYAN}Running original cPanel installation process...${NC}"
        sleep 2
        chmod +x cPanel-v4.sh && ./cPanel-v4.sh
        ;;
    6)
        echo -e "\n${RED}💾 Starting Hetzner Disk Setup...${NC}"
        echo -e "${CYAN}Auto-mounting and setting up all available disks...${NC}"
        sleep 2
        chmod +x hetzner-disk-setup.sh && ./hetzner-disk-setup.sh
        ;;
    *)
        echo -e "\n${RED}❌ Invalid option selected.${NC}"
        echo -e "${YELLOW}Please run the script again and select a valid option (1-6).${NC}"
        exit 1
        ;;
esac

# Post-installation information
echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${WHITE}                     🎉 Setup Complete!                           ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${CYAN}📋 Available Tools:${NC}"
echo -e "${WHITE}• Management Console:${NC} ${YELLOW}./enhanced-console.sh${NC}"
echo -e "${WHITE}• Security Audit:${NC} ${YELLOW}./security-audit.sh${NC}"
echo -e "${WHITE}• Monitoring Setup:${NC} ${YELLOW}./setup-monitoring.sh${NC}"
echo -e "${WHITE}• Enhanced Security:${NC} ${YELLOW}./enhanced-security.sh${NC}"
echo -e "${WHITE}• SSL Manager:${NC} ${YELLOW}./ssl-manager.sh${NC}"
echo -e "${WHITE}• Hetzner Disk Setup:${NC} ${YELLOW}./hetzner-disk-setup.sh${NC}"
echo -e "${WHITE}• Auto Disk Setup:${NC} ${YELLOW}./auto-disk-setup.sh${NC}"

echo -e "\n${CYAN}📚 Documentation:${NC}"
echo -e "${WHITE}• Main README:${NC} ${YELLOW}README.md${NC}"
echo -e "${WHITE}• Enhanced README:${NC} ${YELLOW}README_NEW.md${NC}"
echo -e "${WHITE}• Changelog:${NC} ${YELLOW}CHANGELOG.md${NC}"

echo -e "\n${CYAN}📞 Support & Contact:${NC}"
echo -e "${WHITE}• Website:${NC} ${YELLOW}https://saudhezam.com${NC}"
echo -e "${WHITE}• Email:${NC} ${YELLOW}me@saudhezam.com${NC}"
echo -e "${WHITE}• Support:${NC} ${YELLOW}https://ko-fi.com/saudhezam${NC}"

echo -e "\n${GREEN}Thank you for using EasycPanel v4.1 Enhanced! 🚀${NC}"
echo -e "${CYAN}Created with ❤️ by Saud Hezam${NC}"

# Make all scripts executable
chmod +x *.sh 2>/dev/null

echo -e "\n${YELLOW}💡 Tip: Run ${WHITE}./enhanced-console.sh${YELLOW} for a comprehensive management interface!${NC}"
