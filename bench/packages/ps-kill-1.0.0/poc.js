const ps_kill = require("ps-kill");
try {
  ps_kill.kill("$(touch ps-kill)", function (error) {});
} catch (e) {}
