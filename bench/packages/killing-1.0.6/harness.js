const esl = require('esl_symbolic');
const killing = require("killing");
try {
  killing(esl.string("payload"));
} catch (err) {}
