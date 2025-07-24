module("luci.controller.snac", package.seeall)

function index()
    -- Existing SNAC menu entries
    entry({"admin", "snac"}, firstchild(), "Web Guard", 1).acl_depends = { "luci-app-openvpn" }

    -- AdGuard Home submenu under SNAC
    entry({"admin", "snac", "adguardhome"}, firstchild(), "ADGuardHome", 2).acl_depends = { "luci-app-adguardhome" }
    entry({"admin", "snac", "adguardhome", "dashboard"}, view("adguardhome/dashboard"), "Dashboard", 1).leaf = true
    entry({"admin", "snac", "adguardhome", "status"}, view("adguardhome/status"), "Status", 11).leaf = true
    entry({"admin", "snac", "adguardhome", "logs"}, view("adguardhome/logs"), "Logs", 21).leaf = true
    entry({"admin", "snac", "adguardhome", "config"}, view("adguardhome/config"), "Configuration", 31).leaf = true

    -- Device and Schedule submenu under SNAC
    entry({"admin", "snac", "webguard"}, firstchild(), "Web Access", 3).acl_depends = { "luci-app-adguardhome" }
    entry({"admin", "snac", "webguard", "deviceaccess"}, template("snac"), "Device Access", 1).leaf = true
    entry({"admin", "snac", "webguard", "scheduleaccess"}, template("schedulesnac"), "Schedule Access",11).leaf = true
    entry({"admin", "snac", "webguard", "config"}, view("config"), "Configuration", 21).leaf = true
end
