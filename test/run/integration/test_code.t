  $ cd ../../packages/code-01; explode-js run
  [+] Starting static analysis (dir .)
  [+] Found 7 potential vulnerabilties
  [+] Testing code-injection vulnerability ...
  [+] Trying scheme 0...
  [+] Symbolic execution output:
  Eval failure: (str.++ ("(",
                 (str.substr dp0 13 (int.add (int.sub (str.length dp0) 13) 1)),
                 ")"))
  [+] Symbolic execution stats: clock: 30.532081s | solver: 30.069749s
  [+] ⚠ Detected 1 issue(s)!
  [+] 📄 Trying model :
   (model
    (dp0 str "_$$ND_FUNC$$_;console.log('success')//")
    (originObj str ""))
  [+] 📄 Node exited with 1
  [-] ✖ Status: No side effect
  [+] 📄 Trying model :
   (model
    (dp0 str "_$$ND_FUNC$$_function(){console.log('success')})()")
    (originObj str ""))
  [+] 📄 Node exited with 1
  [-] ✖ Status: No side effect
  [+] 📄 Trying model :
   (model
    (dp0 str "_$$ND_FUNC$$_{__proto__:(function(){console.log('success')})()}")
    (originObj str ""))
  [+] 📄 Node exited with 0
  [+] ✔ Status: Success ("success" in stdout)
  [+] Testing prototype-pollution vulnerability ...
  [+] Trying scheme 0...
  [+] Symbolic execution output:
  Abort: "Uncaught Error: I pollute."
  [+] Symbolic execution stats: clock: 0.659031s | solver: 0.072294s
  [+] ⚠ Detected 1 issue(s)!
  [+] 📄 Trying model :
   (model
    (path0 str "")
    (x0 str "toString")
    (x1 str "__proto__"))
  [+] 📄 Node exited with 1
  [+] ✔ Status: Success (threw Error("I pollute."))
  [+] Testing prototype-pollution vulnerability ...
  [+] Trying scheme 0...
  [+] Symbolic execution output:
  Abort: "Uncaught Error: I pollute."
  [+] Symbolic execution stats: clock: 0.640452s | solver: 0.074274s
  [+] ⚠ Detected 1 issue(s)!
  [+] 📄 Trying model :
   (model
    (path0 str "")
    (x2 str "toString")
    (x3 str "__proto__"))
  [+] 📄 Node exited with 1
  [+] ✔ Status: Success (threw Error("I pollute."))
  [+] Testing prototype-pollution vulnerability ...
  [+] Trying scheme 0...
  [+] Symbolic execution output:
  Abort: "Uncaught Error: I pollute."
  [+] Symbolic execution stats: clock: 0.693751s | solver: 0.114424s
  [+] ⚠ Detected 1 issue(s)!
  [+] 📄 Trying model :
   (model
    (path0 str "")
    (x4 str "toString")
    (x5 str "__proto__")
    (x6 str "toString")
    (x7 str "__proto__"))
  [+] 📄 Node exited with 1
  [+] ✔ Status: Success (threw Error("I pollute."))
  [+] Testing prototype-pollution vulnerability ...
  [+] Trying scheme 0...
  [+] Symbolic execution output:
  [+] Symbolic execution stats: clock: 0.482282s | solver: 0.002567s
  [-] ✔ No issues detected.
  [+] Testing prototype-pollution vulnerability ...
  [+] Trying scheme 0...
  [+] Symbolic execution output:
  [+] Symbolic execution stats: clock: 0.483524s | solver: 0.001569s
  [-] ✔ No issues detected.
  [+] Testing prototype-pollution vulnerability ...
  [+] Trying scheme 0...
  [+] Symbolic execution output:
  [+] Symbolic execution stats: clock: 0.481354s | solver: 0.001716s
  [-] ✔ No issues detected.
