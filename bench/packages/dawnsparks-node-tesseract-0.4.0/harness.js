var esl = require("esl_sybmolic");
require.cache[require.resolve("glob")] = { exports: esl.lazy_object() };


var PUT = require('dawnsparks-node-tesseract');
try {
  new PUT.process(esl.string("payload"), { binary: esl.string("binary") }, function () { });
} catch (e) {
  console.log(e);
}
