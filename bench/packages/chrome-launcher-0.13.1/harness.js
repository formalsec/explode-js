var esl = require("esl_symbolic");
require.cache[require.resolve("lighthouse-logger")] = { exports : esl.lazy_object() };
process.env.HOME += "/" + malicious_code;

var malicious_code = esl.string("payload");
var Root = require("chrome-launcher");
Root.launch();
