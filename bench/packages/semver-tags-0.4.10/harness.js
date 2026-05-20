var esl = require("esl_symbolic");
var r = require("semver-tags")
opt = { repoType: "git", repoPath: esl.string("repoPath") }
finalCb = console.log
r(opt, finalCb)
