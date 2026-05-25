const esl_symbolic = require("esl_symbolic");

const pushDir = require('push-dir');
var maliciousBranch = esl_symbolic.string("maliciousBranch");

//const maliciousBranch = 'attacker; touch ' + PROOF_FILE + ' #';

pushDir({
  branch: maliciousBranch,
  dir: '.',
  'allow-unclean': true,
  'overwrite-local': true
});
