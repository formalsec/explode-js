Test that timeout works:
  $ explode-js exploit --timeout 5 test_timeout.js
        abort : "Uncaught SyntaxError: Must include statements to encode"
  Found 1 problems!
    replaying : test_timeout.js...
      running : _results/test_timeout/test-suite/witness-0.json
       status : false (no side effect)
  unexpected node failure: /home/filipe/projects/explode-js/_build/default/test/test_timeout.js:11
      throw new SyntaxError('Must include statements to encode');
      ^
  
  SyntaxError: Must include statements to encode
      at Module.encodeStatements [as exports] (/home/filipe/projects/explode-js/_build/default/test/test_timeout.js:11:11)
      at Object.<anonymous> (/home/filipe/projects/explode-js/_build/default/test/test_timeout.js:36:8)
      at Module._compile (node:internal/modules/cjs/loader:1356:14)
      at Module._extensions..js (node:internal/modules/cjs/loader:1414:10)
      at Module.load (node:internal/modules/cjs/loader:1197:32)
      at Module._load (node:internal/modules/cjs/loader:1013:12)
      at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:128:12)
      at node:internal/main/run_main_module:28:49
  
  Node.js v18.19.1
