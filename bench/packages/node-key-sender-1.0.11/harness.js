const esl = require('esl_symbolic');
const root = require("node-key-sender");
try {
  let attack_code = [esl.string('payload'), "node-key-sender-sendkeys"];
  root.sendKeys(attack_code);
} catch (err) {}
