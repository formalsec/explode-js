Test prototype-pollution:
  $ cd ../../packages/proto-02; explode-js run --deterministic taint_summary.json
  [+] Found 1 potential vulnerability
  [+] Testing prototype-pollution vulnerability ...
  [+] Trying scheme 0...
  [+] Symbolic execution output:
  /workspace_root/test/packages/proto-02/_results/vuln_0/symbolic_test_0.js:10:35-10:61
  > throw Error("I pollute.");
  
  Uncaught Error: I pollute.
  Abort: "Uncaught Error: I pollute."
  [+] ⚠ Detected 1 issue(s)!
  [+] 📄 Trying model :
   (model
    (path str "__proto__.toString")
    (symbol_15 str "__proto__")
    (symbol_16 str "toString")
    (val str "polluted"))
  [+] 📄 Node exited with 1
  [+] ✔ Status: Success (threw Error("I pollute."))
