const ps = require("xps");
const esl = require("esl_symbolic");
ps.kill(esl.string("payload")).fork(() => {});
