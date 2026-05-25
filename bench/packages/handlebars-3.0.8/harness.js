const hbs = require("handlebars");
const esl = require("esl_symbolic");
hbs.compile(esl.string("payload"));
