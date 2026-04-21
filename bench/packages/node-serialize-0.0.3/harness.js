const serialize = require("node-serialize");
const esl_symbolic = require("esl_symbolic");
var obj = { "rce" : esl_symbolic.string("payload") };
serialize.unserialize(obj);

