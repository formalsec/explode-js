# Path Traversal

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
[INFO] Detected 1 vulnerabilities.
[STEP 3] Queries: Completed.
── PHASE 1: TEMPLATE GENERATION ──
✔ Loaded: _results/taint_summary.json
⚒ Generating 1 template(s):

── PHASE 2: ANALYSIS & VALIDATION ──
◉ [1/1] Procesing index.js
├── Symbolic execution output:
ReadFile failure: (str.++ ("./", request.url))
├── Symbolic execution stats: clock: 0.266454s | solver: 0.003516s
├── ⚠ Detected 1 issue(s)!
│   ├── ↺ Replaying 1 test case(s)
│   │   ├── 📄 [1/1] Using test case: ./index/test-suite/witness-0.json
│   │   │   ├── Node exited with 0
│   │   │   └── ✔ Status: Success (undesired file access occurred)
```
