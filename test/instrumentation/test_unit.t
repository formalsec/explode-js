Test unit:
  $ instrumentation2 symbolic -o - unit/any.json unit/identity.js
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  let esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  let some_arg = esl_symbolic.any("some_arg");
  module.exports(some_arg);
  $ instrumentation2 symbolic -o - unit/array.json unit/identity.js
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  let esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  let some_arg = [ esl_symbolic.string("some_arg0") ];
  module.exports(some_arg);
  $ instrumentation2 symbolic -o - unit/array2.json unit/identity.js
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  let esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  let some_arg =
    [ esl_symbolic.string("some_arg0"), esl_symbolic.boolean("some_arg1"), esl_symbolic.number("some_arg2") ];
  module.exports(some_arg);
  $ instrumentation2 symbolic -o - unit/bool.json unit/identity.js
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  let esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  let some_arg = esl_symbolic.boolean("some_arg");
  module.exports(some_arg);
  $ instrumentation2 symbolic -o - unit/function.json unit/identity.js
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  let esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  let some_arg = esl_symbolic.function("some_arg");
  module.exports(some_arg);
  $ instrumentation2 symbolic -o - unit/lazy_object.json unit/identity.js
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  let esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: path-traversal
  let some_arg = esl_symbolic.lazy_object();
  module.exports(some_arg);
  $ instrumentation2 symbolic -o - unit/number.json unit/identity.js
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  let esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  let some_arg = esl_symbolic.number("some_arg");
  module.exports(some_arg);
  $ instrumentation2 symbolic -o - unit/object.json unit/identity.js
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  let esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  let some_arg = {  };
  module.exports(some_arg);
  $ instrumentation2 symbolic -o - unit/polluted_object2.json unit/identity.js
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  let esl_symbolic = require("esl_symbolic");
  // Vuln: prototype-pollution
  let some_arg = esl_symbolic.polluted_object(2);
  module.exports(some_arg);
  if (({}).toString == "polluted") { throw Error("I pollute."); }
  $ instrumentation2 symbolic -o - unit/polluted_object3.json unit/identity.js
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  let esl_symbolic = require("esl_symbolic");
  // Vuln: prototype-pollution
  let some_arg = esl_symbolic.polluted_object(3);
  module.exports(some_arg);
  if (({}).toString == "polluted") { throw Error("I pollute."); }
  $ instrumentation2 symbolic -o - unit/string.json unit/identity.js
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  let esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  let some_arg = esl_symbolic.string("some_arg");
  module.exports(some_arg);
  $ instrumentation2 symbolic -o - unit/union.json unit/identity.js
  Genrating -
  Genrating -
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  let esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  let some_arg = esl_symbolic.string("some_arg");
  module.exports(some_arg);
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  let esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  let some_arg = esl_symbolic.boolean("some_arg");
  module.exports(some_arg);
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  let esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  let some_arg = esl_symbolic.number("some_arg");
  module.exports(some_arg);
  $ instrumentation2 symbolic -o - unit/dynamic.json unit/identity.js
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  let esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  let obj = { dp0: esl_symbolic.any("dp0") };
  module.exports(obj);
