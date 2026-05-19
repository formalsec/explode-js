const esl = require("esl_symbolic");
require.cache[require.resolve("yargs")] = { exports: esl.lazy_object() };

const root = require("proctree");
root.getProcessTree(esl.string("payload"), () => { })
