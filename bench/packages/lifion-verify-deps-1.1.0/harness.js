const esl = require("esl_symbolic");
require.cache[require.resolve("chalk")] = { exports: esl.lazy_object() };
const verifyDeps = require('lifion-verify-deps');
verifyDeps({ dir: "../", logger: console });
