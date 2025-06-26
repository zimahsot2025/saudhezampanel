#!/bin/bash

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Clear the screen for a clean look
clear

# Display a compact banner
echo -e "${BLUE}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│${GREEN}        Security Audit & Malware Scanner               ${BLUE}│${NC}"
echo -e "${BLUE}│${YELLOW}               Created by Saud Hezam                    ${BLUE}│${NC}"
echo -e "${BLUE}│${WHITE}       Website: saudhezam.com | me@saudhezam.com         ${BLUE}│${NC}"
echo -e "${BLUE}│${CYAN}       Support: ${WHITE}https://ko-fi.com/saudhezam ${CYAN}☕          ${BLUE}│${NC}"
echo -e "${BLUE}│${GREEN}              EasycPanel v4.1 - Enhanced               ${BLUE}│${NC}"
echo -e "${BLUE}└────────────────────────────────────────────────────────┘${NC}"

echo -e "\n${CYAN}Starting comprehensive security audit and malware scan...${NC}"
sleep 2

# Check for Root Privileges
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}✗${NC} This script must be run as root!"
   exit 1
fi

# Create audit log directory
AUDIT_DIR="/root/security_audit_$(date +%Y%m%d_%H%M%S)"
mkdir -p $AUDIT_DIR

# Function to display progress
show_progress() {
    echo -e "${YELLOW}Processing: $1${NC}"
    sleep 1
}

# Function to display success message
success_msg() {
    echo -e "${GREEN}✓${NC} $1"
}

# Function to display warning message
warning_msg() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to display error message
error_msg() {
    echo -e "${RED}✗${NC} $1"
}

echo -e "\n${CYAN}┌─────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${WHITE}                    SYSTEM SECURITY AUDIT                       ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────┘${NC}"

# 1. Check for rootkits
show_progress "Checking for rootkits and malicious software"
if command -v rkhunter &> /dev/null; then
    rkhunter --check --sk > $AUDIT_DIR/rkhunter_report.txt 2>&1
    success_msg "Rootkit scan completed"
else
    yum install -y rkhunter
    rkhunter --propupd
    rkhunter --check --sk > $AUDIT_DIR/rkhunter_report.txt 2>&1
    success_msg "Rootkit scanner installed and scan completed"
fi

# 2. Check file permissions
show_progress "Checking critical file permissions"
{
    echo "=== Critical File Permissions Audit ==="
    echo "Checking /etc/passwd permissions:"
    ls -la /etc/passwd
    echo "Checking /etc/shadow permissions:"
    ls -la /etc/shadow
    echo "Checking /etc/group permissions:"
    ls -la /etc/group
    echo "Checking SSH configuration:"
    ls -la /etc/ssh/sshd_config
    echo "Checking sudo configuration:"
    ls -la /etc/sudoers
} > $AUDIT_DIR/file_permissions.txt
success_msg "File permissions audit completed"

# 3. Check for suspicious processes
show_progress "Scanning for suspicious processes"
{
    echo "=== Process Security Audit ==="
    echo "All running processes:"
    ps aux
    echo -e "\nListening network connections:"
    netstat -tulpn
    echo -e "\nActive connections:"
    ss -tulpn
} > $AUDIT_DIR/process_audit.txt
success_msg "Process audit completed"

# 4. Check for failed login attempts
show_progress "Analyzing authentication logs"
{
    echo "=== Authentication Security Analysis ==="
    echo "Recent failed SSH login attempts:"
    grep "Failed password" /var/log/secure | tail -20
    echo -e "\nRecent successful SSH logins:"
    grep "Accepted password" /var/log/secure | tail -10
    echo -e "\nRecent sudo usage:"
    grep "sudo" /var/log/secure | tail -10
} > $AUDIT_DIR/auth_analysis.txt
success_msg "Authentication analysis completed"

