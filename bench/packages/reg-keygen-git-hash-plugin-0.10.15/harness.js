const esl = require('esl_symbolic');
'use strict';

const { GitCmdClient } = require('reg-keygen-git-hash-plugin/lib/git-cmd-client');

const client = new GitCmdClient();

try {
  client.containedBranches(esl.string('payload'));
} catch (e) {}
