#!/bin/bash

# Enhanced Security Configuration Script
# Created by Saud Hezam | saudhezam.com
# EasycPanel v4.1 - Enhanced Security Features

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${BLUE}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│${GREEN}           Enhanced Security Configuration              ${BLUE}│${NC}"
echo -e "${BLUE}│${YELLOW}               Created by Saud Hezam                    ${BLUE}│${NC}"
echo -e "${BLUE}│${WHITE}       Website: saudhezam.com | me@saudhezam.com         ${BLUE}│${NC}"
echo -e "${BLUE}│${CYAN}       Support: ${WHITE}https://ko-fi.com/saudhezam ${CYAN}☕          ${BLUE}│${NC}"
echo -e "${BLUE}│${GREEN}              EasycPanel v4.1 - Enhanced               ${BLUE}│${NC}"
echo -e "${BLUE}└────────────────────────────────────────────────────────┘${NC}"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}✗${NC} This script must be run as root!"
    exit 1
fi

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

# 1. Advanced CSF Configuration
configure_advanced_csf() {
    info_msg "Configuring advanced CSF firewall settings..."
    
    if [ ! -f "/etc/csf/csf.conf" ]; then
        error_msg "CSF not found. Please install CSF first."
        return 1
    fi
    
    # Backup original configuration
    cp /etc/csf/csf.conf /etc/csf/csf.conf.bak
    
    # Advanced CSF settings
    sed -i 's/^TESTING = "1"/TESTING = "0"/' /etc/csf/csf.conf
    sed -i 's/^CT_LIMIT = "0"/CT_LIMIT = "100"/' /etc/csf/csf.conf
    sed -i 's/^CT_INTERVAL = "0"/CT_INTERVAL = "30"/' /etc/csf/csf.conf
    sed -i 's/^CT_BLOCK_TIME = "0"/CT_BLOCK_TIME = "1800"/' /etc/csf/csf.conf
    sed -i 's/^PS_LIMIT = "0"/PS_LIMIT = "15"/' /etc/csf/csf.conf
    sed -i 's/^PS_INTERVAL = "0"/PS_INTERVAL = "300"/' /etc/csf/csf.conf
    sed -i 's/^PS_BLOCK_TIME = "0"/PS_BLOCK_TIME = "3600"/' /etc/csf/csf.conf
    
    # Enable SYN flood protection
    sed -i 's/^SYNFLOOD = "0"/SYNFLOOD = "1"/' /etc/csf/csf.conf
    sed -i 's/^SYNFLOOD_RATE = "100\/s"/SYNFLOOD_RATE = "50\/s"/' /etc/csf/csf.conf
    sed -i 's/^SYNFLOOD_BURST = "150"/SYNFLOOD_BURST = "100"/' /etc/csf/csf.conf
    
    # Enable connection tracking
    sed -i 's/^CONNLIMIT = ""/CONNLIMIT = "22;5,80;50,443;50"/' /etc/csf/csf.conf
    
    success_msg "Advanced CSF configuration completed"
}

# 2. Enhanced SSH Security
configure_ssh_security() {
    info_msg "Configuring enhanced SSH security..."
    
    # Backup SSH config
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    
    # SSH hardening
    cat >> /etc/ssh/sshd_config << 'EOF'

# Enhanced SSH Security Configuration - EasycPanel v4.1
# Added by Saud Hezam

# Disable root login (if not already disabled)
PermitRootLogin no

# Change default port (uncomment and change as needed)
# Port 2200

# Protocol version
Protocol 2

# Authentication settings
MaxAuthTries 3
MaxStartups 10:30:60
LoginGraceTime 30

# Key-based authentication
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# Disable password authentication (enable only after setting up key-based auth)
# PasswordAuthentication no

# Disable empty passwords
PermitEmptyPasswords no

# Disable X11 forwarding
X11Forwarding no

# Disable user environment
PermitUserEnvironment no

# Use strong ciphers
Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr

# Strong MACs
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512

# Strong Key Exchange
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512

# Log level
LogLevel VERBOSE

# Banner
Banner /etc/ssh/ssh_banner
EOF

    # Create SSH banner
    cat > /etc/ssh/ssh_banner << 'EOF'
***********************************************************************
*                                                                     *
*  This system is for authorized users only. All activity may be     *
*  monitored and recorded. By using this system, you acknowledge     *
*  that you have read and understand these terms.                    *
*                                                                     *
*  Server secured by EasycPanel v4.1                                 *
*  Created by: Saud Hezam | saudhezam.com                            *
*                                                                     *
***********************************************************************
EOF

    success_msg "Enhanced SSH security configured"
}

