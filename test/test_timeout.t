Test that timeout works:
  $ explode-js exploit --timeout 5 test_timeout.js
        abort : "Uncaught SyntaxError: Must include statements to encode"
         eval : s_concat(["`", (`x0 : __$Str), "`"])
  Found 2 problems!
    replaying : test_timeout.js...
      running : explode-out/test_timeout/test-suite/witness-0.json
       status : false (no side effect)
  unexpected node failure: /home/filipe/projects/explode-js/_build/default/test/test_timeout.js:11
      throw new SyntaxError('Must include statements to encode');
      ^
  
  SyntaxError: Must include statements to encode
      at Module.encodeStatements [as exports] (/home/filipe/projects/explode-js/_build/default/test/test_timeout.js:11:11)
      at Object.<anonymous> (/home/filipe/projects/explode-js/_build/default/test/test_timeout.js:36:8)
      at Module._compile (node:internal/modules/cjs/loader:1572:14)
      at Object..js (node:internal/modules/cjs/loader:1709:10)
      at Module.load (node:internal/modules/cjs/loader:1315:32)
      at Function._load (node:internal/modules/cjs/loader:1125:12)
      at TracingChannel.traceSync (node:diagnostics_channel:322:14)
      at wrapModuleLoad (node:internal/modules/cjs/loader:216:24)
      at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:170:5)
      at node:internal/main/run_main_module:36:49
  
  Node.js v23.1.0
