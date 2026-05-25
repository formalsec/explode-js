const esl = require("esl_symbolic");
require.cache[require.resolve("pid-from-port")] = { exports: esl.lazy_object() };

const killPortProcess = require("kill-port-process");
killPortProcess.killPortProcess(esl.string("payload"))
