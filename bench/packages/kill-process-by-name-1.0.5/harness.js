const esl = require('esl_symbolic');
const kill_process_by_name = require("kill-process-by-name");

try {
  kill_process_by_name(esl.string('payload'));
} catch (err) {}
