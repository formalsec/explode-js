const AlfredNode = require("alfred-workflow-nodejs");
var utils = AlfredNode.utils;
const esl = require('esl_symbolic');
utils.wfVars.remove([esl.string('payload')], function () { });
