const psnode = require("psnode");
try {
  psnode.kill("$(touch psnode)", function () {});
} catch (e) {}
