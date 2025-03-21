Test unit:
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/any.json
  ⚒ Generating 1 template(s):
  ├── 📄 -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: command-injection
  var some_arg = esl_symbolic.any("some_arg");
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/array.json
  ⚒ Generating 1 template(s):
  ├── 📄 -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: command-injection
  var some_arg = [ esl_symbolic.string("some_arg0") ];
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/array2.json
  ⚒ Generating 1 template(s):
  ├── 📄 -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: command-injection
  var some_arg =
    [ esl_symbolic.string("some_arg0"), esl_symbolic.boolean("some_arg1"),
      esl_symbolic.number("some_arg2") ];
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/bool.json
  ⚒ Generating 1 template(s):
  ├── 📄 -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: command-injection
  var some_arg = esl_symbolic.boolean("some_arg");
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/function.json
  ⚒ Generating 1 template(s):
  ├── 📄 -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: command-injection
  var some_arg = esl_symbolic.function("some_arg");
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/lazy_object.json
  ⚒ Generating 1 template(s):
  ├── 📄 -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: path-traversal
  var some_arg = esl_symbolic.lazy_object();
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/number.json
  ⚒ Generating 1 template(s):
  ├── 📄 -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: command-injection
  var some_arg = esl_symbolic.number("some_arg");
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/object.json
  ⚒ Generating 1 template(s):
  ├── 📄 -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: command-injection
  var some_arg = {  };
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/polluted_object2.json
  ⚒ Generating 1 template(s):
  ├── 📄 -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: prototype-pollution
  var some_arg = esl_symbolic.polluted_object(2);
  module.exports(some_arg);
  if (({}).polluted == "yes") { throw Error("I pollute."); }
  if (({}).toString == "polluted") { throw Error("I pollute."); }
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/polluted_object3.json
  ⚒ Generating 1 template(s):
  ├── 📄 -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: prototype-pollution
  var some_arg = esl_symbolic.polluted_object(3);
  module.exports(some_arg);
  if (({}).polluted == "yes") { throw Error("I pollute."); }
  if (({}).toString == "polluted") { throw Error("I pollute."); }
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/string.json
  ⚒ Generating 1 template(s):
  ├── 📄 -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: command-injection
  var some_arg = esl_symbolic.string("some_arg");
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/union.json
  ⚒ Generating 3 template(s):
  ├── 📄 -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: command-injection
  var some_arg = esl_symbolic.string("some_arg");
  module.exports(some_arg);
  ├── 📄 -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: command-injection
  var some_arg = esl_symbolic.boolean("some_arg");
  module.exports(some_arg);
  ├── 📄 -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: command-injection
  var some_arg = esl_symbolic.number("some_arg");
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/dynamic.json
  ⚒ Generating 1 template(s):
  ├── 📄 -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: command-injection
  var obj = { dp0: esl_symbolic.any("dp0") };
  module.exports(obj);
