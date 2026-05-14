const esl = require("esl_symbolic");
require.cache[require.resolve("debug")] = { exports : esl.lazy_object() };

const Test = require("giting");

var test = new Test({ workDir: "./" });
repo = {
  organization: "./",
  name: "./",
  branch: esl.string("branch"),
};
test.pull(repo, function () { });
