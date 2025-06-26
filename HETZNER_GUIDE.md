# 🖥️ Hetzner Server Setup Guide - EasycPanel v4.1

## ⚠️ **CRITICAL WARNING - READ THIS FIRST!**

### **🚨 MANDATORY DISK SETUP FOR ALL HETZNER SERVERS!**

**STOP! Before proceeding with ANY cPanel installation on Hetzner servers:**

#### **KNOWN HETZNER ISSUE:**
Hetzner servers have a **CRITICAL PROBLEM** where additional disks are **NOT automatically mounted** during OS installation. This affects **ALL** Hetzner dedicated servers and **WILL CAUSE DATA LOSS** if not addressed immediately.

#### **❌ CONSEQUENCES OF SKIPPING DISK SETUP:**
- **💀 DATA LOSS**: Files saved to unmounted disks disappear
- **🐌 POOR PERFORMANCE**: Server uses only primary disk  
- **💸 WASTED MONEY**: Paying for unused disk space
- **🔧 COMPLEX RECOVERY**: Nearly impossible to fix after cPanel installation

#### **✅ REQUIRED ACTIONS BEFORE cPanel:**
1. **CHECK DISKS**: `lsblk` or `fdisk -l`
2. **MOUNT ALL DISKS**: Use our automated script below
3. **VERIFY SETUP**: Ensure all disks are accessible
4. **PROCEED SAFELY**: Only then install cPanel

---

## 🚀 **AUTOMATED SOLUTION (Recommended)**

```bash
# Download and run our Hetzner disk setup script
curl -O https://saudhezam.com/cpanel-script/hetzner-disk-setup.sh
chmod +x hetzner-disk-setup.sh
./hetzner-disk-setup.sh
```

**This script automatically:**
- ✅ Detects all available disks
- ✅ Creates optimal partitions
- ✅ Sets up LVM/RAID
- ✅ Mounts all disks
- ✅ Configures auto-mounting
- ✅ Sets up monitoring

---

## 📋 Overview
This guide is specifically designed for Hetzner dedicated servers and provides step-by-step instructions for optimal disk configuration and cPanel setup.

## 🏗️ Hetzner Server Types Supported

### 💪 Dedicated Servers
- **AX Series**: AMD-based dedicated servers
- **EX Series**: Intel-based dedicated servers  
- **SX Series**: Storage-optimized servers
- **PX Series**: High-performance servers

### 💾 Common Disk Configurations
- **Single NVMe**: 1x NVMe SSD (entry-level)
- **Dual NVMe**: 2x NVMe SSD (performance)
- **Multiple SATA**: 2-4 SATA drives (storage)
- **Mixed Setup**: NVMe + SATA combination

## 🚀 Quick Hetzner Setup

### Method 1: Complete Auto Setup
```bash
# Download and run EasycPanel
curl -O https://saudhezam.com/cpanel-script/cPanel-v4.sh
chmod +x cPanel-v4.sh
./cPanel-v4.sh

# Select option 1 for fresh installation
# The system will auto-detect Hetzner and offer disk setup
```

### Method 2: Disk Setup Only
```bash
# For existing cPanel servers
./hetzner-disk-setup.sh
```

### Method 3: Auto-Detection Setup
```bash
# Automatic Hetzner detection and configuration
./auto-disk-setup.sh
```

## 💿 Disk Configuration Options

### 🔧 Automatic Configuration (Recommended)
The script automatically detects your Hetzner server and suggests optimal configurations:

#### 📁 Single Additional Disk
- **Setup**: Mounted as `/backup`
- **Use Case**: Backup storage
- **Benefits**: Simple, reliable backup location

#### 🔄 Dual Disk RAID 1
- **Setup**: RAID 1 mirroring
- **Use Case**: Data redundancy
- **Benefits**: Automatic failover protection

#### 📦 Multiple Disk LVM
- **Setup**: Logical Volume Manager
- **Use Case**: Flexible storage management
- **Benefits**: Easy expansion and management

