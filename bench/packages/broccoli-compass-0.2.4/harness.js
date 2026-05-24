var esl = require("esl_symbolic");
require.cache[require.resolve("quick-temp")] = { exports: esl.lazy_object() };

var compileSass = require('broccoli-compass');
compileSass({}, {
  files: [esl.string("payload")]
}).write('.', '.');
