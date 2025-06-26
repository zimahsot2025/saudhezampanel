#!/bin/bash

# Hetzner Disk Auto-Mount and Setup Script
# Created by Saud Hezam | saudhezam.com
# EasycPanel v4.1 - Enhanced Disk Management

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Clear the screen
clear

# Display CRITICAL importance message
echo -e "${RED}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║                              🚨 CRITICAL NOTICE 🚨                             ║${NC}"
echo -e "${RED}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${RED}║                                                                                ║${NC}"
echo -e "${RED}║   ⚠️  HETZNER SERVERS REQUIRE THIS DISK SETUP TO PREVENT DATA LOSS!           ║${NC}"
echo -e "${RED}║                                                                                ║${NC}"
echo -e "${RED}║   🔍 Issue: Hetzner doesn't auto-mount additional disks during OS install     ║${NC}"
echo -e "${RED}║   💾 Result: Extra disks remain unmounted and unusable                        ║${NC}"
echo -e "${RED}║   ⚡ Solution: This script automatically detects and mounts ALL disks         ║${NC}"
echo -e "${RED}║                                                                                ║${NC}"
echo -e "${RED}║   ✅ This script will:                                                         ║${NC}"
echo -e "${RED}║      • Detect all available disks                                             ║${NC}"
echo -e "${RED}║      • Create optimal partitions                                              ║${NC}"
echo -e "${RED}║      • Setup LVM/RAID configuration                                           ║${NC}"
echo -e "${RED}║      • Mount all disks properly                                               ║${NC}"
echo -e "${RED}║      • Configure automatic mounting                                           ║${NC}"
echo -e "${RED}║      • Setup disk monitoring                                                  ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
sleep 3

echo -e "${BLUE}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│${GREEN}        Hetzner Disk Auto-Mount & Setup System         ${BLUE}│${NC}"
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

# Function to detect all available disks
detect_disks() {
    info_msg "Detecting available disks..."
    
    # Get all block devices excluding loop, ram, and sr devices
    AVAILABLE_DISKS=$(lsblk -dpno NAME,SIZE,TYPE | grep "disk" | grep -v "loop\|ram\|sr" | awk '{print $1}')
    
    if [ -z "$AVAILABLE_DISKS" ]; then
        error_msg "No disks found!"
        exit 1
    fi
    
    echo -e "\n${CYAN}┌─────────────────── Available Disks ──────────────────────┐${NC}"
    echo -e "${CYAN}│${WHITE} Disk Device    │ Size      │ Type    │ Mount Status    ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────── ──────────── ──────── ─────────────────┤${NC}"
    
    DISK_COUNT=0
    declare -a UNMOUNTED_DISKS
    
    for disk in $AVAILABLE_DISKS; do
        SIZE=$(lsblk -dno SIZE $disk)
        TYPE=$(lsblk -dno TYPE $disk)
        
        # Check if disk is mounted
        if mount | grep -q "$disk"; then
            MOUNT_STATUS="${GREEN}Mounted${NC}"
        else
            MOUNT_STATUS="${RED}Not Mounted${NC}"
            UNMOUNTED_DISKS+=("$disk")
            ((DISK_COUNT++))
        fi
        
        printf "${CYAN}│${WHITE} %-13s │ %-9s │ %-7s │ %-15s ${CYAN}│${NC}\n" "$disk" "$SIZE" "$TYPE" "$MOUNT_STATUS"
    done
    
    echo -e "${CYAN}└──────────────────────────────────────────────────────────┘${NC}"
    
    echo -e "\n${YELLOW}Total disks found: ${WHITE}$(echo $AVAILABLE_DISKS | wc -w)${NC}"
    echo -e "${YELLOW}Unmounted disks: ${WHITE}$DISK_COUNT${NC}"
}

