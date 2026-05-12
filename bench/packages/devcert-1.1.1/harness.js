const esl = require("esl_symbolic");
require.cache[require.resolve("tmp")] = { exports : esl.lazy_object() };

const { run } = require("devcert/dist/utils");
run("sh", ["-c", esl.string("payload")], {});
