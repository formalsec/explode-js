const a = require("macfromip");
try {
  a.getMacInLinux("& touch macfromip", function () {});
} catch (e) {}
