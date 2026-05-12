var esl = require("esl_symbolic");
var PUT = require('font-converter');
var x = esl.string("payload");
try {
    new PUT(x, x, x, x);
} catch (e) {
    console.log(e);
}
