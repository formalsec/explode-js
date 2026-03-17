  $ cd ../../packages/path-01; explode-js run
  [+] Starting static analysis (dir .)
  [+] Found 1 potential vulnerability
  [+] Testing path-traversal vulnerability ...
  [+] Trying scheme 0...
  explode-js: internal error, uncaught exception:
              File "src/generator/exploit_templates.ml", line 264, characters 61-67: Assertion failed
              Raised at Explode_js_gen__Exploit_templates.Symbolic.pp in file "src/generator/exploit_templates.ml", line 264, characters 61-73
              Called from Stdlib__Format.kasprintf.k in file "format.ml", line 1565, characters 4-22
              Called from Explode_js_gen__Exploit_templates.Symbolic.render in file "src/generator/exploit_templates.ml", line 273, characters 17-34
              Called from Dune__exe__Taint_analysis.execute_scheme in file "src/bin/taint_analysis.ml", line 10, characters 6-48
              Called from Dune__exe__Taint_analysis.test_vulnerability.loop in file "src/bin/taint_analysis.ml", line 52, characters 8-63
              Called from Dune__exe__Taint_analysis.test_vulnerability in file "src/bin/taint_analysis.ml", line 71, characters 29-54
              Called from Stdlib__List.mapi in file "list.ml", line 95, characters 15-21
              Called from Dune__exe__Taint_analysis.run_from_file in file "src/bin/taint_analysis.ml", line 90, characters 18-63
              Called from Bos_os_dir.with_current.(fun) in file "src/bos_os_dir.ml", line 123, characters 14-17
              Called from Rresult.R.bind in file "src/rresult.ml" (inlined), line 29, characters 38-41
              Called from Bos_os_dir.with_current.(fun) in file "src/bos_os_dir.ml", lines 122-124, characters 4-40
              Re-raised at Bos_os_dir.with_current.(fun) in file "src/bos_os_dir.ml", line 126, characters 37-46
              Called from Dune__exe__Cmd_run.run_package in file "src/bin/cmd_run.ml", lines 8-15, characters 4-18
              Called from Cmdliner_term.app.(fun) in file "cmdliner_term.ml", line 22, characters 19-24
              Called from Cmdliner_eval.run_parser in file "cmdliner_eval.ml", line 41, characters 7-16
  [125]
