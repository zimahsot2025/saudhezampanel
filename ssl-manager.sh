#!/bin/bash

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# SSL Management Script for EasycPanel
echo -e "${BLUE}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│${GREEN}              SSL Certificate Manager                   ${BLUE}│${NC}"
echo -e "${BLUE}│${YELLOW}               Created by Saud Hezam                    ${BLUE}│${NC}"
echo -e "${BLUE}│${WHITE}       Website: saudhezam.com | me@saudhezam.com         ${BLUE}│${NC}"
echo -e "${BLUE}│${CYAN}       Support: ${WHITE}https://ko-fi.com/saudhezam ${CYAN}☕          ${BLUE}│${NC}"
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

# Install Let's Encrypt if not present
install_letsencrypt() {
    if ! command -v certbot &> /dev/null; then
        echo -e "${YELLOW}Installing Let's Encrypt (Certbot)...${NC}"
        yum install -y epel-release
        yum install -y certbot python3-certbot-apache
        success_msg "Let's Encrypt installed successfully"
    else
        success_msg "Let's Encrypt already installed"
    fi
}

# Setup auto-renewal
setup_auto_renewal() {
    echo -e "${YELLOW}Setting up SSL auto-renewal...${NC}"
    
    # Create renewal script
    cat > /root/scripts/ssl_renewal.sh << 'EOF'
#!/bin/bash
LOG_FILE="/var/log/ssl_renewal.log"
echo "[$(date)] Starting SSL renewal check" >> $LOG_FILE
certbot renew --quiet >> $LOG_FILE 2>&1
if [ $? -eq 0 ]; then
    echo "[$(date)] SSL renewal check completed successfully" >> $LOG_FILE
    systemctl reload httpd
else
    echo "[$(date)] SSL renewal failed" >> $LOG_FILE
fi
EOF
    
    chmod +x /root/scripts/ssl_renewal.sh
    
    # Add to crontab
    (crontab -l 2>/dev/null | grep -v ssl_renewal; echo "0 2 * * * /root/scripts/ssl_renewal.sh") | crontab -
    
    success_msg "SSL auto-renewal configured"
}

# Main SSL setup
main() {
    install_letsencrypt
    setup_auto_renewal
    
    echo -e "\n${GREEN}SSL Certificate Manager setup completed!${NC}"
    echo -e "${CYAN}Created by: Saud Hezam | saudhezam.com${NC}"
}

main
