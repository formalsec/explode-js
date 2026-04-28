const git = require("async-git");
const esl = require('esl_symbolic');
git.reset([esl.string('payload')]);