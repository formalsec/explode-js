const esl = require("esl_symbolic");
require.cache[require.resolve("shelljs")] = { exports : require("child_process") };
const dnsSync = require("dns-sync");
dnsSync.resolve(esl.string("payload"));

