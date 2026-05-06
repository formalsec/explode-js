const typed = require("typed-function");
const esl = require("esl_symbolic");

var name = esl.string("name");
typed(name , { "": function () {} });
