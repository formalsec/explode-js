const esl = require('esl_symbolic');
const { FSGit } = require('fs-git');

try {
    FSGit.prototype.readFile(esl.string('payload'), {});
} catch (err) {}
