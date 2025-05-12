# Prototype Pollution

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
[INFO] Running prototype pollution query.
[INFO] Prototype Pollution - Reconstructing attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Detected 1 vulnerabilities.
[STEP 3] Queries: Completed.
── PHASE 1: TEMPLATE GENERATION ──
✔ Loaded: _results/taint_summary.json
⚒ Generating 2 template(s):
├── 📄 ./symbolic_test_0.js
├── 📄 ./symbolic_test_1.js

── PHASE 2: ANALYSIS & VALIDATION ──
◉ [1/2] Procesing ./symbolic_test_0.js
├── Symbolic execution output:
├── Symbolic execution stats: clock: 0.438087s | solver: 0.104111s
└── ✔ No issues detected.
◉ [2/2] Procesing ./symbolic_test_1.js
├── Symbolic execution output:
"Uncaught TypeError"
"Uncaught TypeError"
"Uncaught TypeError"
"Uncaught TypeError"
"Uncaught TypeError"
"Uncaught TypeError"
"Uncaught TypeError"
"Uncaught TypeError"
Abort: "Uncaught Error: I pollute."
├── Symbolic execution stats: clock: 7.269718s | solver: 6.420542s
├── ⚠ Detected 1 issue(s)!
│   ├── ↺ Replaying 1 test case(s)
│   │   ├── 📄 [1/1] Using test case: ./symbolic_test_1/test-suite/witness-0.json
│   │   │   ├── Node exited with 1
│   │   │   └── ✔ Status: Success (threw Error("I pollute."))
```
