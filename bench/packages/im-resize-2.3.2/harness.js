const esl = require('esl_symbolic');
const root = require("im-resize");

let image = { path: esl.string('payload') };
let output = { versions: [] };
try {
  root(image, output, function () {});
} catch (err) {}
