# 🚨 CRITICAL WARNING FOR HETZNER SERVERS

## ⚠️ **STOP! READ THIS BEFORE PROCEEDING!**

### **MANDATORY DISK SETUP REQUIRED**

If you're using a **Hetzner dedicated server**, you **MUST** configure all disks before installing EasycPanel or any cPanel-related software.

---

## ❌ **THE PROBLEM**

**Hetzner servers have a critical issue:**
- Additional disks are **NOT automatically mounted** during OS installation
- Only the primary disk (usually `/dev/sda`) is configured
- Additional disks (like `/dev/sdb`, `/dev/sdc`, etc.) remain **unformatted and unmounted**
- This affects **ALL** Hetzner dedicated servers regardless of the plan

---

## 💥 **CONSEQUENCES OF IGNORING THIS**

### **Data Loss Scenarios:**
- Files saved to unmounted disks **disappear** on reboot
- Database files might be written to unmounted disks
- Backup files stored on unmounted disks are **lost**
- cPanel accounts created on unmounted disks become **inaccessible**

### **Performance Issues:**
- Server uses only 20-50% of available disk space
- Poor I/O performance due to single disk usage
- Unnecessary disk space wastage
- Higher hosting costs per GB used

### **Recovery Complexity:**
- Very difficult to migrate data after cPanel installation
- Requires service downtime for proper disk setup
- Potential for configuration conflicts
- Risk of data corruption during recovery

---

## ✅ **THE SOLUTION**

### **1. Automatic Setup (Recommended)**
```bash
# Download and run our Hetzner disk setup script
curl -O https://saudhezam.com/cpanel-script/hetzner-disk-setup.sh
chmod +x hetzner-disk-setup.sh
./hetzner-disk-setup.sh
```

### **2. Manual Verification**
Before proceeding, verify all disks are mounted:
```bash
# Check all available disks
lsblk

# Verify disk usage
df -h

# Check mount points
mount | grep -E '^/dev'
```

### **3. Safe Installation**
Only after disk setup is complete:
```bash
# Now safe to install EasycPanel
curl -O https://saudhezam.com/cpanel-script/cPanel-v4.sh
chmod +x cPanel-v4.sh
./cPanel-v4.sh
```

---

## 🔍 **IDENTIFYING UNMOUNTED DISKS**

### **Signs of Unmounted Disks:**
```bash
# If you see disks without mount points:
$ lsblk
NAME   SIZE TYPE MOUNTPOINT
sda    480G disk 
├─sda1   1G part /boot
├─sda2   8G part [SWAP]
└─sda3 471G part /
sdb    960G disk              # ⚠️ NOT MOUNTED!
sdc    960G disk              # ⚠️ NOT MOUNTED!
```

### **What You Should See After Setup:**
```bash
$ lsblk
NAME   SIZE TYPE MOUNTPOINT
sda    480G disk 
├─sda1   1G part /boot
├─sda2   8G part [SWAP]
└─sda3 471G part /
sdb    960G disk 
└─sdb1 960G part /var        # ✅ PROPERLY MOUNTED
sdc    960G disk 
└─sdc1 960G part /home       # ✅ PROPERLY MOUNTED
```

---

## 🛡️ **WHY OUR SCRIPT IS SAFE**

### **Automated Disk Detection:**
- Scans for all available disks automatically
- Identifies unmounted disks safely
- Preserves existing data where possible

### **Intelligent Configuration:**
- Creates optimal partition layouts
- Sets up LVM for flexibility
- Configures automatic mounting
- Optimizes for cPanel usage

### **Safety Features:**
- Creates backups before changes
- Validates configurations
- Provides rollback options
- Tests all mount points

### **Monitoring Setup:**
- Configures disk monitoring
- Sets up email alerts
- Creates usage reports
- Monitors disk health

---

## 📞 **SUPPORT**

If you encounter any issues:
- **Email**: me@saudhezam.com
- **Website**: https://saudhezam.com
- **Support**: https://ko-fi.com/saudhezam

---

## ⚡ **QUICK CHECKLIST**

- [ ] Run `lsblk` to check for unmounted disks
- [ ] Download and run `hetzner-disk-setup.sh`
- [ ] Verify all disks are mounted with `df -h`
- [ ] Confirm setup with `mount | grep -E '^/dev'`
- [ ] Only then proceed with EasycPanel installation

**Remember: 5 minutes of disk setup prevents hours of data recovery!**

---

*This warning was created to prevent data loss and ensure optimal server performance on Hetzner infrastructure.*
