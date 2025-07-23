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

# 3. Install LuCI menu definition
mkdir -p /usr/share/luci/menu.d/
cp "$SRC_DIR/usr/share/luci/menu.d/luci-app-adguardhome.json" /usr/share/luci/menu.d/

# 4. Install RPCD ACL (access control)
mkdir -p /usr/share/rpcd/acl.d/
cp "$SRC_DIR/usr/share/rpcd/acl.d/luci-app-adguardhome.json" /usr/share/rpcd/acl.d/

echo "Restarted rpcd and reload LuCI:"
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart
