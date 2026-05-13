const esl = require("esl_symbolic");
const git = require("git-promise");
// Use the shell's predefined separator using ${IFS} to escape the whitespace splitting logic
git(esl.string("payload"), {cwd: "./"}).then((output) => console.log(output));