# 3. Advanced ModSecurity Rules
configure_modsecurity() {
    info_msg "Configuring advanced ModSecurity rules..."
    
    # Create custom ModSecurity rules directory
    mkdir -p /usr/local/apache/conf/modsec_custom
    
    # Custom rules for enhanced protection
    cat > /usr/local/apache/conf/modsec_custom/easycpanel_rules.conf << 'EOF'
# EasycPanel v4.1 Enhanced ModSecurity Rules
# Created by Saud Hezam

# Anti-automation rules
SecRule REQUEST_HEADERS:User-Agent "@detectSQLi" \
    "id:1001,\
    phase:1,\
    block,\
    msg:'SQL Injection Attack in User-Agent',\
    logdata:'Matched Data: %{MATCHED_VAR} found within %{MATCHED_VAR_NAME}',\
    tag:'attack-sqli',\
    severity:'CRITICAL'"

# Enhanced XSS protection
SecRule ARGS "@detectXSS" \
    "id:1002,\
    phase:2,\
    block,\
    msg:'XSS Attack Detected in Arguments',\
    logdata:'Matched Data: %{MATCHED_VAR} found within %{MATCHED_VAR_NAME}',\
    tag:'attack-xss',\
    severity:'CRITICAL'"

# File upload restrictions
SecRule FILES_TMPNAMES "@detectSQLi" \
    "id:1003,\
    phase:2,\
    block,\
    msg:'SQL Injection in uploaded file',\
    tag:'attack-sqli',\
    severity:'CRITICAL'"

# Rate limiting
SecAction \
    "id:1004,\
    phase:1,\
    nolog,\
    pass,\
    initcol:ip=%{remote_addr},\
    setvar:ip.requests_per_min=+1,\
    expirevar:ip.requests_per_min=60"

SecRule IP:REQUESTS_PER_MIN "@gt 120" \
    "id:1005,\
    phase:1,\
    block,\
    msg:'Rate limiting: too many requests',\
    tag:'rate-limit',\
    severity:'WARNING'"

# Geolocation blocking (example for high-risk countries)
SecGeoLookupDB /usr/share/GeoIP/GeoLite2-Country.mmdb
SecRule GEO:COUNTRY_CODE "@pmFromFile /usr/local/apache/conf/modsec_custom/blocked_countries.txt" \
    "id:1006,\
    phase:1,\
    block,\
    msg:'Request from blocked country: %{GEO.COUNTRY_CODE}',\
    tag:'geo-blocking'"
EOF

    # Create blocked countries list (example)
    cat > /usr/local/apache/conf/modsec_custom/blocked_countries.txt << 'EOF'
# Add country codes to block (example)
# CN
# RU
# KP
EOF

    success_msg "Advanced ModSecurity rules configured"
}

# 4. Implement Real-time Malware Scanning
setup_realtime_scanning() {
    info_msg "Setting up real-time malware scanning..."
    
    # Install inotify-tools for real-time monitoring
    yum install -y inotify-tools
    
    # Create real-time scanner script
    cat > /root/scripts/realtime_scanner.sh << 'EOF'
#!/bin/bash

# Real-time malware scanner for web directories
# Created by Saud Hezam

LOG_FILE="/var/log/realtime_scanner.log"
SCAN_DIRS="/home /var/www /public_html"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}

# Function to scan file
scan_file() {
    local file="$1"
    log_message "Scanning new/modified file: $file"
    
    # Check for malicious patterns
    if grep -l "eval.*base64\|system.*\$_\|passthru.*\$_\|exec.*\$_" "$file" 2>/dev/null; then
        log_message "ALERT: Suspicious PHP code detected in $file"
        # Quarantine the file
        mkdir -p /quarantine
        mv "$file" "/quarantine/$(basename $file).$(date +%s)"
        log_message "File quarantined: $file"
        
        # Send alert email
        echo "Malicious file detected and quarantined: $file" | mail -s "Security Alert - $(hostname)" admin@yourdomain.com 2>/dev/null
    fi
    
    # ClamAV scan
    if command -v clamscan &> /dev/null; then
        SCAN_RESULT=$(clamscan --no-summary "$file" 2>/dev/null)
        if echo "$SCAN_RESULT" | grep -q "FOUND"; then
            log_message "ALERT: Virus detected in $file"
            mkdir -p /quarantine
            mv "$file" "/quarantine/$(basename $file).virus.$(date +%s)"
            log_message "Infected file quarantined: $file"
        fi
    fi
}

# Monitor directories
for dir in $SCAN_DIRS; do
    if [ -d "$dir" ]; then
        inotifywait -m -r -e create,modify,moved_to --format '%w%f' "$dir" |
        while read file; do
            # Skip temporary files and directories
            if [[ ! "$file" =~ \.(tmp|swp|log)$ ]] && [ -f "$file" ]; then
                scan_file "$file"
            fi
        done &
    fi
done

log_message "Real-time scanner started for directories: $SCAN_DIRS"
wait
EOF

    chmod +x /root/scripts/realtime_scanner.sh
    
    # Create systemd service for real-time scanner
    cat > /etc/systemd/system/realtime-scanner.service << 'EOF'
[Unit]
Description=Real-time Malware Scanner
After=network.target

