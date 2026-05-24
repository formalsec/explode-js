const esl = require("esl_symbolic");
require.cache[require.resolve("portfinder")] = { exports: esl.lazy_object() };
require.cache[require.resolve("inquirer")] = { exports: esl.lazy_object() };

const lib = require('kill-process-on-port');
lib.killProcessOnPort(esl.string("port"), false);
