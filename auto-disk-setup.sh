#!/bin/bash

# Auto Disk Setup Integration for Fresh Installations
# Created by Saud Hezam | saudhezam.com
# EasycPanel v4.1 - Hetzner Integration

# This script is called during fresh installations to handle disk setup
# CRITICAL: This prevents data loss on Hetzner servers by ensuring all disks are mounted

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${RED}════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${RED}                           🚨 HETZNER DISK SETUP REQUIRED 🚨                      ${NC}"
echo -e "${RED}════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Hetzner servers require all disks to be mounted before cPanel installation!${NC}"
echo -e "${YELLOW}This script ensures all available disks are properly configured and mounted.${NC}"
echo -e "${RED}════════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Function to display messages
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

# Function to check if we're on a Hetzner server
detect_hetzner() {
    # Check for Hetzner-specific indicators
    if dmidecode -s system-manufacturer 2>/dev/null | grep -qi "hetzner\|supermicro"; then
        return 0
    fi
    
    # Check hostname patterns
    if hostname | grep -E "^(static|server|dedicated)" >/dev/null 2>&1; then
        return 0
    fi
    
    # Check for multiple unmounted disks (common in Hetzner)
    UNMOUNTED_COUNT=$(lsblk -dpno NAME,TYPE | grep "disk" | grep -v "loop\|ram\|sr" | wc -l)
    if [ $UNMOUNTED_COUNT -gt 1 ]; then
        # Check if most disks are unmounted
        MOUNTED_COUNT=$(mount | grep -E "^/dev/[s|n|v]d" | wc -l)
        if [ $UNMOUNTED_COUNT -gt $MOUNTED_COUNT ]; then
            return 0
        fi
    fi
    
    return 1
}

