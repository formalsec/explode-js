const esl = require("esl_symbolic");
// require.cache[require.resolve("bluebird")] = { exports: esl.lazy_object() };

const a = require("ggit");
a.fetchTags(esl.string("payload"));
