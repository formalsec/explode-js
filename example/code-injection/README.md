# Code Injection

```sh
$ explode-js full index.js
[STEP 1] MDG: Generating...

[STEP 1] MDG: Completed.
[STEP 2] Queries: Importing the graph...
[INFO] Stop running Neo4j local instance.
[INFO] Import MDG to Neo4j.
[INFO] Starting Neo4j
[STEP 2] Queries: Imported
[STEP 3] Queries: Traversing Graph...
[INFO] Running injection query.
[INFO] Reconstructing attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Running prototype pollution query.
[INFO] Prototype Pollution - Reconstructing attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Detected 7 vulnerabilities.
[STEP 3] Queries: Completed.
── PHASE 1: TEMPLATE GENERATION ──
✔ Loaded: _results/taint_summary.json
⚒ Generating 28 template(s):
├── 📄 ./symbolic_test_0.js
├── 📄 ./symbolic_test_1.js
├── 📄 ./symbolic_test_2.js
├── 📄 ./symbolic_test_3.js
├── 📄 ./symbolic_test_4.js
├── 📄 ./symbolic_test_5.js
├── 📄 ./symbolic_test_6.js
├── 📄 ./symbolic_test_7.js
├── 📄 ./symbolic_test_8.js
├── 📄 ./symbolic_test_9.js
├── 📄 ./symbolic_test_10.js
├── 📄 ./symbolic_test_11.js
├── 📄 ./symbolic_test_12.js
├── 📄 ./symbolic_test_13.js
├── 📄 ./symbolic_test_14.js
├── 📄 ./symbolic_test_15.js
├── 📄 ./symbolic_test_16.js
├── 📄 ./symbolic_test_17.js
├── 📄 ./symbolic_test_18.js
├── 📄 ./symbolic_test_19.js
├── 📄 ./symbolic_test_20.js
├── 📄 ./symbolic_test_21.js
├── 📄 ./symbolic_test_22.js
├── 📄 ./symbolic_test_23.js
├── 📄 ./symbolic_test_24.js
├── 📄 ./symbolic_test_25.js
├── 📄 ./symbolic_test_26.js
├── 📄 ./symbolic_test_27.js

── PHASE 2: ANALYSIS & VALIDATION ──
◉ [1/28] Procesing ./symbolic_test_0.js
├── Symbolic execution output:
Eval failure: (str.++ ("(",
               (str.substr dp0 13
                (int.add
                 (int.sub
                  (int.reinterpret_float
                   (real.reinterpret_int (str.length dp0))) 13) 1)), ")"))
├── Symbolic execution stats: clock: 32.300943s | solver: 31.997247s
├── ⚠ Detected 1 issue(s)!
│   ├── ↺ Replaying 4 test case(s)
│   │   ├── 📄 [1/4] Using test case: ./symbolic_test_0/test-suite/witness-0.json
│   │   │   ├── Node exited with 1
│   │   │   └── ✖ Status: No side effect
│   │   ├── 📄 [2/4] Using test case: ./symbolic_test_0/test-suite/witness-1.json
│   │   │   ├── Node exited with 0
│   │   │   └── ✔ Status: Success ("success" in stdout)
│   │   ├── 📄 [3/4] Using test case: ./symbolic_test_0/test-suite/witness-2.json
│   │   │   ├── Node exited with 0
│   │   │   └── ✔ Status: Success ("success" in stdout)
```
