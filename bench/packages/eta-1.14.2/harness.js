const eta = require("eta");
const esl = require("esl_symbolic");

var config = { async : false, varName : esl.string("varName") };
eta.compile("", config);
