var esl = require("esl_symbolic");
var root = require("puppet-facter")
root.getFact(esl.string("payload"), function () { }, {})
