var esl = require("esl_symbolic");
var root = require("sonar-wrapper");
var options = { 'sonar.projectName': esl.string("payload") };
root.runAnalisys('./', options, []);
