let esl_symbolic = require("esl_symbolic");
let child_process = require("child_process");
let remote = esl_symbolic.string("remote");
child_process.exec("git fetch " + remote);