# Function to create partition and filesystem
setup_disk() {
    local disk=$1
    local mount_point=$2
    
    info_msg "Setting up disk: $disk"
    
    # Check if disk already has partitions
    PARTITIONS=$(lsblk -ln $disk | grep "part" | wc -l)
    
    if [ $PARTITIONS -gt 0 ]; then
        warning_msg "Disk $disk already has partitions. Skipping partitioning."
        return 1
    fi
    
    # Create partition table and partition
    info_msg "Creating partition table on $disk..."
    parted -s $disk mklabel gpt
    
    if [ $? -ne 0 ]; then
        error_msg "Failed to create partition table on $disk"
        return 1
    fi
    
    # Create primary partition using entire disk
    info_msg "Creating primary partition on $disk..."
    parted -s $disk mkpart primary ext4 0% 100%
    
    if [ $? -ne 0 ]; then
        error_msg "Failed to create partition on $disk"
        return 1
    fi
    
    # Wait for partition to be recognized
    sleep 2
    partprobe $disk
    sleep 2
    
    # Get the partition name (usually ends with 1)
    PARTITION="${disk}1"
    
    # Create filesystem
    info_msg "Creating ext4 filesystem on $PARTITION..."
    mkfs.ext4 -F $PARTITION
    
    if [ $? -ne 0 ]; then
        error_msg "Failed to create filesystem on $PARTITION"
        return 1
    fi
    
    # Create mount point
    info_msg "Creating mount point: $mount_point"
    mkdir -p $mount_point
    
    # Mount the partition
    info_msg "Mounting $PARTITION to $mount_point..."
    mount $PARTITION $mount_point
    
    if [ $? -ne 0 ]; then
        error_msg "Failed to mount $PARTITION"
        return 1
    fi
    
    # Add to fstab for permanent mounting
    UUID=$(blkid -s UUID -o value $PARTITION)
    echo "UUID=$UUID $mount_point ext4 defaults,noatime 0 2" >> /etc/fstab
    
    success_msg "Disk $disk successfully mounted at $mount_point"
    return 0
}

# Function to setup LVM for multiple disks
setup_lvm() {
    info_msg "Setting up LVM with multiple disks..."
    
    # Install LVM if not present
    if ! command -v pvcreate &> /dev/null; then
        info_msg "Installing LVM tools..."
        yum install -y lvm2
    fi
    
    # Create physical volumes
    for disk in "${UNMOUNTED_DISKS[@]}"; do
        info_msg "Creating physical volume on $disk..."
        pvcreate $disk
    done
    
    # Create volume group
    VG_NAME="hetzner_vg"
    info_msg "Creating volume group: $VG_NAME"
    vgcreate $VG_NAME "${UNMOUNTED_DISKS[@]}"
    
    # Create logical volume using all available space
    LV_NAME="data_lv"
    info_msg "Creating logical volume: $LV_NAME"
    lvcreate -l 100%FREE -n $LV_NAME $VG_NAME
    
    # Create filesystem
    LV_PATH="/dev/$VG_NAME/$LV_NAME"
    info_msg "Creating ext4 filesystem on $LV_PATH..."
    mkfs.ext4 -F $LV_PATH
    
    # Mount the logical volume
    MOUNT_POINT="/mnt/storage"
    mkdir -p $MOUNT_POINT
    mount $LV_PATH $MOUNT_POINT
    
    # Add to fstab
    echo "$LV_PATH $MOUNT_POINT ext4 defaults,noatime 0 2" >> /etc/fstab
    
    success_msg "LVM setup completed. All disks combined into $MOUNT_POINT"
}

