const esl = require('esl_symbolic');
const Root = require("compass-compile");
let root = new Root();
let options = { compassCommand: [esl.string('payload')] };
try {
  root.compile(options).then(() => {}).catch((err) => {});
} catch (err) {}
