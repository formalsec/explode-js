const root = require("apiconnect-cli-plugins");
let payload = "& touch apiconnect-cli-plugins &";
root.pluginLoader.installPlugin(payload, "").catch(() => {}); 
