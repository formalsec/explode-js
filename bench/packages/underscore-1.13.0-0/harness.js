const _ = require("underscore");
const esl_symbolic = require("esl_symbolic");
var settings = { variable: esl_symbolic.string("variable") };
const t = _.template("", settings)();
