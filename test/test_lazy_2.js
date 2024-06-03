var esl_symbolic = require("esl_symbolic");
var fs = require("fs");

let x = esl_symbolic.string("x");
if (!fs.existsSync(x)) {
  console.log(true);
} else {
  console.log(false);
}
