const Djv = require("djv");
const esl_symbolic = require("esl_symbolic");

const env = new Djv();
const evilSchema = { "common" : { "type" : "array", "minItems" : esl_symbolic.string("minItems") } };
env.addSchema("test", evilSchema);
env.validate("test#/common", { type: "custom" });
