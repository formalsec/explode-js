var esl = require("esl_symbolic");
var root = require("fsa");
var attack_code = esl.string("payload");
var dir = "./";
var options= {};
root.rep.execGitCommand(attack_code,dir,options,function(){});
