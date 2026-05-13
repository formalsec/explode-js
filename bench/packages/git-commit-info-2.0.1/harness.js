const esl = require("esl_symbolic");
require.cache[require.resolve("is-git-repository")] = { exports: () => { return true; } };
require.cache[require.resolve("execa")] = { exports: { commandSync : require("child_process").execSync } };

const gitCommitInfo = require('git-commit-info')
// information of the latest commit in ./my_repo
gitCommitInfo({
  cwd: './my_repo',
  commit: esl.string("commit")
})
