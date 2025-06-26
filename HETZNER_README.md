⚠️ **READ THIS FIRST IF USING HETZNER SERVERS** ⚠️
==================================================

🚨 **CRITICAL**: Hetzner servers require disk setup BEFORE cPanel installation!

**Quick Commands:**
```bash
# 1. Check disks first
lsblk

# 2. If you see unmounted disks, run this FIRST:
curl -O https://saudhezam.com/cpanel-script/hetzner-disk-setup.sh
chmod +x hetzner-disk-setup.sh
./hetzner-disk-setup.sh

# 3. Only AFTER disk setup, install EasycPanel:
curl -O https://saudhezam.com/cpanel-script/cPanel-v4.sh
chmod +x cPanel-v4.sh
./cPanel-v4.sh
```

**Why This Matters:**
- Prevents DATA LOSS
- Uses ALL available disk space
- Optimal performance
- Saves time and money

**See:** HETZNER_WARNING.md for detailed explanation.
