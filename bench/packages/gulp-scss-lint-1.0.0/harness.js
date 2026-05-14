var esl = require("esl_symbolic");
require.cache[require.resolve("bluebird")] = { exports: Promise };
require.cache[require.resolve("pretty-data")] = { exports: esl.lazy_object() };
require.cache[require.resolve("xml2js")] = { exports: esl.lazy_object() };

var root = require("gulp-scss-lint");
var attack_code = esl.string("src");
var opt = { "src": attack_code }
root(opt);
