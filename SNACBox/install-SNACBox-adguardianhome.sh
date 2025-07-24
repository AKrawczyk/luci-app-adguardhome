#!/bin/sh

# This script manually installs luci-app-adguardhome to OpenWrt
# Assumes you're running this script on the OpenWrt device as root

set -e

echo "Installing luci-app-adguardhome manually..."

# Define source directory (where files are stored)
SRC_DIR="$(pwd)"  # Change if needed

# 1. Install LuCI view .js files
mkdir -p /www/luci-static/resources/view/adguardhome/
cp "$SRC_DIR/www/luci-static/resources/view/adguardhome/"*.js /www/luci-static/resources/view/adguardhome/

# 2. Install RPCD backend script
mkdir -p /usr/libexec/rpcd/
cp "$SRC_DIR/usr/libexec/rpcd/luci.adguardhome" /usr/libexec/rpcd/
chmod +x /usr/libexec/rpcd/luci.adguardhome

# 4. Install RPCD ACL (access control)
mkdir -p /usr/lib/lua/luci/controller/
cp "$SRC_DIR/usr/lib/lua/luci/controller/snac.lua" /usr/lib/lua/luci/controller/

# Create /etc/config/adguardhome with a config adguardhome section if missing
grep -q ' config adguardhome' /etc/config/adguardhome 2>/dev/null || {
    echo ' config adguardhome' >> /etc/config/adguardhome
}

# Create /etc/config/webguard with a config webguard section if missing
grep -q ' config webguard' /etc/config/webguard 2>/dev/null || {
    echo ' config webguard' >> /etc/config/webguard
}

echo "Restarted rpcd and reload LuCI:"
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart
