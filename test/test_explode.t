Test eval explode :
  $ explode-js exploit test_sink_eval.js
         eval : (`source : __$Str)
  Found 1 problems!
    replaying : test_sink_eval.js...
      running : ecma-out/test_sink_eval/test-suite/witness-0.js
       status : true ("success" in stdout)

Test exec explode:
  $ explode-js exploit test_sink_exec.js
         exec : s_concat(["git fetch ", (`remote : __$Str)])
  Found 1 problems!
    replaying : test_sink_exec.js...
      running : ecma-out/test_sink_exec/test-suite/witness-0.js
       status : true (created file "success")

Test polluted explode:
  $ explode-js exploit test_pollution_2.js
        abort : "Prototype pollution detected!"
  Found 1 problems!
    replaying : test_pollution_2.js...
      running : ecma-out/test_pollution_2/test-suite/witness-0.js
       status : true ("polluted" in stdout)

Tests full:
  $ explode-js run test_vfunexported.json
  Genrating ecma-out/symbolic_test_0_0.js
         exec : (`x : __$Str)
  Found 1 problems!
    replaying : ecma-out/symbolic_test_0_0.js...
      running : ecma-out/symbolic_test_0_0/test-suite/witness-0.js
       status : true (created file "success")
