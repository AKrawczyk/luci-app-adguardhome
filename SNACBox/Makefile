# Copyright 2024- Douglas Orend <doug.orend2@gmail.com>
# This is free software, licensed under the Apache License, Version 2.0

include $(TOPDIR)/rules.mk

PKG_LICENSE:=Apache-2.0
PKG_NAME:=luci-app-adguardhome
PKG_VERSION:=2.2
PKG_RELEASE:=1
PKG_MAINTAINER:=Douglas Orend <doug.orend2@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-adguardhome
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI support for AdguardHome
	PKGARCH:=all
	DEPENDS:=+adguardhome +luci-base +twin-bcrypt-js +curl
endef

define Package/luci-app-adguardhome/description
	LuCI Support for AdGuardHome
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-adguardhome/install
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view/adguardhome/
	$(INSTALL_DATA) ./www/luci-static/resources/view/adguardhome/*.js $(1)/www/luci-static/resources/view/adguardhome/

	$(INSTALL_DIR) $(1)/usr/libexec/rpcd/
	$(INSTALL_BIN) ./usr/libexec/rpcd/luci.adguardhome $(1)/usr/libexec/rpcd/

	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d/
	$(INSTALL_DATA) ./usr/share/luci/menu.d/luci-app-adguardhome.json $(1)/usr/share/luci/menu.d/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DATA) ./usr/lib/lua/luci/controller/snac.lua $(1)/usr/lib/lua/luci/controller/
endef

$(eval $(call BuildPackage,luci-app-adguardhome))
