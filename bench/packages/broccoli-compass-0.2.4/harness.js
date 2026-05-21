var esl = require("esl_symbolic");
var compileSass = require('broccoli-compass');
compileSass({}, {
  files: [esl.string("payload")]
}).write('.', '.');
