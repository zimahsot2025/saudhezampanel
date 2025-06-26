#!/bin/bash

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Enhanced Server Management Dashboard
echo -e "${BLUE}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│${GREEN}           Enhanced Server Management Console           ${BLUE}│${NC}"
echo -e "${BLUE}│${YELLOW}               Created by Saud Hezam                    ${BLUE}│${NC}"
echo -e "${BLUE}│${WHITE}       Website: saudhezam.com | me@saudhezam.com         ${BLUE}│${NC}"
echo -e "${BLUE}│${CYAN}       Support: ${WHITE}https://ko-fi.com/saudhezam ${CYAN}☕          ${BLUE}│${NC}"
echo -e "${BLUE}│${GREEN}              EasycPanel v4.1 - Enhanced               ${BLUE}│${NC}"
echo -e "${BLUE}└────────────────────────────────────────────────────────┘${NC}"

# Functions
success_msg() {
    echo -e "${GREEN}✓${NC} $1"
}

error_msg() {
    echo -e "${RED}✗${NC} $1"
}

warning_msg() {
    echo -e "${YELLOW}⚠${NC} $1"
}

info_msg() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# System Information Function
show_system_info() {
    clear
    echo -e "${BLUE}┌─────────────────── System Information ───────────────────┐${NC}"
    
    # Basic system info
    echo -e "${WHITE}Hostname:${NC} $(hostname)"
    echo -e "${WHITE}Uptime:${NC} $(uptime -p)"
    echo -e "${WHITE}OS:${NC} $(cat /etc/redhat-release 2>/dev/null || echo "Unknown")"
    echo -e "${WHITE}Kernel:${NC} $(uname -r)"
    
    # CPU Information
    CPU_CORES=$(nproc)
    CPU_MODEL=$(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d: -f2 | xargs)
    echo -e "${WHITE}CPU:${NC} $CPU_MODEL ($CPU_CORES cores)"
    
    # Memory Information
    MEM_TOTAL=$(free -h | grep "Mem:" | awk '{print $2}')
    MEM_USED=$(free -h | grep "Mem:" | awk '{print $3}')
    MEM_FREE=$(free -h | grep "Mem:" | awk '{print $4}')
    echo -e "${WHITE}Memory:${NC} $MEM_USED / $MEM_TOTAL used (Free: $MEM_FREE)"
    
    # Disk Information
    echo -e "${WHITE}Disk Usage:${NC}"
    df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{print "  " $5 " " $1 " (" $3 "/" $2 ")"}'
    
    # Load Average
    LOAD_AVG=$(cat /proc/loadavg | awk '{print $1 " " $2 " " $3}')
    echo -e "${WHITE}Load Average:${NC} $LOAD_AVG"
    
    # Network Interfaces
    echo -e "${WHITE}Network Interfaces:${NC}"
    ip addr show | grep -E "^[0-9]+:" | awk '{print "  " $2}' | sed 's/://'
    
    echo -e "${BLUE}└──────────────────────────────────────────────────────────┘${NC}"
}

# Service Status Function
show_services_status() {
    clear
    echo -e "${BLUE}┌─────────────────── Service Status ───────────────────────┐${NC}"
    
    services=("httpd" "mysql" "exim" "named" "sshd" "cpanel" "whostmgrd")
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet $service 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $service - ${GREEN}Running${NC}"
        elif service $service status >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} $service - ${GREEN}Running${NC}"
        else
            echo -e "${RED}✗${NC} $service - ${RED}Stopped${NC}"
        fi
    done
    
    echo -e "${BLUE}└──────────────────────────────────────────────────────────┘${NC}"
}

