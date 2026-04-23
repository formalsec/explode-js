const mp = require("mol-proto");
const esl_symbolic = require("esl_symbolic");
var payload = esl_symbolic.string("payload");
mp.makeFunction(
    "a",
    "b",
    payload
);
//"};require('fs').writeFileSync('./mol-proto', '');{"