### 🎛️ Manual Configuration Options

#### ⚡ RAID 0 (Performance)
```bash
# Best for: High I/O applications
# Requirements: 2+ disks
# Pros: Maximum performance
# Cons: No redundancy
```

#### 🛡️ RAID 5 (Balanced)
```bash
# Best for: Production environments
# Requirements: 3+ disks  
# Pros: Good performance + redundancy
# Cons: Complex recovery
```

#### 📊 LVM (Flexibility)
```bash
# Best for: Dynamic environments
# Requirements: 1+ disks
# Pros: Easy resizing and management
# Cons: Additional complexity layer
```

## 📋 Pre-Installation Checklist

### ✅ Server Requirements
- [ ] Fresh AlmaLinux 8/9 or CloudLinux 8/9 installation
- [ ] Root access to the server
- [ ] Stable internet connection
- [ ] All disks properly connected and detected
- [ ] Server rescue system not active

### 🔍 Disk Detection Verification
```bash
# Check all available disks
lsblk

# Check disk details
fdisk -l

# Verify no existing RAID/LVM
cat /proc/mdstat
pvdisplay
```

### 🌐 Network Configuration
```bash
# Verify internet connectivity
ping -c 4 google.com

# Check DNS resolution
nslookup saudhezam.com

# Verify package repositories
yum repolist
```

## 🔧 Installation Process

### Step 1: Download EasycPanel
```bash
cd /root
curl -O https://saudhezam.com/cpanel-script/easycpanel-v4.1.tar.gz
tar -xzf easycpanel-v4.1.tar.gz
cd easycpanel
```

### Step 2: Make Scripts Executable
```bash
chmod +x *.sh
```

### Step 3: Start Installation
```bash
# For complete setup including disk configuration
./quick-setup.sh

# Or use the main script
./cPanel-v4.sh
```

### Step 4: Follow Interactive Prompts
The installation will guide you through:
- OS compatibility check
- Disk detection and configuration
- cPanel installation options
- Security hardening setup
- Performance optimization

## 💾 Disk Setup Examples

### 🖥️ Example 1: Hetzner AX41 (2x NVMe)
**Server**: AMD Ryzen 5 3600, 64GB RAM, 2x 512GB NVMe
```bash
Detected Configuration:
- /dev/nvme0n1: 512GB (OS) - Already mounted
- /dev/nvme1n1: 512GB (Available)

Recommended Setup:
- Single disk mounted as /backup
- Used for cPanel backups and temporary storage
```

### 🖥️ Example 2: Hetzner EX62 (2x SSD + 2x HDD)
**Server**: Intel i7, 64GB RAM, 2x 480GB SSD, 2x 4TB HDD
```bash
Detected Configuration:
- /dev/sda: 480GB SSD (OS) - Already mounted  
- /dev/sdb: 480GB SSD (Available)
- /dev/sdc: 4TB HDD (Available)
- /dev/sdd: 4TB HDD (Available)

Recommended Setup:
- SSD (/dev/sdb): Fast storage for databases
- HDDs: RAID 1 for user data and backups
```

### 🖥️ Example 3: Hetzner SX134 (Multiple HDDs)
**Server**: Storage optimized, 4x 10TB HDD
```bash
Detected Configuration:
- /dev/sda: 10TB (OS partition + available space)
- /dev/sdb: 10TB (Available)
- /dev/sdc: 10TB (Available) 
- /dev/sdd: 10TB (Available)

Recommended Setup:
- LVM across all available disks
- Flexible partition management
- Combined ~30TB usable space
```

## 🔍 Troubleshooting Common Issues

### ❌ Issue: Disks Not Detected
**Symptoms**: Script shows "No disks found"
**Solutions**:
```bash
# Check hardware detection
lsblk -a
lshw -class disk

# Verify BIOS/UEFI settings
dmesg | grep -i disk

# Rescan SCSI buses
echo "- - -" > /sys/class/scsi_host/host*/scan
```

