const esl = require("esl_symbolic");
const find = require("find-process");
find("pid", esl.string("command"));
