const kill_process_by_name = require("kill-process-by-name");

try {
  kill_process_by_name("$(touch kill-process-by-name)");
} catch (err) {}
