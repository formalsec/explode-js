const esl = require("esl_symbolic");
require.cache[require.resolve("ssh2/lib/protocol/keyParser.js")] = { exports: esl.lazy_object() };

const agent = require('ssh2/lib/agent');
agent(esl.string("payload"), (e) => {console.log(e)});
