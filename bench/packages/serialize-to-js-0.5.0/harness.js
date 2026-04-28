const serialize = require("serialize-to-js");
const esl = require("esl_symbolic");
let payload = esl.string("payload");
serialize.deserialize(payload);
