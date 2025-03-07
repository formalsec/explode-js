Tests full:
  $ explode-js run test_vfunexported.json
  ── PHASE 1: TEMPLATE GENERATION ──
  ✔ Loaded: test_vfunexported.json
  ⚒ Generating 1 template(s):
  ├── 📄 ./symbolic_test_0.js
  
  ── PHASE 2: ANALYSIS & VALIDATION ──
  ◉ [1/1] Procesing ./symbolic_test_0.js
  ├── Symbolic execution output:
  Exec failure: x
  ├── Symbolic execution stats: clock: 0.357199s | solver: 0.001722s
  ├── ⚠ Detected 1 issue(s)!
  │   ├── ↺ Replaying 1 test case(s)
  │   │   ├── 📄 [1/1] Using test case: ./symbolic_test_0/test-suite/witness-0.json
  │   │   │   ├── Node exited with 0
  │   │   │   └── ✔ Status: Success (created file "./success")
  $ explode-js run test_usecase_4.json
  ── PHASE 1: TEMPLATE GENERATION ──
  ✔ Loaded: test_usecase_4.json
  ⚒ Generating 1 template(s):
  ├── 📄 ./symbolic_test_0.js
  
  ── PHASE 2: ANALYSIS & VALIDATION ──
  ◉ [1/1] Procesing ./symbolic_test_0.js
  ├── Symbolic execution output:
  "Uncaught TypeError"
  "Uncaught TypeError"
  "Uncaught TypeError"
  "Uncaught TypeError"
  "Uncaught TypeError"
  "Uncaught TypeError"
  Abort: "Uncaught Error: I pollute."
  ├── Symbolic execution stats: clock: 7.546626s | solver: 6.631817s
  ├── ⚠ Detected 1 issue(s)!
  │   ├── ↺ Replaying 1 test case(s)
  │   │   ├── 📄 [1/1] Using test case: ./symbolic_test_0/test-suite/witness-0.json
  │   │   │   ├── Node exited with 1
  │   │   │   └── ✔ Status: Success (threw Error("I pollute."))