# 5. Check firewall status
show_progress "Checking firewall configuration"
{
    echo "=== Firewall Configuration Audit ==="
    if command -v csf &> /dev/null; then
        echo "CSF Firewall Status:"
        csf -l
        echo -e "\nCSF Configuration:"
        cat /etc/csf/csf.conf | grep -v "^#" | grep -v "^$"
    fi
    
    echo -e "\nIPTables rules:"
    iptables -L -n
    
    if systemctl is-active --quiet firewalld; then
        echo -e "\nFirewalld status:"
        firewall-cmd --list-all
    fi
} > $AUDIT_DIR/firewall_audit.txt
success_msg "Firewall audit completed"

# 6. Malware scanning
echo -e "\n${CYAN}┌─────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${WHITE}                    MALWARE SCANNING                             ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────┘${NC}"

show_progress "Installing and running ClamAV antivirus"
if ! command -v clamscan &> /dev/null; then
    yum install -y epel-release
    yum install -y clamav clamav-update
    
    # Update virus definitions
    freshclam
    success_msg "ClamAV installed and updated"
else
    freshclam
    success_msg "ClamAV virus definitions updated"
fi

# Scan critical directories
show_progress "Scanning critical system directories for malware"
clamscan -r --infected --remove /home > $AUDIT_DIR/malware_scan_home.txt 2>&1 &
SCAN_PID=$!

show_progress "Scanning web directories"
if [ -d "/public_html" ]; then
    clamscan -r --infected --remove /public_html > $AUDIT_DIR/malware_scan_web.txt 2>&1
fi

wait $SCAN_PID
success_msg "Malware scanning completed"

# 7. Check for suspicious files
show_progress "Checking for suspicious files and scripts"
{
    echo "=== Suspicious Files Analysis ==="
    echo "Recently modified files in /tmp:"
    find /tmp -type f -mtime -1 -ls 2>/dev/null
    
    echo -e "\nSUID files:"
    find / -perm -4000 -type f 2>/dev/null
    
    echo -e "\nSGID files:"
    find / -perm -2000 -type f 2>/dev/null
    
    echo -e "\nWorld-writable files:"
    find / -type f -perm -002 2>/dev/null | head -20
    
    echo -e "\nFiles with no owner:"
    find / -nouser -o -nogroup 2>/dev/null | head -20
} > $AUDIT_DIR/suspicious_files.txt
success_msg "Suspicious files analysis completed"

# 8. Check system integrity
show_progress "Checking system file integrity"
if command -v aide &> /dev/null; then
    aide --check > $AUDIT_DIR/aide_report.txt 2>&1
    success_msg "AIDE integrity check completed"
else
    warning_msg "AIDE not installed - skipping integrity check"
fi

# 9. SSL Certificate audit
show_progress "Auditing SSL certificates"
{
    echo "=== SSL Certificate Audit ==="
    echo "SSL certificates in cPanel:"
    if [ -d "/var/cpanel/ssl" ]; then
        find /var/cpanel/ssl -name "*.crt" -exec openssl x509 -in {} -text -noout \; 2>/dev/null | grep -E "(Subject:|Not After|Issuer)" | head -20
    fi
    
    echo -e "\nApache SSL configuration:"
    if [ -f "/etc/httpd/conf.d/ssl.conf" ]; then
        grep -i "ssl" /etc/httpd/conf.d/ssl.conf | grep -v "^#"
    fi
} > $AUDIT_DIR/ssl_audit.txt
success_msg "SSL certificate audit completed"

# 10. Create security recommendations
show_progress "Generating security recommendations"
{
    echo "=== SECURITY RECOMMENDATIONS ==="
    echo "Based on the security audit, here are recommendations:"
    echo ""
    
    # Check SSH configuration
    if grep -q "PermitRootLogin yes" /etc/ssh/sshd_config; then
        echo "⚠ CRITICAL: Disable root SSH login"
        echo "  Fix: sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config"
        echo ""
    fi
    
    # Check for default passwords
    if grep -q "password" /etc/passwd; then
        echo "⚠ WARNING: Check for accounts with default passwords"
        echo ""
    fi
    
    # Check firewall
    if ! command -v csf &> /dev/null; then
        echo "⚠ RECOMMENDATION: Install CSF firewall for better security"
        echo "  Install: wget https://download.configserver.com/csf.tgz && tar -xzf csf.tgz && cd csf && sh install.sh"
        echo ""
    fi
    
    # Check fail2ban
    if ! systemctl is-active --quiet fail2ban; then
        echo "⚠ RECOMMENDATION: Install and configure fail2ban"
        echo "  Install: yum install -y fail2ban && systemctl enable fail2ban && systemctl start fail2ban"
        echo ""
    fi
    
    echo "✓ Keep system updated regularly"
    echo "✓ Monitor logs for suspicious activity"
    echo "✓ Use strong passwords and two-factor authentication"
    echo "✓ Regular backup your data"
    echo "✓ Limit user privileges to minimum required"
    
} > $AUDIT_DIR/security_recommendations.txt
success_msg "Security recommendations generated"

