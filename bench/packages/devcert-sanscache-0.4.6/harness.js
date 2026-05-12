var esl = require("esl_symbolic");
require.cache["fs"] = { exports: { writeFileSync: function(a, b) { return; } } };
require.cache[require.resolve("command-exists")] = { exports : { sync : function(a) { return true; } } };

var root = require("devcert-sanscache");
root(esl.string("commandName"));
