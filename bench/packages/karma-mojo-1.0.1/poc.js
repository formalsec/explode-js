var root = require("karma-mojo");
var config = {
  runnerPath: './karma.log',
  grep: "\"& touch success\"",
  grepDir: "",
  length: 1
}
root['reporter:mojo'][1]('', config, '', { 'create': function () { } });
