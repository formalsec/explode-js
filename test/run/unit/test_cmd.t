Basic tests:

  $ cd ../../packages/cmd-01/; explode-js run --deterministic taint_summary.json
  [+] Found 1 potential vulnerability
  [+] Testing command-injection vulnerability ...
  [+] Trying scheme 0...
  [+] Symbolic execution output:
  /workspace_root/test/packages/cmd-01/_results/vuln_0/symbolic_test_0.js:4:2-4:17
  > return exec(x);
  
  Reached sensitive command-injection sink 'child_process.exec' with symbolic expr:
  x
  Abort: ["/workspace_root/test/packages/cmd-01/_results/vuln_0/symbolic_test_0.js",
          4., "command-injection", "child_process.exec", x]
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
  /workspace_root/test/packages/cmd-04/_results/vuln_0/symbolic_test_0.js:24:4-32:7
  > exec(command, function(error, stdout, stderr) { if (error) {
    if (stdout) { console["log"](stdout); }
    if (stderr) { console["log"](stderr); }
    reject(error);
  } else { resolve(compassOptions["cssDir"]); } });
  
  Reached sensitive command-injection sink 'child_process.exec' with symbolic expr:
  (str.++ symbol_14 " " "compile")
  Abort: ["/workspace_root/test/packages/cmd-04/_results/vuln_0/symbolic_test_0.js",
          24., "command-injection", "child_process.exec",
          (str.++ symbol_14 " " "compile")]
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

