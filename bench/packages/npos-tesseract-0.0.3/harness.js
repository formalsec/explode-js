var esl = require("esl_symbolic");
require.cache[require.resolve("node-uuid")] = { exports: esl.lazy_object() };

// Promise.promisify = require("util").promisify;
// require.cache[require.resolve("bluebird")] = { exports: Promise };

var a = require("npos-tesseract");
a.ocr(esl.string("payload"),"",function(){});
