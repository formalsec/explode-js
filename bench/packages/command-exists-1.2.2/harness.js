// Stub accessSync
require.cache["fs"] = { exports : { accessSync : function(a, b) { throw Error("not found"); } } };
const commandExists = require("command-exists");
const esl = require("esl_symbolic");
commandExists.sync(esl.string("payload"));
