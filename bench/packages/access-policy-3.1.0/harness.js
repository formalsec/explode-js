let a = require("access-policy");
const esl_symbolic = require("esl_symbolic");
let payload = esl_symbolic.string("payload");
esl_symbolic.assume(payload != "");
a.encode(payload, {});
