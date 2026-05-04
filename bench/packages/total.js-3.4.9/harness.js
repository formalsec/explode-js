// Stub cache so utils doesn't require index.js
global.F = {
  temporary : { other : {} },
  install: function install(a, b, cb) {},
};

const utils = require("total.js/utils");
const esl = require("esl_symbolic");

utils.get({}, esl.string("path"));
