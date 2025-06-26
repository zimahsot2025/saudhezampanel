# EasycPanel v4.1 - The Ultimate cPanel Server Management Solution

![EasycPanel Banner](https://saudhezam.com/cpanel-script/easycpanel-banner.png)

## ⚠️ **URGENT: HETZNER USERS READ THIS FIRST!**

**🚨 CRITICAL WARNING FOR HETZNER SERVERS:**
Before installing EasycPanel on any Hetzner server, you **MUST** set up all disks first! Hetzner servers don't auto-mount additional disks, which can cause **DATA LOSS**. 

**→ [Jump to Hetzner Setup Instructions](#️-critical-notice-for-hetzner-servers)**

---

## Overview
EasycPanel is the ultimate, free, one-click solution for installing, configuring, optimizing, and securing cPanel servers. Perfect for both novice and experienced system administrators, this powerful script handles everything from initial setup to performance tuning and security hardening.

## ⚠️ **CRITICAL NOTICE FOR HETZNER SERVERS**

**🚨 IMPORTANT: Before installing EasycPanel on Hetzner servers, you MUST set up all disks first!**

Hetzner servers have a known issue where additional disks are not automatically mounted during OS installation. **This MUST be done before running EasycPanel to avoid data loss and ensure optimal server performance.**

### **Required Steps for Hetzner Servers:**

1. **Detect all available disks**: `lsblk` or `fdisk -l`
2. **Mount ALL available disks** before installation
3. **Set up RAID/LVM configuration** if needed
4. **Verify disk setup**: Ensure all disks are properly mounted

### **Quick Hetzner Disk Setup:**
```bash
# Download and run our Hetzner disk setup script FIRST
curl -O https://saudhezam.com/cpanel-script/hetzner-disk-setup.sh && chmod +x hetzner-disk-setup.sh && ./hetzner-disk-setup.sh
```

**Why this is critical:**
- **Data Protection**: Prevents data loss during setup
- **Performance**: Utilizes all available disk space
- **Cost Efficiency**: You're paying for all disks, use them all!
- **Prevents Issues**: Avoids complex disk management later

**❌ DO NOT proceed with EasycPanel installation until ALL disks are properly set up!**

## 🚀 New Features in v4.1
- **Enhanced Security**: Advanced DDoS protection with fail2ban integration
- **Auto Backup System**: Daily automated backups with retention policies
- **Smart Resource Monitoring**: Real-time server health monitoring
- **Enhanced SSL Management**: Let's Encrypt SSL auto-renewal
- **Database Optimization**: Advanced MySQL/MariaDB performance tuning
- **Redis Caching**: Integrated Redis for improved performance
- **Cloudflare Integration**: Enhanced CDN and security features
- **Malware Scanner**: Real-time malware detection and removal
- **🆕 Hetzner Disk Management**: Auto-mount and setup all server disks
- **🆕 RAID & LVM Support**: Advanced disk configuration options

## Why Choose EasycPanel?
- **Save Time**: Complete setup in minutes, not hours
- **Optimize Performance**: Pre-configured for maximum efficiency
- **Enhance Security**: Robust security measures implemented automatically
- **Flexibility**: Works on fresh servers or existing installations
- **Revertible**: Comprehensive backup and reversion capabilities

## Requirements

### Operating System
- AlmaLinux 8/9 (64-bit) - **Recommended**
- CloudLinux 8/9 (64-bit)

### Hardware
- **Minimum**: 2GB RAM, 20GB Disk Space
- **Recommended**: 4GB+ RAM, 40GB+ Disk Space

### Licensing
- cPanel License (recommended but not required)
- CloudLinux License (if using CloudLinux OS)

## Installation

### Quick Install
Run this single command on your server:

```bash
curl -O https://saudhezam.com/cpanel-script/cPanel-v4.sh && chmod +x cPanel-v4.sh && sh cPanel-v4.sh
```

### From Repository
Clone and run:

```bash
git clone https://github.com/saudhezam/easycpanel.git
cd easycpanel && chmod +x cPanel-v4.sh && sh cPanel-v4.sh
```

## What's New in Version 4.1

### Advanced Security Features
- **Fail2ban Integration**: Advanced intrusion prevention system
- **Real-time Malware Scanning**: Automated malware detection and removal
- **Enhanced Firewall Rules**: Custom CSF rules for better protection
- **SSL Certificate Management**: Automated Let's Encrypt SSL deployment

### Performance Enhancements
- **Intelligent Caching**: Multi-layer caching with Redis and Memcached
- **Database Optimization**: Query optimization and index management
- **CDN Integration**: Seamless Cloudflare and other CDN providers
- **Resource Monitoring**: Real-time CPU, RAM, and disk monitoring

### Backup and Recovery
- **Automated Backup System**: Daily incremental backups
- **Cloud Storage Integration**: Support for AWS S3, Google Drive
- **One-Click Restore**: Easy restoration from backup points
- **Backup Encryption**: Secure encrypted backup storage

### Management Features
- **Web-based Dashboard**: Easy-to-use control panel
- **Email Notifications**: Real-time alerts for system events
- **Log Management**: Centralized logging and analysis
- **Update Manager**: Automatic system and security updates

### Web Server Enhancements
- **Dual Server Optimization**: Choose between Apache-only or Nginx+Apache stack
- **Apache Optimization**: MPM-Event with HTTP/2 and dynamic resource allocation
- **Nginx Integration**: Engintron with advanced caching and Cloudflare compatibility
- **Server-Specific Tuning**: Automatically adjusts settings based on your hardware

### Performance Improvements
- **Resource-Aware Configuration**: Adjusts resource allocation based on server usage type
- **Dynamic MySQL Tuning**: Optimizes database performance based on available RAM
- **PHP-FPM Optimization**: Enhanced PHP performance with optimized settings
- **Redis Integration**: Improved caching and session handling

### Security Enhancements
- **Advanced CSF Configuration**: Comprehensive firewall with DDoS protection
- **ModSecurity with OWASP Rules**: Enterprise-grade web application firewall
- **ImunifyAV Integration**: Malware scanning and protection
- **Comprehensive Hardening**: Symlink protection, compiler restrictions, and more

### CMS Optimizations
- **WordPress-Specific Rules**: Performance tweaks for WordPress sites
- **Media Caching**: Optimized handling of static files
- **Browser Caching**: Improved client-side caching for faster repeat visits

### System Management
- **Backup System**: Comprehensive backup of all configurations
- **Reversion Capability**: Easy rollback to previous state if needed
- **SSH Security**: Automated SSH hardening with custom port options
- **Service Monitoring**: Enhanced monitoring of critical services

## Usage Options

### Fresh Installation
Use EasycPanel to set up a new cPanel server from scratch with optimal configuration.

### Server Optimization
Run on an existing server to optimize and secure it without reinstallation.

### Configuration Reversion
Use the included reversion script to roll back changes if needed:

```bash
bash revert-optimization.sh
```

## 💾 Hetzner Server Optimization

### Automatic Disk Management
EasycPanel v4.1 includes special support for Hetzner dedicated servers with multiple disks:

#### 🔧 Hetzner Disk Setup Features
- **🔍 Auto-Detection**: Automatically detects all available disks
- **📊 Smart Analysis**: Shows disk status, size, and mount information
- **⚡ Multiple Setup Options**: Choose from various disk configurations
- **🛡️ RAID Support**: RAID 0, 1, and 5 configurations
- **📦 LVM Integration**: Logical Volume Management for flexibility
- **🔄 Auto-Mount**: Automatic mounting with fstab entries
- **📈 Monitoring**: Built-in disk usage monitoring and alerts

#### 💿 Available Disk Configurations

##### 1. **Individual Disk Mounting**
- Mounts each disk separately
- Optimal for specific application storage
- Easy to manage individual disks

##### 2. **LVM (Logical Volume Manager)**
- Combines all disks into one logical volume
- Flexible storage management
- Easy to expand storage later

##### 3. **RAID 0 (Striping)**
- Maximum performance setup
- Data striped across all disks
- Best for high I/O applications

##### 4. **RAID 1 (Mirroring)**
- Data redundancy and protection
- Requires at least 2 disks
- Best for critical data storage

##### 5. **RAID 5 (Distributed Parity)**
- Balance of performance and redundancy
- Requires at least 3 disks
- Good for most production environments

#### 🚀 Quick Disk Setup
```bash
# Run the Hetzner disk setup tool
./hetzner-disk-setup.sh

# Or use the main menu option 5
./cPanel-v4.sh
```

#### ⚠️ Important Notes for Hetzner Users
- **🔒 Root Access Required**: Full administrative privileges needed
- **💾 Backup Important Data**: Always backup before disk operations
- **🔄 Server Reboot**: Some configurations may require reboot
- **📊 Monitoring**: Disk monitoring is automatically configured
- **📧 Alerts**: Configure email alerts for disk issues

#### 🛠️ Troubleshooting Hetzner Disks
- **Disk Not Detected**: Check hardware connections and power
- **Mount Failures**: Verify disk health and filesystem integrity
- **Performance Issues**: Check RAID status and disk errors
- **Space Issues**: Monitor disk usage and cleanup old files

## License
Free to use and redistribute with attribution.

## About the Author
Created by [Saud Hezam](https://www.saudhezam.com)
- **Email**: me@saudhezam.com
- **Website**: https://saudhezam.com
- **GitHub**: https://github.com/saudhezam
- **LinkedIn**: https://linkedin.com/in/saudhezam

## ☕ Support EasycPanel Development

**EasycPanel saves you hours of work - consider buying me a coffee to keep this project alive!**

If EasycPanel has helped you, please consider supporting ongoing development and improvements. Your support directly enables new features, optimizations, and regular updates.

**[☕ Buy Me a Coffee](https://ko-fi.com/saudhezam)**

*Monthly supporters get priority support and early access to new features!*

---

## Detailed Changelog

### Version 4.1 (June 2025) - Major Security & Performance Update
- Added comprehensive fail2ban integration for intrusion prevention
- Implemented real-time malware scanning and auto-removal
- Enhanced SSL certificate management with auto-renewal
- Added intelligent multi-layer caching system
- Improved database performance optimization
- Added automated backup system with cloud storage support
- Enhanced monitoring and alerting system
- Added web-based management dashboard
- Improved Cloudflare integration with advanced security rules
- Added support for custom security policies

### Version 4.0 (March 2025)
- Added adaptive resource allocation based on server type (personal/shared hosting)
- Implemented comprehensive backup and restoration system
- Added WordPress-specific optimizations
- Enhanced Cloudflare integration
- Improved DDoS protection in CSF firewall
- Added better media and static file caching
- Implemented Redis for improved caching

### Version 3.0 (November 2023)
- Added Nginx and Apache optimization with MPM-Event and HTTP/2
- Implemented MySQL/MariaDB basic optimization
- Enhanced server security protocols
- Configured CSF Firewall with additional options
- Added Cloudflare support for Nginx/Engintron
- Disabled micro caching in Nginx/Engintron by default to prevent session conflicts

### Version 2.0 (March 2023)
- Added PHP 8.1 and 8.2 support
- Implemented improved security measures
- Enhanced cPanel configuration options
- Added more comprehensive logging

### Version 1.0 (January 2022)
- Initial release with basic cPanel installation and configuration
- Basic security hardening
- PHP optimization
- Apache configuration

---

*EasycPanel is a community-driven project designed to make server management accessible to everyone. Your feedback and contributions help make it better!*