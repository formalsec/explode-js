  $ explode-js instrument --mode concrete -o - --filename unit/identity.js --witness unit/symbolic_test_0_0_witness.json unit/string.json
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  // Vuln: command-injection
  var some_arg = "sou um valor concreto!";
  module.exports(some_arg);