# Security Status Function
show_security_status() {
    clear
    echo -e "${BLUE}┌─────────────────── Security Status ──────────────────────┐${NC}"
    
    # Check CSF Firewall
    if command -v csf &> /dev/null; then
        if csf -l >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} CSF Firewall - ${GREEN}Active${NC}"
        else
            echo -e "${YELLOW}⚠${NC} CSF Firewall - ${YELLOW}Installed but not active${NC}"
        fi
    else
        echo -e "${RED}✗${NC} CSF Firewall - ${RED}Not installed${NC}"
    fi
    
    # Check Fail2ban
    if systemctl is-active --quiet fail2ban 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Fail2ban - ${GREEN}Active${NC}"
        BANNED_IPS=$(fail2ban-client status sshd 2>/dev/null | grep "Currently banned" | awk '{print $4}' || echo "0")
        echo -e "  Currently banned IPs: $BANNED_IPS"
    else
        echo -e "${RED}✗${NC} Fail2ban - ${RED}Not active${NC}"
    fi
    
    # Check ModSecurity
    if httpd -M 2>/dev/null | grep -q security2; then
        echo -e "${GREEN}✓${NC} ModSecurity - ${GREEN}Loaded${NC}"
    else
        echo -e "${RED}✗${NC} ModSecurity - ${RED}Not loaded${NC}"
    fi
    
    # Check SSL Certificates
    if [ -d "/var/cpanel/ssl" ]; then
        SSL_COUNT=$(find /var/cpanel/ssl -name "*.crt" 2>/dev/null | wc -l)
        echo -e "${GREEN}✓${NC} SSL Certificates - ${GREEN}$SSL_COUNT found${NC}"
    else
        echo -e "${YELLOW}⚠${NC} SSL Certificates - ${YELLOW}Directory not found${NC}"
    fi
    
    # Check for recent failed logins
    FAILED_LOGINS=$(grep "Failed password" /var/log/secure 2>/dev/null | grep "$(date +%b\ %d)" | wc -l)
    if [ $FAILED_LOGINS -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Failed Logins Today - ${GREEN}$FAILED_LOGINS${NC}"
    elif [ $FAILED_LOGINS -lt 10 ]; then
        echo -e "${YELLOW}⚠${NC} Failed Logins Today - ${YELLOW}$FAILED_LOGINS${NC}"
    else
        echo -e "${RED}✗${NC} Failed Logins Today - ${RED}$FAILED_LOGINS${NC}"
    fi
    
    echo -e "${BLUE}└──────────────────────────────────────────────────────────┘${NC}"
}

# Performance Monitoring Function
show_performance() {
    clear
    echo -e "${BLUE}┌─────────────────── Performance Monitor ──────────────────┐${NC}"
    
    # CPU Usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo -e "${WHITE}CPU Usage:${NC} ${CPU_USAGE}%"
    
    # Memory Usage
    MEM_PERCENT=$(free | grep Mem | awk '{printf("%.1f"), $3/$2 * 100.0}')
    echo -e "${WHITE}Memory Usage:${NC} ${MEM_PERCENT}%"
    
    # Disk I/O
    if command -v iostat &> /dev/null; then
        DISK_IO=$(iostat -x 1 1 | tail -n +4 | head -1 | awk '{print $10}')
        echo -e "${WHITE}Disk I/O:${NC} ${DISK_IO}% utilization"
    fi
    
    # Network connections
    CONNECTIONS=$(netstat -an | wc -l)
    echo -e "${WHITE}Network Connections:${NC} $CONNECTIONS"
    
    # Apache connections (if running)
    if systemctl is-active --quiet httpd; then
        APACHE_PROCS=$(ps aux | grep httpd | grep -v grep | wc -l)
        echo -e "${WHITE}Apache Processes:${NC} $APACHE_PROCS"
    fi
    
    # MySQL connections (if running)
    if systemctl is-active --quiet mysql; then
        MYSQL_CONNS=$(mysqladmin processlist 2>/dev/null | wc -l)
        echo -e "${WHITE}MySQL Connections:${NC} $MYSQL_CONNS"
    fi
    
    # Top 5 processes by CPU
    echo -e "\n${WHITE}Top 5 CPU consuming processes:${NC}"
    ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "  %-15s %6s%%  %s\n", $1, $3, $11}'
    
    echo -e "${BLUE}└──────────────────────────────────────────────────────────┘${NC}"
}

