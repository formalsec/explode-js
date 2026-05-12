var esl = require("esl_symbolic");
var root = require("create-choo-app3");
root.devInstall("./", [esl.string("payload")], function () { });
