const os = require("os");
os.platform = () => {
  return "freebsd";
};
const roar_pidusage = require("pidusage");

try {
  roar_pidusage.stat("1 && touch pidusage", function () {});
} catch (e) {}
