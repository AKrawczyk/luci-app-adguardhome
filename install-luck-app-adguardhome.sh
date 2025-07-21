#!/bin/sh

# This script manually installs luci-app-adguardhome to OpenWrt
# Assumes you're running this script on the OpenWrt device as root

set -e

echo "Installing luci-app-adguardhome manually..."

# Define source directory (where files are stored)
SRC_DIR="$(pwd)"  # Change if needed

# 1. Install LuCI view .js files
mkdir -p /www/luci-static/resources/view/adguardhome/
cp "$SRC_DIR/htdocs/"*.js /www/luci-static/resources/view/adguardhome/

# 2. Install RPCD backend script
mkdir -p /usr/libexec/rpcd/
cp "$SRC_DIR/files/luci.adguardhome" /usr/libexec/rpcd/
chmod +x /usr/libexec/rpcd/luci.adguardhome

# 3. Install LuCI menu definition
mkdir -p /usr/share/luci/menu.d/
cp "$SRC_DIR/files/luci-menu.d.json" /usr/share/luci/menu.d/luci-app-adguardhome.json

# 4. Install RPCD ACL (access control)
mkdir -p /usr/share/rpcd/acl.d/
cp "$SRC_DIR/files/rcp-acl.d.json" /usr/share/rpcd/acl.d/luci-app-adguardhome.json

echo "Restarted rpcd and reload LuCI:"
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart
