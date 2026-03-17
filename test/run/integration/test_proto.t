  $ cd ../../packages/proto-01; explode-js run
  [+] Starting static analysis (dir .)
  [+] Found 1 potential vulnerability
  [+] Testing prototype-pollution vulnerability ...
  [+] Trying scheme 0...
  [+] Symbolic execution output:
  [+] Symbolic execution stats: clock: 0.754384s | solver: 0.049135s
  [-] ✔ No issues detected.
  [+] Trying scheme 1...
  [+] Symbolic execution output:
  "Uncaught TypeError"
  "Uncaught TypeError"
  "Uncaught TypeError"
  "Uncaught TypeError"
  "Uncaught TypeError"
  "Uncaught TypeError"
  "Uncaught TypeError"
  "Uncaught TypeError"
  Abort: "Uncaught Error: I pollute."
  [+] Symbolic execution stats: clock: 5.544913s | solver: 1.519314s
  [+] ⚠ Detected 1 issue(s)!
  [+] 📄 Trying model :
   (model
    (path str "__proto__.toString")
    (value str "polluted")
    (x0 str "__proto__")
    (x1 str "toString"))
  [+] 📄 Node exited with 1
  [+] ✔ Status: Success (threw Error("I pollute."))