# Backup Management Function
manage_backups() {
    clear
    echo -e "${BLUE}┌─────────────────── Backup Management ────────────────────┐${NC}"
    
    echo -e "${WHITE}1.${NC} Create full system backup"
    echo -e "${WHITE}2.${NC} Create cPanel accounts backup"
    echo -e "${WHITE}3.${NC} List available backups"
    echo -e "${WHITE}4.${NC} Restore from backup"
    echo -e "${WHITE}5.${NC} Clean old backups"
    echo -e "${WHITE}6.${NC} Return to main menu"
    
    echo -e "\n${YELLOW}Select an option:${NC}"
    read -p "▶ " backup_choice
    
    case $backup_choice in
        1)
            echo -e "${YELLOW}Creating full system backup...${NC}"
            /root/scripts/backup_system.sh
            ;;
        2)
            echo -e "${YELLOW}Creating cPanel accounts backup...${NC}"
            /scripts/pkgacct --all
            ;;
        3)
            echo -e "${WHITE}Available backups:${NC}"
            ls -la /root/backups/ 2>/dev/null || echo "No backups found"
            ;;
        4)
            echo -e "${YELLOW}Backup restoration requires manual intervention${NC}"
            echo -e "${WHITE}Backup location: /root/backups/${NC}"
            ;;
        5)
            echo -e "${YELLOW}Cleaning backups older than 7 days...${NC}"
            find /root/backups -type f -mtime +7 -delete
            success_msg "Old backups cleaned"
            ;;
        6)
            return
            ;;
        *)
            error_msg "Invalid option"
            ;;
    esac
    
    echo -e "\n${CYAN}Press Enter to continue...${NC}"
    read
}

# Main Menu Function
show_main_menu() {
    while true; do
        clear
        echo -e "${BLUE}┌────────────────────────────────────────────────────────┐${NC}"
        echo -e "${BLUE}│${GREEN}           Enhanced Server Management Console           ${BLUE}│${NC}"
        echo -e "${BLUE}│${WHITE}                  Main Menu Options                     ${BLUE}│${NC}"
        echo -e "${BLUE}└────────────────────────────────────────────────────────┘${NC}"
        
        echo -e "\n${WHITE}1.${NC} System Information"
        echo -e "${WHITE}2.${NC} Service Status"
        echo -e "${WHITE}3.${NC} Security Status"
        echo -e "${WHITE}4.${NC} Performance Monitor"
        echo -e "${WHITE}5.${NC} Backup Management"
        echo -e "${WHITE}6.${NC} Quick Health Check"
        echo -e "${WHITE}7.${NC} View System Logs"
        echo -e "${WHITE}8.${NC} Restart Services"
        echo -e "${WHITE}9.${NC} Exit"
        
        echo -e "\n${YELLOW}Select an option (1-9):${NC}"
        read -p "▶ " choice
        
        case $choice in
            1)
                show_system_info
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read
                ;;
            2)
                show_services_status
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read
                ;;
            3)
                show_security_status
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read
                ;;
            4)
                show_performance
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read
                ;;
            5)
                manage_backups
                ;;
            6)
                echo -e "${YELLOW}Running quick health check...${NC}"
                /root/scripts/system_monitor.sh 2>/dev/null || echo "Monitor script not found"
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read
                ;;
            7)
                clear
                echo -e "${WHITE}Recent system logs:${NC}"
                tail -20 /var/log/messages 2>/dev/null || echo "Log file not accessible"
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read
                ;;
            8)
                echo -e "${YELLOW}Restarting core services...${NC}"
                systemctl restart httpd mysql exim named sshd
                success_msg "Services restarted"
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read
                ;;
            9)
                echo -e "${GREEN}Thank you for using EasycPanel Enhanced Console!${NC}"
                echo -e "${CYAN}Created by: Saud Hezam | saudhezam.com${NC}"
                exit 0
                ;;
            *)
                error_msg "Invalid option. Please select 1-9."
                sleep 2
                ;;
        esac
    done
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    error_msg "This console must be run as root!"
    exit 1
fi

# Start the main menu
show_main_menu
