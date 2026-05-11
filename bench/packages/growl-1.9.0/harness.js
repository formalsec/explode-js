const growl = require("growl");
const esl = require("esl_symbolic");
growl(esl.string("payload"), {}, () => {});
