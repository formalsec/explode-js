var esl = require("esl_symbolic");
require.cache[require.resolve("babel-core")] = { exports : esl.lazy_object() };
require.cache[require.resolve("esprima")] = { exports : esl.lazy_object() };
require.cache[require.resolve("uglify-js")] = { exports : esl.lazy_object() };
require.cache[require.resolve("esprima-walk")] = { exports : esl.lazy_object() };
var root = require("buns");
root.install(esl.string("name"));

