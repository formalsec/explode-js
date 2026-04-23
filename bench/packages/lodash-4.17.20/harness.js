var _ = require('lodash');
const esl_symbolic = require("esl_symbolic");
var payload = esl_symbolic.string("payload");
_.template('', { variable: payload })();
//'){console.log("Hacked")}; with(obj'
