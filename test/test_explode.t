Test eval explode :
  $ explode-js exploit test_sink_eval.js
         eval : (`source : __$Str)
  Found 1 problems!
    replaying : test_sink_eval.js...
      running : explode-out/test_sink_eval/test-suite/witness-0.js
       status : true ("success" in stdout)

Test exec explode:
  $ explode-js exploit test_sink_exec.js
         exec : s_concat(["git fetch ", (`remote : __$Str)])
  Found 1 problems!
    replaying : test_sink_exec.js...
      running : explode-out/test_sink_exec/test-suite/witness-0.js
       status : true (created file "success")
Test readFile explode
  $ explode-js exploit test_sink_fs.js
     readFile : (`source : __$Str)
  Found 1 problems!
    replaying : test_sink_fs.js...
      running : explode-out/test_sink_fs/test-suite/witness-0.js
       status : true (undesired file access occurred)

Test polluted explode:
  $ explode-js exploit test_pollution_2.js
        abort : "Prototype pollution detected!"
  Found 1 problems!
    replaying : test_pollution_2.js...
      running : explode-out/test_pollution_2/test-suite/witness-0.js
       status : true ("polluted" in stdout)

Tests full:
  $ explode-js run test_vfunexported.json
  Genrating explode-out/symbolic_test_0_0.js
         exec : (`x : __$Str)
  Found 1 problems!
    replaying : explode-out/symbolic_test_0_0.js...
      running : explode-out/symbolic_test_0_0/test-suite/witness-0.js
       status : true (created file "success")
