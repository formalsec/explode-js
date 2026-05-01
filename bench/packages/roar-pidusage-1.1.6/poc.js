const os = require("os");
os.platform = () => {
  return "freebsd";
};
const roar_pidusage = require("roar-pidusage");

try {
  roar_pidusage.stat("$(touch roar-pidusage)", function () {});
} catch (e) {}

