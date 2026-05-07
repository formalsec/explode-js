// Stub shelljs
const esl = require("esl_symbolic");
require.cache[require.resolve("shelljs/global")] = { exports: esl.lazy_object() };
const { exec } = require("child_process");
global.exec = exec;

// Harness
const aaptjs = require("aaptjs");
aaptjs.add(esl.string("payload"), [], (err, data) => {});