### ❌ Issue: Partition Creation Fails
**Symptoms**: "Failed to create partition table"
**Solutions**:
```bash
# Check if disk is busy
fuser -v /dev/sdX

# Clear existing partition table
wipefs -a /dev/sdX

# Retry with force
parted -s /dev/sdX mklabel gpt
```

### ❌ Issue: Mount Failures
**Symptoms**: "Failed to mount partition"
**Solutions**:
```bash
# Check filesystem
fsck -f /dev/sdX1

# Verify mount point
mkdir -p /mount/point

# Manual mount test
mount -t ext4 /dev/sdX1 /mount/point
```

### ❌ Issue: RAID Problems
**Symptoms**: RAID array not starting
**Solutions**:
```bash
# Check RAID status
cat /proc/mdstat
mdadm --detail /dev/md0

# Reassemble array
mdadm --assemble --scan

# Force assembly
mdadm --assemble --force /dev/md0 /dev/sd[bcd]
```

## 📊 Performance Optimization

### 💡 SSD Optimization
```bash
# Enable TRIM support
echo 'ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="noop"' > /etc/udev/rules.d/60-ssd-scheduler.rules

# Configure fstab for SSD
# Add 'noatime,discard' to mount options
```

### 💡 HDD Optimization
```bash
# Set appropriate scheduler
echo 'ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="deadline"' > /etc/udev/rules.d/60-hdd-scheduler.rules

# Configure fstab for HDD
# Add 'noatime' to mount options
```

### 💡 RAID Performance
```bash
# Optimize RAID stripe size
mdadm --create /dev/md0 --level=0 --raid-devices=2 --chunk=64 /dev/sdb /dev/sdc

# Monitor RAID performance
iostat -x 1
```

## 📈 Monitoring Setup

### 📊 Automatic Monitoring
EasycPanel automatically configures:
- Disk usage monitoring
- RAID status checking  
- Performance alerts
- Email notifications

### 📱 Manual Monitoring Commands
```bash
# Check disk usage
df -h

# Monitor I/O
iotop

# Check RAID status
watch cat /proc/mdstat

# LVM status
lvdisplay
vgdisplay
```

## 🆘 Emergency Procedures

### 🚨 Disk Failure Recovery
```bash
# RAID 1 disk replacement
mdadm --manage /dev/md0 --remove /dev/sdb
# Replace disk physically
mdadm --manage /dev/md0 --add /dev/sdb
```

### 🚨 LVM Recovery
```bash
# Scan for LVM volumes
pvscan
vgscan
lvscan

# Activate volume group
vgchange -ay
```

### 🚨 Backup Recovery
```bash
# List available backups
ls -la /backup/

# Restore cPanel account
/scripts/restorepkg account_backup.tar.gz
```

## 📞 Support

### 🆘 Getting Help
- **Primary Support**: [me@saudhezam.com](mailto:me@saudhezam.com)
- **Website**: [saudhezam.com](https://saudhezam.com)
- **Hetzner Support**: For hardware issues
- **Community**: GitHub Issues

### 📋 Support Information to Provide
When requesting support, include:
- Hetzner server model
- Operating system version
- Disk configuration details
- Error messages or logs
- Steps attempted

## 💰 Hetzner-Specific Tips

### 💡 Cost Optimization
- Use appropriate disk types for workload
- Consider RAID levels vs. cost
- Monitor bandwidth usage
- Optimize backup retention

### 💡 Performance Tips
- Place databases on fastest disks
- Use separate disks for logs
- Configure appropriate file systems
- Monitor disk I/O patterns

### 💡 Maintenance Best Practices
- Regular SMART disk checks
- Monitor RAID rebuild times
- Test backup restoration
- Keep spare disk space available

---

**Created by**: [Saud Hezam](https://saudhezam.com)  
**Email**: [me@saudhezam.com](mailto:me@saudhezam.com)  
**Support**: [ko-fi.com/saudhezam](https://ko-fi.com/saudhezam)

*This guide is specifically optimized for Hetzner dedicated servers running EasycPanel v4.1*
