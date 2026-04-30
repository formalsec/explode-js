const esl = require('esl_symbolic');
const git = require("git-lib");
try {
  git.add(esl.string('payload'));
} catch (error) {}
