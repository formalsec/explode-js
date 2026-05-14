var esl = require("esl_symbolic");
require.cache[require.resolve("node-uuid")] = { exports : esl.lazy_object() };

var a =require("ntesseract");
a.process(esl.string("payload"),"",function(){})
