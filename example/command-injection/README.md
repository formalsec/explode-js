# Command Injection

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
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Running prototype pollution query.
[INFO] Prototype Pollution - Reconstructing attacker-controlled data.
[INFO] Detected 1 vulnerabilities.
[STEP 3] Queries: Completed.
── PHASE 1: TEMPLATE GENERATION ──
✔ Loaded: _results/taint_summary.json
⚒ Generating 1 template(s):
├── 📄 ./symbolic_test_0.js

── PHASE 2: ANALYSIS & VALIDATION ──
◉ [1/1] Procesing ./symbolic_test_0.js
├── Symbolic execution output:
"Uncaught TypeError"
"Uncaught TypeError"
"File too big"
Exec failure: (str.++ ("rsync -av /tmp/0 ", id, "@", host, ":", dstDir))
├── Symbolic execution stats: clock: 43.508250s | solver: 43.141939s
├── ⚠ Detected 1 issue(s)!
│   ├── ↺ Replaying 2 test case(s)
│   │   ├── 📄 [1/2] Using test case: ./symbolic_test_0/test-suite/witness-0.json
│   │   │   ├── Node exited with 0
│   │   │   └── ✔ Status: Success (created file "./success")
```
