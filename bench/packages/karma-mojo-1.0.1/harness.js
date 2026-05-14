var esl = require("esl_symbolic");
var root = require("karma-mojo");
var config = {
  runnerPath: './karma.log',
  grep: esl.string("grep"),
  grepDir: "",
  length: 1
}
root['reporter:mojo'][1]('', config, '', { 'create': function () { } });