# Function to auto-configure disks for cPanel
auto_configure_disks() {
    info_msg "Configuring disks for optimal cPanel performance..."
    
    # Get unmounted disks
    UNMOUNTED_DISKS=($(lsblk -dpno NAME,TYPE | grep "disk" | grep -v "loop\|ram\|sr" | awk '{print $1}' | while read disk; do
        if ! mount | grep -q "$disk"; then
            echo "$disk"
        fi
    done))
    
    DISK_COUNT=${#UNMOUNTED_DISKS[@]}
    
    if [ $DISK_COUNT -eq 0 ]; then
        info_msg "All disks are already mounted. Skipping disk configuration."
        return 0
    fi
    
    info_msg "Found $DISK_COUNT unmounted disks"
    
    # Auto-configure based on disk count and use case
    if [ $DISK_COUNT -eq 1 ]; then
        # Single additional disk - mount for backups/storage
        setup_single_disk "${UNMOUNTED_DISKS[0]}"
    elif [ $DISK_COUNT -eq 2 ]; then
        # Two disks - offer RAID 1 for redundancy
        setup_dual_disks "${UNMOUNTED_DISKS[@]}"
    else
        # Multiple disks - setup LVM for flexibility
        setup_multiple_disks "${UNMOUNTED_DISKS[@]}"
    fi
}

# Function to setup single additional disk
setup_single_disk() {
    local disk=$1
    info_msg "Setting up single disk: $disk"
    
    # Create partition
    parted -s $disk mklabel gpt
    parted -s $disk mkpart primary ext4 0% 100%
    
    # Wait for partition
    sleep 2
    partprobe $disk
    sleep 2
    
    # Create filesystem
    PARTITION="${disk}1"
    mkfs.ext4 -F $PARTITION
    
    # Mount for cPanel backups
    MOUNT_POINT="/backup"
    mkdir -p $MOUNT_POINT
    mount $PARTITION $MOUNT_POINT
    
    # Add to fstab
    UUID=$(blkid -s UUID -o value $PARTITION)
    echo "UUID=$UUID $MOUNT_POINT ext4 defaults,noatime 0 2" >> /etc/fstab
    
    # Set permissions for cPanel
    chown root:root $MOUNT_POINT
    chmod 755 $MOUNT_POINT
    
    success_msg "Disk mounted at $MOUNT_POINT for backups"
}

# Function to setup dual disks
setup_dual_disks() {
    local disks=("$@")
    info_msg "Setting up RAID 1 with two disks for redundancy"
    
    # Install mdadm
    yum install -y mdadm >/dev/null 2>&1
    
    # Create RAID 1 array
    mdadm --create /dev/md0 --level=1 --raid-devices=2 "${disks[@]}" --assume-clean
    
    # Wait for RAID
    sleep 5
    
    # Create filesystem
    mkfs.ext4 -F /dev/md0
    
    # Mount for data storage
    MOUNT_POINT="/home"
    mount /dev/md0 $MOUNT_POINT
    
    # Add to fstab
    echo "/dev/md0 $MOUNT_POINT ext4 defaults,noatime 0 2" >> /etc/fstab
    
    # Save RAID config
    mdadm --detail --scan >> /etc/mdadm.conf
    
    success_msg "RAID 1 array created and mounted at $MOUNT_POINT"
}

# Function to setup multiple disks
setup_multiple_disks() {
    local disks=("$@")
    info_msg "Setting up LVM with ${#disks[@]} disks"
    
    # Install LVM
    yum install -y lvm2 >/dev/null 2>&1
    
    # Create physical volumes
    for disk in "${disks[@]}"; do
        pvcreate $disk >/dev/null 2>&1
    done
    
    # Create volume group
    vgcreate cpanel_vg "${disks[@]}" >/dev/null 2>&1
    
    # Create logical volumes
    # 70% for home directories, 30% for backups
    TOTAL_SIZE=$(vgdisplay cpanel_vg | grep "VG Size" | awk '{print $3}' | cut -d'.' -f1)
    HOME_SIZE=$((TOTAL_SIZE * 70 / 100))
    BACKUP_SIZE=$((TOTAL_SIZE * 30 / 100))
    
    lvcreate -L ${HOME_SIZE}G -n home_lv cpanel_vg >/dev/null 2>&1
    lvcreate -L ${BACKUP_SIZE}G -n backup_lv cpanel_vg >/dev/null 2>&1
    
    # Create filesystems
    mkfs.ext4 -F /dev/cpanel_vg/home_lv >/dev/null 2>&1
    mkfs.ext4 -F /dev/cpanel_vg/backup_lv >/dev/null 2>&1
    
    # Mount volumes
    mount /dev/cpanel_vg/home_lv /home
    mkdir -p /backup
    mount /dev/cpanel_vg/backup_lv /backup
    
    # Add to fstab
    echo "/dev/cpanel_vg/home_lv /home ext4 defaults,noatime 0 2" >> /etc/fstab
    echo "/dev/cpanel_vg/backup_lv /backup ext4 defaults,noatime 0 2" >> /etc/fstab
    
    success_msg "LVM setup completed with separate home and backup volumes"
}

# Main execution
if detect_hetzner; then
    echo -e "\n${CYAN}┌─────────────────── Hetzner Server Detected ──────────────────────┐${NC}"
    echo -e "${CYAN}│${WHITE} Hetzner dedicated server detected!                             ${CYAN}│${NC}"
    echo -e "${CYAN}│${WHITE} Would you like to auto-configure additional disks?             ${CYAN}│${NC}"
    echo -e "${CYAN}└────────────────────────────────────────────────────────────────────┘${NC}"
    
    echo -e "\n${YELLOW}Auto-configure disks for optimal cPanel performance? (y/n):${NC}"
    read -p "▶ " auto_setup
    
    if [[ $auto_setup =~ ^[Yy]$ ]]; then
        auto_configure_disks
        
        # Create disk monitoring for cPanel
        cat > /root/scripts/cpanel_disk_monitor.sh << 'EOF'
#!/bin/bash
# cPanel-specific disk monitoring
# Check backup disk usage
BACKUP_USAGE=$(df /backup 2>/dev/null | tail -1 | awk '{print $5}' | cut -d'%' -f1)
if [ ! -z "$BACKUP_USAGE" ] && [ $BACKUP_USAGE -gt 85 ]; then
    echo "Warning: Backup disk usage is ${BACKUP_USAGE}%" | mail -s "Backup Disk Alert" admin@yourdomain.com 2>/dev/null
fi

# Check home disk usage
HOME_USAGE=$(df /home 2>/dev/null | tail -1 | awk '{print $5}' | cut -d'%' -f1)
if [ ! -z "$HOME_USAGE" ] && [ $HOME_USAGE -gt 90 ]; then
    echo "Critical: Home disk usage is ${HOME_USAGE}%" | mail -s "Home Disk Alert" admin@yourdomain.com 2>/dev/null
fi
EOF
        
        chmod +x /root/scripts/cpanel_disk_monitor.sh
        
        # Add to cron
        (crontab -l 2>/dev/null | grep -v cpanel_disk_monitor; echo "*/30 * * * * /root/scripts/cpanel_disk_monitor.sh") | crontab -
        
        success_msg "Disk configuration completed and monitoring enabled"
    else
        info_msg "Skipping automatic disk configuration"
        info_msg "You can run ./hetzner-disk-setup.sh later for manual configuration"
    fi
else
    # Not a Hetzner server, check for additional disks anyway
    UNMOUNTED_COUNT=$(lsblk -dpno NAME,TYPE | grep "disk" | grep -v "loop\|ram\|sr" | wc -l)
    MOUNTED_COUNT=$(mount | grep -E "^/dev/[s|n|v]d" | wc -l)
    
    if [ $UNMOUNTED_COUNT -gt $MOUNTED_COUNT ] && [ $UNMOUNTED_COUNT -gt 1 ]; then
        echo -e "\n${CYAN}Multiple disks detected. Run ${WHITE}./hetzner-disk-setup.sh${CYAN} for disk configuration.${NC}"
    fi
fi
