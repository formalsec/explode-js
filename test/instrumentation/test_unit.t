Test unit:
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/any.json
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  var some_arg = esl_symbolic.any("some_arg");
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/array.json
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  var some_arg = [ esl_symbolic.string("some_arg0") ];
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/array2.json
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  var some_arg =
    [ esl_symbolic.string("some_arg0"), esl_symbolic.boolean("some_arg1"), esl_symbolic.number("some_arg2") ];
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/bool.json
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  var some_arg = esl_symbolic.boolean("some_arg");
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/function.json
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  var some_arg = esl_symbolic.function("some_arg");
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/lazy_object.json
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: path-traversal
  var some_arg = esl_symbolic.lazy_object();
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/number.json
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  var some_arg = esl_symbolic.number("some_arg");
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/object.json
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  var some_arg = {  };
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/polluted_object2.json
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: prototype-pollution
  var some_arg = esl_symbolic.polluted_object(2);
  module.exports(some_arg);
  if (({}).toString == "polluted") { throw Error("I pollute."); }
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/polluted_object3.json
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: prototype-pollution
  var some_arg = esl_symbolic.polluted_object(3);
  module.exports(some_arg);
  if (({}).toString == "polluted") { throw Error("I pollute."); }
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/string.json
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  var some_arg = esl_symbolic.string("some_arg");
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/union.json
  Genrating -
  Genrating -
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  var some_arg = esl_symbolic.string("some_arg");
  module.exports(some_arg);
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  var some_arg = esl_symbolic.boolean("some_arg");
  module.exports(some_arg);
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  var some_arg = esl_symbolic.number("some_arg");
  module.exports(some_arg);
  $ explode-js instrument --mode symbolic -o - --filename unit/identity.js unit/dynamic.json
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  var obj = { dp0: esl_symbolic.any("dp0") };
  module.exports(obj);
