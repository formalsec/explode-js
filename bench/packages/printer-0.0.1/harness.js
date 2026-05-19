const esl = require("esl_symbolic");
require.cache["fs"] = { exports: esl.lazy_object() };

const root = require("printer");
root.printDirect({
  data: "",
  printer: esl.string("printer"),
})
