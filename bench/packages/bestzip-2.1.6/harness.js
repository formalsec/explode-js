const esl = require("esl_symbolic");
// Stub these functions for faster execution
require.cache[require.resolve("which")] = { exports : { sync : function(c, o) { return true; } } };
require.cache[require.resolve("archiver")] = { exports : esl.lazy_object() };

const zip = require("bestzip");
zip({
  source: "",
  destination: esl.string("destination"),
})
