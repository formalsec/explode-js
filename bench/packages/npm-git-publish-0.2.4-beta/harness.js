const git = require("npm-git-publish");
const esl = require("esl_symbolic");
git.publish(".", esl.string("payload"));
