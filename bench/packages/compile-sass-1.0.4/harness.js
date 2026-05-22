var esl = require('esl_symbolic');
require.cache[require.resolve("node-sass")] = { exports: esl.lazy_object() };

var a = require('compile-sass');
a.setupCleanupOnExit(esl.string('payload'));
process.exit(0)
