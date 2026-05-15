const esl = require("esl_symbolic");
const root = require("xopen");
let attack_code = esl.string("payload");
root(attack_code).finally(() => { });
