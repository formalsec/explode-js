  $ cd ../../packages/cmd-02; explode-js run
  [+] Starting static analysis (dir .)
  [+] Found 1 potential vulnerability
  [+] Testing command-injection vulnerability ...
  [+] Trying scheme 0...
  [+] Symbolic execution output:
  "Uncaught TypeError"
  "Uncaught TypeError"
  "File too big"
  Exec failure: (str.++ ("rsync -av /tmp/0 ", id, "@", host, ":", dstDir))
  [+] Symbolic execution stats: clock: 30.771015s | solver: 30.137604s
  [+] ⚠ Detected 1 issue(s)!
  [+] 📄 Trying model :
   (model
    (data str "B")
    (dstDir str "UVWXYZ[\\]")
    (host str "`touch success`")
    (id str "")
    (useTempFiles str "A")
    (x0 real -0.5))
  [+] 📄 Node exited with 1
  [-] ✖ Status: No side effect
