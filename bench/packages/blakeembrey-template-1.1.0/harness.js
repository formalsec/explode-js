const { template } = require("@blakeembrey/template");
const esl_symbolic = require("esl_symbolic");

template(esl_symbolic.string("name"), esl_symbolic.string("payload"));