# Function to setup RAID for multiple disks
setup_raid() {
    local raid_level=$1
    
    info_msg "Setting up RAID $raid_level with multiple disks..."
    
    # Install mdadm if not present
    if ! command -v mdadm &> /dev/null; then
        info_msg "Installing mdadm..."
        yum install -y mdadm
    fi
    
    # Create RAID array
    RAID_DEVICE="/dev/md0"
    MOUNT_POINT="/mnt/raid_storage"
    
    case $raid_level in
        "0")
            info_msg "Creating RAID 0 (striping) array..."
            mdadm --create $RAID_DEVICE --level=0 --raid-devices=${#UNMOUNTED_DISKS[@]} "${UNMOUNTED_DISKS[@]}"
            ;;
        "1")
            if [ ${#UNMOUNTED_DISKS[@]} -lt 2 ]; then
                error_msg "RAID 1 requires at least 2 disks"
                return 1
            fi
            info_msg "Creating RAID 1 (mirroring) array..."
            mdadm --create $RAID_DEVICE --level=1 --raid-devices=2 "${UNMOUNTED_DISKS[@]:0:2}"
            ;;
        "5")
            if [ ${#UNMOUNTED_DISKS[@]} -lt 3 ]; then
                error_msg "RAID 5 requires at least 3 disks"
                return 1
            fi
            info_msg "Creating RAID 5 array..."
            mdadm --create $RAID_DEVICE --level=5 --raid-devices=${#UNMOUNTED_DISKS[@]} "${UNMOUNTED_DISKS[@]}"
            ;;
    esac
    
    # Wait for RAID to initialize
    info_msg "Waiting for RAID initialization..."
    sleep 5
    
    # Create filesystem
    info_msg "Creating ext4 filesystem on RAID array..."
    mkfs.ext4 -F $RAID_DEVICE
    
    # Mount the RAID device
    mkdir -p $MOUNT_POINT
    mount $RAID_DEVICE $MOUNT_POINT
    
    # Add to fstab
    echo "$RAID_DEVICE $MOUNT_POINT ext4 defaults,noatime 0 2" >> /etc/fstab
    
    # Save RAID configuration
    mdadm --detail --scan >> /etc/mdadm.conf
    
    success_msg "RAID $raid_level setup completed at $MOUNT_POINT"
}

# Main execution
echo -e "\n${CYAN}🔍 Scanning for disks...${NC}"
sleep 1

detect_disks

if [ $DISK_COUNT -eq 0 ]; then
    warning_msg "All disks are already mounted. Nothing to do."
    exit 0
fi

echo -e "\n${YELLOW}📋 Disk Setup Options:${NC}"
echo -e "\n${WHITE}1.${NC} ${GREEN}Auto Mount All Disks${NC} - Mount each disk separately"
echo -e "${WHITE}2.${NC} ${BLUE}LVM Setup${NC} - Combine all disks into one logical volume"
echo -e "${WHITE}3.${NC} ${YELLOW}RAID 0 Setup${NC} - Stripe all disks for maximum performance"
echo -e "${WHITE}4.${NC} ${CYAN}RAID 1 Setup${NC} - Mirror disks for redundancy (2 disks)"
echo -e "${WHITE}5.${NC} ${YELLOW}RAID 5 Setup${NC} - Distributed parity (3+ disks)"
echo -e "${WHITE}6.${NC} ${WHITE}Custom Setup${NC} - Manual disk configuration"
echo -e "${WHITE}7.${NC} ${RED}Skip Disk Setup${NC} - Continue without mounting"

echo -e "\n${YELLOW}Select setup option (1-7):${NC}"
read -p "▶ " setup_option

case $setup_option in
    1)
        echo -e "\n${GREEN}🔧 Auto-mounting all available disks...${NC}"
        MOUNT_COUNTER=1
        
        for disk in "${UNMOUNTED_DISKS[@]}"; do
            MOUNT_POINT="/mnt/disk$MOUNT_COUNTER"
            if setup_disk "$disk" "$MOUNT_POINT"; then
                ((MOUNT_COUNTER++))
            fi
        done
        ;;
    2)
        echo -e "\n${BLUE}📦 Setting up LVM...${NC}"
        setup_lvm
        ;;
    3)
        echo -e "\n${YELLOW}⚡ Setting up RAID 0...${NC}"
        setup_raid "0"
        ;;
    4)
        echo -e "\n${CYAN}🔄 Setting up RAID 1...${NC}"
        setup_raid "1"
        ;;
    5)
        echo -e "\n${YELLOW}🛡️ Setting up RAID 5...${NC}"
        setup_raid "5"
        ;;
    6)
        echo -e "\n${WHITE}🎛️ Custom setup selected...${NC}"
        echo -e "${CYAN}Available disks for custom setup:${NC}"
        
        for i in "${!UNMOUNTED_DISKS[@]}"; do
            echo -e "${WHITE}$((i+1)).${NC} ${UNMOUNTED_DISKS[i]}"
        done
        
        echo -e "\n${YELLOW}Enter disk numbers to setup (e.g., '1 3 4'):${NC}"
        read -p "▶ " disk_selection
        
        for num in $disk_selection; do
            if [ $num -le ${#UNMOUNTED_DISKS[@]} ] && [ $num -gt 0 ]; then
                disk="${UNMOUNTED_DISKS[$((num-1))]}"
                echo -e "\n${YELLOW}Enter mount point for $disk:${NC}"
                read -p "▶ " mount_point
                setup_disk "$disk" "$mount_point"
            fi
        done
        ;;
    7)
        warning_msg "Skipping disk setup as requested."
        ;;
    *)
        error_msg "Invalid option selected."
        exit 1
        ;;
