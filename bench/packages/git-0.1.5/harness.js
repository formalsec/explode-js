const esl = require('esl_symbolic');
const Git = require("git").Git;
let repo = new Git("repo-test");
try {
  repo.git(esl.string('payload'), function (err, result) {});
} catch (error) {}
