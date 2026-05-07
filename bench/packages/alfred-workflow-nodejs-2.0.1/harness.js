const AlfredNode = require("alfred-workflow-nodejs");
const esl = require("esl_symbolic");
var utils = AlfredNode.utils;
utils.wfVars.remove(esl.string("payload"));
