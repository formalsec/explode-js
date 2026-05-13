const git = require("git-promise");
// Use the shell's predefined separator using ${IFS} to escape the whitespace splitting logic
git("fetch origin --upload-pack=touch${IFS}/tmp/abcd-new", {cwd: '/tmp/example-git-repo'}).then((output) => console.log(output))
