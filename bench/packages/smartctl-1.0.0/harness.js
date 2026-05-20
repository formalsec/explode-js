const esl = require("esl_symbolic");
const smartctl = require('smartctl');
smartctl.info(esl.string("payload"), function () { });
