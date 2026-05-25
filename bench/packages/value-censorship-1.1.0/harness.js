const censor = require("value-censorship");
const esl = require("esl_symbolic");
let payload = esl.string("payload");
censor(payload);
