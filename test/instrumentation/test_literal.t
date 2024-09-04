  $ instrumentation2 literal -o - unit/string.json unit/identity.js --witness unit/symbolic_test_0_0_witness.json
  Genrating -
  module.exports = function identity(some_arg) {
    return some_arg
  }
  
  // Vuln: command-injection
  let some_arg = "sou um valor concreto!";
  module.exports(some_arg);