[Service]
Type=simple
User=root
ExecStart=/root/scripts/realtime_scanner.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable realtime-scanner
    systemctl start realtime-scanner
    
    success_msg "Real-time malware scanning enabled"
}

# 5. Enhanced Logging and Monitoring
setup_enhanced_logging() {
    info_msg "Setting up enhanced logging and monitoring..."
    
    # Configure rsyslog for centralized logging
    cat >> /etc/rsyslog.conf << 'EOF'

# EasycPanel Enhanced Logging Configuration
# Created by Saud Hezam

# Security events
auth,authpriv.*                                 /var/log/auth.log
mail.*                                          /var/log/mail.log
cron.*                                          /var/log/cron.log

# Apache logs
local0.*                                        /var/log/apache_security.log
local1.*                                        /var/log/apache_access.log

# Custom application logs
local7.*                                        /var/log/easycpanel.log
EOF

    # Restart rsyslog
    systemctl restart rsyslog
    
    # Create log analysis script
    cat > /root/scripts/log_analyzer.sh << 'EOF'
#!/bin/bash

# Log analyzer for security events
# Created by Saud Hezam

LOG_FILE="/var/log/log_analysis.log"
ALERT_EMAIL="admin@yourdomain.com"

analyze_logs() {
    local today=$(date +%b\ %d)
    
    # Check for SSH attacks
    SSH_ATTACKS=$(grep "$today" /var/log/secure | grep "Failed password" | wc -l)
    if [ $SSH_ATTACKS -gt 20 ]; then
        echo "HIGH: $SSH_ATTACKS failed SSH login attempts today" >> $LOG_FILE
        echo "Alert: High number of SSH attacks detected ($SSH_ATTACKS)" | mail -s "Security Alert - SSH" $ALERT_EMAIL 2>/dev/null
    fi
    
    # Check for web attacks
    if [ -f "/usr/local/apache/logs/error_log" ]; then
        WEB_ATTACKS=$(grep "$today" /usr/local/apache/logs/error_log | grep -E "(XSS|SQL|injection)" | wc -l)
        if [ $WEB_ATTACKS -gt 10 ]; then
            echo "HIGH: $WEB_ATTACKS web attack attempts today" >> $LOG_FILE
            echo "Alert: High number of web attacks detected ($WEB_ATTACKS)" | mail -s "Security Alert - Web" $ALERT_EMAIL 2>/dev/null
        fi
    fi
    
    # Check for unusual cPanel activity
    CPANEL_ERRORS=$(grep "$today" /usr/local/cpanel/logs/error_log | wc -l)
    if [ $CPANEL_ERRORS -gt 50 ]; then
        echo "WARNING: $CPANEL_ERRORS cPanel errors today" >> $LOG_FILE
    fi
}

analyze_logs
EOF

    chmod +x /root/scripts/log_analyzer.sh
    
    # Add to crontab for hourly analysis
    (crontab -l 2>/dev/null | grep -v log_analyzer; echo "0 * * * * /root/scripts/log_analyzer.sh") | crontab -
    
    success_msg "Enhanced logging and monitoring configured"
}

# Main execution
echo -e "\n${YELLOW}Starting enhanced security configuration...${NC}"
sleep 2

configure_advanced_csf
configure_ssh_security
configure_modsecurity
setup_realtime_scanning
setup_enhanced_logging

echo -e "\n${GREEN}┌─────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}│${WHITE}             Enhanced Security Configuration Complete!          ${GREEN}│${NC}"
echo -e "${GREEN}├─────────────────────────────────────────────────────────────────┤${NC}"
echo -e "${GREEN}│${WHITE} ✓ Advanced CSF firewall rules configured                      ${GREEN}│${NC}"
echo -e "${GREEN}│${WHITE} ✓ Enhanced SSH security implemented                           ${GREEN}│${NC}"
echo -e "${GREEN}│${WHITE} ✓ Advanced ModSecurity rules added                            ${GREEN}│${NC}"
echo -e "${GREEN}│${WHITE} ✓ Real-time malware scanning enabled                          ${GREEN}│${NC}"
echo -e "${GREEN}│${WHITE} ✓ Enhanced logging and monitoring configured                  ${GREEN}│${NC}"
echo -e "${GREEN}│                                                                 ${GREEN}│${NC}"
echo -e "${GREEN}│${YELLOW} Important: Configure email alerts and review settings          ${GREEN}│${NC}"
echo -e "${GREEN}└─────────────────────────────────────────────────────────────────┘${NC}"

echo -e "\n${CYAN}Enhanced security configuration completed successfully!${NC}"
echo -e "${CYAN}Created by: ${YELLOW}Saud Hezam${NC} | ${WHITE}saudhezam.com${NC}"

# Restart services
info_msg "Restarting services to apply changes..."
systemctl restart sshd
systemctl restart httpd
if systemctl is-active --quiet csf; then
    csf -r
fi

success_msg "All services restarted successfully"
