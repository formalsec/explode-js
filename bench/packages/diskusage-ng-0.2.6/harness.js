const esl = require('esl_symbolic');
const root = require("diskusage-ng");
try {
  root([esl.string('payload')], () => {});
} catch (err) {}
