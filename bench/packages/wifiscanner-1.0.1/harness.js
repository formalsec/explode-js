let esl = require("esl_symbolic");
require.cache[require.resolve("nconf")] = { exports: esl.lazy_object() };

let wifiscanner = require("wifiscanner");
let options = {
  args: esl.string("args"),
  binaryPath: esl.string("binaryPath"),
};
esl.assume(options.args != "" && options.binaryPath != "");
try {
  let scanner = wifiscanner(options);
  scanner.scan(function (error, networks) { });
} catch (error) {
  console.log(error);
}

