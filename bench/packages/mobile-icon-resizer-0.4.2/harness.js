const esl = require("esl_symbolic");
// Stub problematic stuff
process.env.TEST_COV = undefined;
require.cache[require.resolve("image-size")] = { exports : esl.lazy_object() };

const resize = require("mobile-icon-resizer");

let options = {
  config: "./config.js"
};

resize(options, function (err) { });
