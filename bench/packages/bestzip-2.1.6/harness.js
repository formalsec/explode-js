
const zip = require("bestzip");
const esl = require('esl_symbolic'); 
zip({
  source: "",
  destination: [esl.string('payload')],
})

