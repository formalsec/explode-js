const portprocesses = require("portprocesses");

try {
  portprocesses.killProcess("$(touch portprocesses)");
} catch (e) {}
