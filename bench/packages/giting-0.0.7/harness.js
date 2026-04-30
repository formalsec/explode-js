const esl = require('esl_symbolic');
const Test = require("giting");

const test = new Test({ workDir: "./" });
const repo = {
  organization: "./",
  name: "./",
  branch: esl.string('payload'),
};
try {
  test.pull(repo, function () {});
} catch (err) {}
