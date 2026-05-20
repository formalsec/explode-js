const esl = require("esl_symbolic");
require.cache[require.resolve("shelljs")] = { exports: require("child_process") };
require.cache[require.resolve("node-sketch")] = { exports: esl.lazy_object() };
require.cache[require.resolve("colors/safe")] = { exports: esl.lazy_object() };
require.cache[require.resolve("@ebay/retriever")] = { exports: esl.lazy_object() };
require.cache[require.resolve("fs-extra")] = { exports: esl.lazy_object() };
require.cache[require.resolve("svgo")] = { exports: esl.lazy_object() };
require.cache[require.resolve("cheerio")] = { exports: esl.lazy_object() };
require.cache[require.resolve("node-emoji")] = { exports: esl.lazy_object() };

const SketchSVG = require('sketchsvg/lib/index');
const inst2 = new SketchSVG();
inst2.getLayers(esl.string("payload"));
