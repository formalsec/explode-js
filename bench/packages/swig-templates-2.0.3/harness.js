const swig = require("swig-templates");
const esl = require("esl_symbolic");
swig.compile(esl.string("source"));
