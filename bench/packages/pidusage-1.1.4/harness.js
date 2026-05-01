const esl = require('esl_symbolic');
const os = require("os");
os.platform = () => {
  return "freebsd";
};
const roar_pidusage = require("pidusage");

try {
  roar_pidusage.stat(esl.string('payload'), function () {});
} catch (e) {}
