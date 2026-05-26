var esl = require("esl_symbolic");
var root = require("global-modules-path");
var executable = esl.string("executable");
esl.assume(executable != "");
root.getPath(esl.string("module"), executable);
