const Symbolic = require("esl_symbolic");
const Root = require("clamscan");

async function run() {
  var root = new Root();
  await root.init({
    clamscan: { path: Symbolic.string("clamscan.path") },
    clamdscan: { path: Symbolic.string("clamdscan.path") },
  })
}

run();
