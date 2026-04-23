const thenify = require("thenify");
const esl = require("esl_symbolic");

function cur() {}
Object.defineProperty(cur, "name", {
  value: esl.string("name"),
 });

thenify(cur);
