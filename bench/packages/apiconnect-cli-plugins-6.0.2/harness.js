const root = require("apiconnect-cli-plugins/lib/plugin-loader.js");
const esl = require("esl_symbolic");
let payload = esl.string("payload");
root.installPlugin(payload, "");
