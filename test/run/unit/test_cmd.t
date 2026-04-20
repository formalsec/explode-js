Basic tests:

  $ cd ../../packages/cmd-01/; explode-js run --deterministic taint_summary.json
  [+] Found 1 potential vulnerability
  [+] Testing command-injection vulnerability ...
  [+] Trying scheme 0...
  [+] Symbolic execution output:
  Exec failure: x
  [+] ⚠ Detected 1 issue(s)!
  [+] 📄 Trying model :
   (model
    (x str "`touch success`"))
  [+] 📄 Node exited with 0
  [+] ✔ Status: Success (created file "./success")

Real world command injection
  $ cd ../../packages/cmd-04/; explode-js run --deterministic taint_summary.json
  [+] Found 1 potential vulnerability
  [+] Testing command-injection vulnerability ...
  [+] Trying scheme 0...
  [+] Symbolic execution output:
  Exec failure: (str.++ symbol_14 " " "compile")
  [+] ⚠ Detected 1 issue(s)!
  [+] 📄 Trying model :
   (model
    (options str "")
    (symbol_14 str "`touch success`"))
  [+] 📄 Node exited with 1
  [-] ✖ Status: No side effect
  [+] 📄 Trying model :
   (model
    (options str "")
    (symbol_14 str "''; touch success #"))
  [+] 📄 Node exited with 1
  [-] ✖ Status: No side effect

