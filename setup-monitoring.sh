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
echo -e "${BLUE}│${GREEN}        Advanced Monitoring & Backup Setup             ${BLUE}│${NC}"
echo -e "${BLUE}│${YELLOW}               Created by Saud Hezam                    ${BLUE}│${NC}"
echo -e "${BLUE}│${WHITE}       Website: saudhezam.com | me@saudhezam.com         ${BLUE}│${NC}"
echo -e "${BLUE}│${CYAN}       Support: ${WHITE}https://ko-fi.com/saudhezam ${CYAN}☕          ${BLUE}│${NC}"
echo -e "${BLUE}│${GREEN}              EasycPanel v4.1 - Enhanced               ${BLUE}│${NC}"
echo -e "${BLUE}└────────────────────────────────────────────────────────┘${NC}"

echo -e "\n${CYAN}Setting up advanced monitoring and backup system...${NC}"
sleep 2

# Check for Root Privileges
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}✗${NC} This script must be run as root!"
   exit 1
fi

# Function to display progress
show_progress() {
    echo -e "${YELLOW}Processing: $1${NC}"
    sleep 1
}

# Function to display success message
success_msg() {
    echo -e "${GREEN}✓${NC} $1"
}

# Function to display error message
error_msg() {
    echo -e "${RED}✗${NC} $1"
}

# Install monitoring tools
show_progress "Installing system monitoring tools"
yum install -y htop iotop nethogs iftop sysstat || {
    error_msg "Failed to install monitoring tools"
    exit 1
}
success_msg "System monitoring tools installed"

# Install and configure fail2ban
show_progress "Installing and configuring fail2ban"
yum install -y epel-release
yum install -y fail2ban

# Create fail2ban configuration
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
# Ban hosts for 24 hours
bantime = 86400
# A host is banned after 3 failed attempts
maxretry = 3
# Check for failed attempts every 10 minutes
findtime = 600

[sshd]
enabled = true
port = ssh
logpath = /var/log/secure
maxretry = 3

[cpanel]
enabled = true
port = 2083,2087
logpath = /usr/local/cpanel/logs/access_log
maxretry = 3

[exim]
enabled = true
port = smtp,465,submission
logpath = /var/log/exim_mainlog

[apache-auth]
enabled = true
port = http,https
logpath = /usr/local/apache/logs/error_log

[apache-badbots]
enabled = true
port = http,https
logpath = /usr/local/apache/logs/access_log
EOF

systemctl enable fail2ban
systemctl start fail2ban
success_msg "Fail2ban installed and configured"

# Setup backup system
show_progress "Setting up automated backup system"

# Create backup directory
mkdir -p /root/backups/{daily,weekly,monthly}
mkdir -p /root/scripts

# Create backup script
cat > /root/scripts/backup_system.sh << 'EOF'
#!/bin/bash

# Backup configuration
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/root/backups/daily"
LOG_FILE="/var/log/easycpanel_backup.log"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
    echo "$1"
}

log_message "Starting backup process"

# Backup cPanel accounts
log_message "Backing up cPanel accounts"
/scripts/pkgacct --skiphomedir --skipbwdata --skipbwdata cpanelusername > /dev/null 2>&1

# Backup system configurations
log_message "Backing up system configurations"
tar -czf $BACKUP_DIR/system_config_$BACKUP_DATE.tar.gz \
    /etc/httpd/conf* \
    /etc/my.cnf* \
    /etc/php.ini \
    /usr/local/cpanel/cpanel.config \
    /var/cpanel/easy_config_snapshot.yaml \
    /etc/csf/ \
    /etc/fail2ban/ \
    2>/dev/null

# Backup databases
log_message "Backing up databases"
mysqldump --all-databases --single-transaction --routines --triggers > $BACKUP_DIR/all_databases_$BACKUP_DATE.sql

# Clean old backups (keep 7 days)
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete

log_message "Backup process completed"
EOF

chmod +x /root/scripts/backup_system.sh
success_msg "Backup system configured"

# Setup monitoring script
show_progress "Creating system monitoring script"

cat > /root/scripts/system_monitor.sh << 'EOF'
#!/bin/bash

# System monitoring script
LOG_FILE="/var/log/easycpanel_monitor.log"
ALERT_EMAIL="admin@yourdomain.com"

