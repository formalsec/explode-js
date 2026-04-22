const A = require("node-rules");
const esl = require("esl_symbolic");

var a = new A();
var rules = {
  condition: esl.string("condition"),
  consequence: esl.string("consequence")
};
a.fromJSON(rules);