esac

# Show final disk status
echo -e "\n${GREEN}┌─────────────────── Final Disk Status ────────────────────┐${NC}"
echo -e "${GREEN}│${WHITE} Mount Point        │ Device     │ Size      │ Usage    ${GREEN}│${NC}"
echo -e "${GREEN}├─────────────────── ──────────── ──────────── ──────────── ${GREEN}│${NC}"

df -h | grep -E "^/dev/" | while read line; do
    DEVICE=$(echo $line | awk '{print $1}')
    SIZE=$(echo $line | awk '{print $2}')
    USED=$(echo $line | awk '{print $5}')
    MOUNT=$(echo $line | awk '{print $6}')
    
    printf "${GREEN}│${WHITE} %-18s │ %-10s │ %-9s │ %-8s ${GREEN}│${NC}\n" "$MOUNT" "$DEVICE" "$SIZE" "$USED"
done

echo -e "${GREEN}└──────────────────────────────────────────────────────────┘${NC}"

# Create disk monitoring script
cat > /root/scripts/disk_monitor.sh << 'EOF'
#!/bin/bash

# Disk monitoring script for Hetzner servers
# Created by Saud Hezam

LOG_FILE="/var/log/disk_monitor.log"
ALERT_EMAIL="admin@yourdomain.com"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}

# Check disk usage
df -h | grep -vE '^Filesystem|tmpfs|cdrom|udev' | awk '{ print $5 " " $1 " " $6 }' | while read output; do
    usage=$(echo $output | awk '{ print $1}' | cut -d'%' -f1)
    partition=$(echo $output | awk '{ print $2 }')
    mount_point=$(echo $output | awk '{ print $3 }')
    
    if [ $usage -ge 90 ]; then
        log_message "CRITICAL: Disk usage is ${usage}% on $partition ($mount_point)"
        echo "Critical disk usage: ${usage}% on $partition ($mount_point)" | mail -s "Disk Alert - $(hostname)" $ALERT_EMAIL 2>/dev/null
    elif [ $usage -ge 80 ]; then
        log_message "WARNING: Disk usage is ${usage}% on $partition ($mount_point)"
    fi
done

# Check for disk errors
dmesg | grep -i "error\|fail" | grep -i "disk\|sda\|sdb\|sdc\|sdd" | tail -5 >> $LOG_FILE
EOF

chmod +x /root/scripts/disk_monitor.sh

# Add disk monitoring to crontab
(crontab -l 2>/dev/null | grep -v disk_monitor; echo "*/15 * * * * /root/scripts/disk_monitor.sh") | crontab -

echo -e "\n${GREEN}✅ Disk setup completed successfully!${NC}"
echo -e "\n${CYAN}📊 Additional Information:${NC}"
echo -e "${WHITE}• Disk monitoring script created: ${YELLOW}/root/scripts/disk_monitor.sh${NC}"
echo -e "${WHITE}• Monitoring runs every 15 minutes${NC}"
echo -e "${WHITE}• All disks added to /etc/fstab for automatic mounting${NC}"
echo -e "${WHITE}• Configure email alerts in the monitoring script${NC}"

echo -e "\n${CYAN}🛠️ Useful Commands:${NC}"
echo -e "${WHITE}• Check disk usage: ${YELLOW}df -h${NC}"
echo -e "${WHITE}• Check mount points: ${YELLOW}mount | grep ^/dev${NC}"
echo -e "${WHITE}• Check RAID status: ${YELLOW}cat /proc/mdstat${NC}"
echo -e "${WHITE}• Check LVM status: ${YELLOW}lvdisplay${NC}"

echo -e "\n${GREEN}Created by: ${YELLOW}Saud Hezam${NC} | ${WHITE}saudhezam.com${NC}"
