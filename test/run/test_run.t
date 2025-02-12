Tests full:
  $ explode-js run test_vfunexported.json --filename ./test_vfunexported.js
  Genrating ./symbolic_test_0.js
         exec : x
  Found 1 problems!
    replaying : ./symbolic_test_0.js...
  Genrating ./symbolic_test_0/literal_0.js
      running : ./symbolic_test_0/test-suite/witness-0.json
       status : true (created file "success")
  $ explode-js run test_usecase_4.json
  Genrating _results/symbolic_test_0_0.js
  "Uncaught TypeError"
  "Uncaught TypeError"
  "Uncaught TypeError"
  "Uncaught TypeError"
  "Uncaught TypeError"
  "Uncaught TypeError"
  "Uncaught TypeError"
        abort : "Uncaught Error: I pollute."
  Found 1 problems!
    replaying : _results/symbolic_test_0_0.js...
  Genrating _results/symbolic_test_0_0/literal_0_0.js
      running : _results/symbolic_test_0_0/test-suite/witness-0.json
       status : true (threw Error("I pollute."))
  unexpected node failure: $TESTCASE_ROOT/_results/symbolic_test_0_0.js:51
  if (({}).toString == "polluted") { throw Error("I pollute."); }
                                     ^

  Error: I pollute.
      at Object.<anonymous> ($TESTCASE_ROOT/_results/symbolic_test_0_0.js:51:42)
      at Module._compile (node:internal/modules/cjs/loader:1356:14)
      at Module._extensions..js (node:internal/modules/cjs/loader:1414:10)
      at Module.load (node:internal/modules/cjs/loader:1197:32)
      at Module._load (node:internal/modules/cjs/loader:1013:12)
      at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:128:12)
      at node:internal/main/run_main_module:28:49

  Node.js v18.19.1
