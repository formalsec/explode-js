Test prototype-pollution:
  $ cd ../../packages/proto-02; explode-js run --deterministic taint_summary.json | sed '/^\//d'
  [+] Found 1 potential vulnerability
  [+] Testing prototype-pollution vulnerability ...
  [+] Trying scheme 0...
  [+] Symbolic execution output:
  > obj[attr] = val;
  
  Uncaught TypeError: 'caller', 'callee', and 'arguments' properties may not be accessed on strict mode functions or the arguments objects for calls to them
  > obj[attr] = val;
  
  Uncaught TypeError: 'caller', 'callee', and 'arguments' properties may not be accessed on strict mode functions or the arguments objects for calls to them
  > obj[attr] = val;
  
  Uncaught TypeError: 'caller', 'callee', and 'arguments' properties may not be accessed on strict mode functions or the arguments objects for calls to them
  > obj[attr] = val;
  
  Uncaught TypeError: 'caller', 'callee', and 'arguments' properties may not be accessed on strict mode functions or the arguments objects for calls to them
  > throw Error("I pollute.");
  
  Uncaught Error: I pollute.
  Abort: "Uncaught Error: I pollute."
  [+] ⚠ Detected 1 issue(s)!
  [+] 📄 Trying model :
   (model
    (path str "__proto__.toString")
    (symbol_10 str "toString")
    (symbol_9 str "__proto__")
    (val str "polluted"))
  [+] 📄 Node exited with 1
  [+] ✔ Status: Success (threw Error("I pollute."))
