var esl = require("esl_symbolic");
var root = require("create-choo-electron");
root.devInstall("./",[ esl.string("payload") ],function(){})
