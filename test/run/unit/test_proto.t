Test prototype-pollution:
  $ cd ../../packages/proto-02; explode-js run --deterministic taint_summary.json
  [+] Found 1 potential vulnerability
  [+] Testing prototype-pollution vulnerability ...
  [+] Trying scheme 0...
  [+] Symbolic execution output:
  Abort: "Uncaught Error: I pollute."
  [+] ⚠ Detected 1 issue(s)!
  [+] 📄 Trying model :
   (model
    (path str "__proto__.toString")
    (symbol_17 str "__proto__")
    (symbol_18 str "toString")
    (val str "polluted"))
  [+] 📄 Node exited with 1
  [+] ✔ Status: Success (threw Error("I pollute."))
