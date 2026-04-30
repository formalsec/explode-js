const esl = require("esl_symbolic");
const root = require("git-add-remote")();
let payload = esl.string("payload");
root(payload, "", function () { });