# Function to log and alert
log_alert() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ALERT: $1" >> $LOG_FILE
    echo "ALERT: $1" | mail -s "Server Alert - $(hostname)" $ALERT_EMAIL 2>/dev/null
}

# Check disk usage
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 85 ]; then
    log_alert "Disk usage is ${DISK_USAGE}% - High disk usage detected"
fi

# Check memory usage
MEM_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
if [ $MEM_USAGE -gt 90 ]; then
    log_alert "Memory usage is ${MEM_USAGE}% - High memory usage detected"
fi

# Check load average
LOAD_AVG=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | sed 's/^[ \t]*//')
LOAD_LIMIT=4
if (( $(echo "$LOAD_AVG > $LOAD_LIMIT" | bc -l) )); then
    log_alert "Load average is $LOAD_AVG - High server load detected"
fi

# Check important services
SERVICES=("httpd" "mysql" "exim" "named" "sshd" "cpanel")
for service in "${SERVICES[@]}"; do
    if ! systemctl is-active --quiet $service; then
        log_alert "Service $service is not running"
    fi
done

# Check for failed login attempts
FAILED_LOGINS=$(tail -50 /var/log/secure | grep "Failed password" | wc -l)
if [ $FAILED_LOGINS -gt 10 ]; then
    log_alert "High number of failed login attempts detected: $FAILED_LOGINS"
fi
EOF

chmod +x /root/scripts/system_monitor.sh
success_msg "System monitoring script created"

# Setup cron jobs
show_progress "Setting up automated tasks"

# Add cron jobs
(crontab -l 2>/dev/null; echo "# EasycPanel Automated Tasks") | crontab -
(crontab -l 2>/dev/null; echo "0 2 * * * /root/scripts/backup_system.sh") | crontab -
(crontab -l 2>/dev/null; echo "*/15 * * * * /root/scripts/system_monitor.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 0 * * 0 /scripts/upcp --force") | crontab -

success_msg "Automated tasks configured"

# Install Redis for caching
show_progress "Installing Redis for enhanced caching"
yum install -y redis
systemctl enable redis
systemctl start redis

# Configure Redis
sed -i 's/^# maxmemory <bytes>/maxmemory 256mb/' /etc/redis.conf
sed -i 's/^# maxmemory-policy noeviction/maxmemory-policy allkeys-lru/' /etc/redis.conf
systemctl restart redis

success_msg "Redis caching system installed"

# Setup log rotation
show_progress "Configuring log rotation"
cat > /etc/logrotate.d/easycpanel << 'EOF'
/var/log/easycpanel_*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
}
EOF

success_msg "Log rotation configured"

# Final message
echo -e "\n${GREEN}┌─────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}│${WHITE}             Monitoring & Backup Setup Complete!                ${GREEN}│${NC}"
echo -e "${GREEN}├─────────────────────────────────────────────────────────────────┤${NC}"
echo -e "${GREEN}│${WHITE} ✓ Fail2ban intrusion prevention system installed              ${GREEN}│${NC}"
echo -e "${GREEN}│${WHITE} ✓ Automated backup system configured                           ${GREEN}│${NC}"
echo -e "${GREEN}│${WHITE} ✓ System monitoring with alerts enabled                       ${GREEN}│${NC}"
echo -e "${GREEN}│${WHITE} ✓ Redis caching system installed                              ${GREEN}│${NC}"
echo -e "${GREEN}│${WHITE} ✓ Log rotation configured                                     ${GREEN}│${NC}"
echo -e "${GREEN}│                                                                 ${GREEN}│${NC}"
echo -e "${GREEN}│${YELLOW} Backup Location: ${WHITE}/root/backups/                              ${GREEN}│${NC}"
echo -e "${GREEN}│${YELLOW} Monitor Logs: ${WHITE}/var/log/easycpanel_monitor.log                ${GREEN}│${NC}"
echo -e "${GREEN}│${YELLOW} Backup Logs: ${WHITE}/var/log/easycpanel_backup.log                 ${GREEN}│${NC}"
echo -e "${GREEN}└─────────────────────────────────────────────────────────────────┘${NC}"

echo -e "\n${CYAN}Please configure the alert email in ${WHITE}/root/scripts/system_monitor.sh${NC}"
echo -e "${CYAN}Created by: ${YELLOW}Saud Hezam${NC} | ${WHITE}saudhezam.com${NC}"
