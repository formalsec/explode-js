# Package example

```sh
$ explode-js package
── PHASE 0: VULNERABILITY DETECTION ──
Detected 1 potential issue(s):
├── Issue 0: command-injection @ /home/filipe/projects/explode-js/_build/default/example/package-example/_results/20250512T211823/index.js:10
│   └── 10|  return exec(command);

── PHASE 1: TEMPLATE GENERATION ──
✔ Loaded: ./taint_summary.json
⚒ Generating 1 template(s):
├── 📄 ./symbolic_test_0.js

── PHASE 2: ANALYSIS & VALIDATION ──
◉ [1/1] Procesing ./symbolic_test_0.js
├── Symbolic execution output:
"File too big"
Exec failure: (str.++ ("rsync -av /tmp/0 ", userId, "@", host, ":", usrDir))
├── Symbolic execution stats: clock: 40.317392s | solver: 39.864743s
├── ⚠ Detected 1 issue(s)!
│   ├── ↺ Replaying 2 test case(s)
│   │   ├── 📄 [1/2] Using test case: ./symbolic_test_0/test-suite/witness-0.json
│   │   │   ├── Node exited with 0
│   │   │   └── ✔ Status: Success (created file "./success")
```
