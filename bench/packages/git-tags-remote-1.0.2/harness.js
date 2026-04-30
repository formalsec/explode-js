const esl = require('esl_symbolic');
const gitTagsRemote = require("git-tags-remote");
try {
  gitTagsRemote.get(esl.string('payload'));
} catch (err) {}
