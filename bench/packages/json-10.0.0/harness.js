const json = require("json");
const esl = require("esl_symbolic");

var lookup = esl.string("lookup");
esl.assume(lookup.startsWith('['));
esl.assume(lookup.endsWith(']'));
esl.assume(lookup.length == 20);

json.parseLookup(lookup);
