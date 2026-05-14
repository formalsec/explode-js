var esl = require("esl_symbolic");
require.cache[require.resolve('plugin-error')] = { exports : esl.lazy_object() };
require.cache[require.resolve('tap-parser')] = { exports : esl.lazy_object() };
var gulpTape = require("gulp-tape");
var options = {
  name: esl.string("name")
}
gulpTape(options);

