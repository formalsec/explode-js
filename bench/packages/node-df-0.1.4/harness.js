const df = require("node-df");
const esl = require("esl_symbolic");
const options = {
  file: esl.string("file"),
  prefixMultiplier: "GB",
  isDisplayPrefixMultiplier: true,
  precision: 2,
};
df(options, function (error, response) { });
