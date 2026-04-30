'use strict';

const esl = require('esl_symbolic');
const Entitlements = require('entitlements');

try {
  Entitlements(esl.string('payload'), function (error, data) {});
} catch (_) {}
