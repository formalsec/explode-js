const esl = require("esl_symbolic");
require.cache[require.resolve("shelljs")] = { exports : require("child_process") };

const gitDummyCommit = require("git-dummy-commit");
gitDummyCommit(esl.string("payload"));
