const esl = require("esl_symbolic");
require.cache[require.resolve("any-promise")] = { exports: Promise };

const thenify = require("thenify");

function cur() {}
Object.defineProperty(cur, "name", {
  value: esl.string("name"),
 });

thenify(cur);