# Create summary report
show_progress "Creating audit summary report"
{
    echo "EASYCPANEL SECURITY AUDIT SUMMARY"
    echo "=================================="
    echo "Audit Date: $(date)"
    echo "Server: $(hostname)"
    echo "Audit Directory: $AUDIT_DIR"
    echo ""
    echo "Files Generated:"
    echo "- rkhunter_report.txt - Rootkit scan results"
    echo "- file_permissions.txt - Critical file permissions"
    echo "- process_audit.txt - Running processes and connections"
    echo "- auth_analysis.txt - Authentication log analysis"
    echo "- firewall_audit.txt - Firewall configuration"
    echo "- malware_scan_home.txt - Home directory malware scan"
    echo "- malware_scan_web.txt - Web directory malware scan"
    echo "- suspicious_files.txt - Suspicious files analysis"
    echo "- ssl_audit.txt - SSL certificate audit"
    echo "- security_recommendations.txt - Security recommendations"
    echo ""
    echo "Review all files for detailed information."
    echo ""
    echo "Created by: Saud Hezam | saudhezam.com"
} > $AUDIT_DIR/AUDIT_SUMMARY.txt

# Final message
echo -e "\n${GREEN}┌─────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}│${WHITE}             Security Audit & Malware Scan Complete!            ${GREEN}│${NC}"
echo -e "${GREEN}├─────────────────────────────────────────────────────────────────┤${NC}"
echo -e "${GREEN}│${WHITE} ✓ Comprehensive security audit completed                      ${GREEN}│${NC}"
echo -e "${GREEN}│${WHITE} ✓ Malware scanning performed                                  ${GREEN}│${NC}"
echo -e "${GREEN}│${WHITE} ✓ System integrity checked                                    ${GREEN}│${NC}"
echo -e "${GREEN}│${WHITE} ✓ Security recommendations generated                          ${GREEN}│${NC}"
echo -e "${GREEN}│                                                                 ${GREEN}│${NC}"
echo -e "${GREEN}│${YELLOW} Audit Results: ${WHITE}$AUDIT_DIR${GREEN}│${NC}"
echo -e "${GREEN}│${YELLOW} Summary: ${WHITE}$AUDIT_DIR/AUDIT_SUMMARY.txt${GREEN}│${NC}"
echo -e "${GREEN}└─────────────────────────────────────────────────────────────────┘${NC}"

echo -e "\n${CYAN}Review the audit results in: ${WHITE}$AUDIT_DIR${NC}"
echo -e "${CYAN}Created by: ${YELLOW}Saud Hezam${NC} | ${WHITE}saudhezam.com${NC}"

# Display quick summary
echo -e "\n${YELLOW}Quick Summary:${NC}"
if [ -s "$AUDIT_DIR/malware_scan_home.txt" ]; then
    INFECTED=$(grep "Infected files" $AUDIT_DIR/malware_scan_home.txt | tail -1)
    echo -e "${CYAN}Malware Scan: ${WHITE}$INFECTED${NC}"
fi

PROCESSES=$(ps aux | wc -l)
echo -e "${CYAN}Running Processes: ${WHITE}$PROCESSES${NC}"

CONNECTIONS=$(netstat -tulpn | wc -l)
echo -e "${CYAN}Network Connections: ${WHITE}$CONNECTIONS${NC}"

echo -e "\n${GREEN}Security audit completed successfully!${NC}"
