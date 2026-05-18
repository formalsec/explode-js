const esl = require("esl_symbolic");
const npm = require('npm-programmatic');

const installPayload = [esl.string("payload")];

npm.install(installPayload, { cwd: './', maxBuffer: 1024 * 1024 });
