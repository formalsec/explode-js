const root = require("node-key-sender");
try {
  let attack_code = ["&touch", "node-key-sender-sendkeys"];
  root.sendKeys(attack_code);
} catch (err) {}
