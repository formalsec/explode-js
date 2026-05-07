const esl = require("esl_symbolic");
require.cache[require.resolve("debug")] = { exports: esl.lazy_object() };

const morgan = require("morgan");

morgan.compile(esl.string("format"));

