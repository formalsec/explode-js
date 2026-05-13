const esl = require("esl_symbolic");
const gitSome = require('gitsome');
const payload = esl.string("payload");
const result = gitSome({ path: '/tmp', format: ['%H'], date: payload });
console.log('commits count:', result.commits.length);
