const esl = require("esl_symbolic");
const Root = require("clamscan");

var root = new Root();
root.init({
  clamscan: { path: esl.string("clamscan.path") },
  clamdscan: { path: esl.string("clamdscan.path") },
})
