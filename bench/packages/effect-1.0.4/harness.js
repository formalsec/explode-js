const esl = require('esl_symbolic');
const Root = require("effect");
var options = { image: esl.string('payload') };
try {
  Root.edge(options, () => {});
} catch (err) {}
