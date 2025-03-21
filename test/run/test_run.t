Tests full:
  $ explode-js run --deterministic test_vfunexported.json
  ── PHASE 1: TEMPLATE GENERATION ──
  ✔ Loaded: test_vfunexported.json
  ⚒ Generating 1 template(s):
  ├── 📄 ./symbolic_test_0.js
  
  ── PHASE 2: ANALYSIS & VALIDATION ──
  ◉ [1/1] Procesing ./symbolic_test_0.js
  ├── Symbolic execution output:
  Exec failure: x
  ├── ⚠ Detected 1 issue(s)!
  │   ├── ↺ Replaying 2 test case(s)
  │   │   ├── 📄 [1/2] Using test case: ./symbolic_test_0/test-suite/witness-0.json
  │   │   │   ├── Node exited with 0
  │   │   │   └── ✔ Status: Success (created file "./success")
  │   │   ├── 📄 [2/2] Using test case: ./symbolic_test_0/test-suite/witness-1.json
  │   │   │   ├── Node exited with 0
  │   │   │   └── ✔ Status: Success (created file "./success")

  $ explode-js run --deterministic test_usecase_4.json
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
  "Uncaught TypeError"
  Abort: "Uncaught Error: I pollute."
  ├── ⚠ Detected 1 issue(s)!
  │   ├── ↺ Replaying 1 test case(s)
  │   │   ├── 📄 [1/1] Using test case: ./symbolic_test_0/test-suite/witness-0.json
  │   │   │   ├── Node exited with 1
  │   │   │   └── ✔ Status: Success (threw Error("I pollute."))

  $ explode-js run --deterministic test_http_server.json
  ── PHASE 1: TEMPLATE GENERATION ──
  ✔ Loaded: test_http_server.json
  ⚒ Generating 1 template(s):
  
  ── PHASE 2: ANALYSIS & VALIDATION ──
  ◉ [1/1] Procesing ././test_http_server.js
  ├── Symbolic execution output:
  ReadFile failure: (str.++ ("./", request.url))
  ├── ⚠ Detected 1 issue(s)!
  │   ├── ↺ Replaying 1 test case(s)
  │   │   ├── 📄 [1/1] Using test case: ./test_http_server/test-suite/witness-0.json
  │   │   │   ├── Node exited with 0
  │   │   │   └── ✔ Status: Success (undesired file access occurred)
