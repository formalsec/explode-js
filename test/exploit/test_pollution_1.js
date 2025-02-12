/* Ok */
let esl_symbolic = require("esl_symbolic");
esl_symbolic.sealProperties(Object.prototype);
let obj = {};
obj.toString = 'polluted';
