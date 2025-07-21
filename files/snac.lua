module("luci.controller.snac", package.seeall)

function index()
    -- Existing SNAC menu entries
    entry({"admin", "snac"}, firstchild(), "Web Guard", 1).acl_depends = { "luci-app-openvpn" }

    -- AdGuard Home submenu under SNAC
    entry({"admin", "snac", "adguardhome"}, firstchild(), "AdGuard Home", 2).acl_depends = { "luci-app-adguardhome" }
    entry({"admin", "snac", "adguardhome", "dashboard"}, view("adguardhome/dashboard"), "Dashboard", 1).leaf = true
    entry({"admin", "snac", "adguardhome", "status"}, view("adguardhome/status"), "Status", 11).leaf = true
    entry({"admin", "snac", "adguardhome", "logs"}, view("adguardhome/logs"), "Logs", 21).leaf = true
    entry({"admin", "snac", "adguardhome", "config"}, view("adguardhome/config"), "Configuration", 31).leaf = true

    -- Device and Schedule submenu under SNAC
    entry({"admin", "snac", "deviceaccess"}, template("snac"), "Device Access", 3).leaf = true
    entry({"admin", "snac", "scheduleaccess"}, template("schedulesnac"), "Schedule Access", 4).leaf = true
end
