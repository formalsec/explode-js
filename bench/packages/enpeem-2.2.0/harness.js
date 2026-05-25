var esl = require("esl_symbolic");
const root = require("enpeem");
let attack_code = esl.string("production");
let opts = { production: attack_code };
root.update(opts, function (err) {});
