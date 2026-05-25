const esl = require('esl_symbolic');
require.cache[require.resolve("shell-quote")] = { exports: esl.lazy_object() };

var launchEditor = require('react-dev-utils/launchEditor');
launchEditor(esl.string('filename'), 0);
