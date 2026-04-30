const esl = require('esl_symbolic');
const asciinema = require("extra-asciinema");
try {
  asciinema.uploadSync(esl.string('payload'));
} catch (err) {}
