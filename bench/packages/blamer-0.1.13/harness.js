// Stub problematic module.
require.cache[require.resolve('bluebird')] = { exports : Promise };
const Root = require("blamer");
const esl = require("esl_symbolic");
let cmd = esl.string("cmd");
var root = new Root("git", cmd);
root.blameByFile("./");

