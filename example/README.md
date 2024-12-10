# Explode-js example

Considering the example program in the file `exec.js`:

```javascript
let exec = require('child_process').exec;

module.exports = function f(source) {
  if (Array.isArray(source)) {
    return exec(source.join(' '));
  }
  return exec(source);
};
```

Notice that the function `f` receives a `source` parameter and, if it is an
array, it joins its elements with a space and executes the command.
Otherwise, it executes the command directly. Function `f` is vulnerable to
two vulnerabilities of command injection depending on the input.

Explode.js will ask graph.js if it is able to identify the vulnerabilities
in the function `f`. Graph.js, will output the following taint summary:

```sh
$ graphjs --with-types -f exec.js -o explode-out
...
$ cat explode-out/taint_summary.json
[
    {
        "type": "VFunExported",
        "filename": ...
        "vuln_type": "command-injection",
        "sink": "return exec(source.join(' '));",
        "sink_lineno": 5,
        "source": "module.exports",
        "tainted_params": [
            "source"
        ],
        "params_types": {
            "source": {
                "_union": [
                    "array",
                    "string"
                ]
            }
        },
        "call_paths": [
            {
                "type": "Call",
                "fn_name": "119.f-o24",
                "fn_id": "82",
                "source_fn_id": "82"
            }
        ]
    },
    {
        "type": "VFunExported",
        "filename": ...
        "vuln_type": "command-injection",
        "sink": "return exec(source);",
        "sink_lineno": 7,
        "source": "module.exports",
        "tainted_params": [
            "source"
        ],
        "params_types": {
            "source": {
                "_union": [
                    "array",
                    "string"
                ]
            }
        },
        "call_paths": [
            {
                "type": "Call",
                "fn_name": "119.f-o24",
                "fn_id": "82",
                "source_fn_id": "82"
            }
        ]
    }
]
```

Importantly, notice that the summary contains two vulnerabilities with the
same source, but with different sinks and parameters. The first vulnerability
is related to the case where the `source` parameter is an array, and the second
vulnerability is related to the case where the `source` parameter is a string.

To confirm the vulnerabilities, Explode.js will execute explode-js like this:

```sh
$ explode-js run --filename exec.js explode-out/taint_summary.json
Genrating explode-out/symbolic_test_0_0.js
Genrating explode-out/symbolic_test_0_1.js
Genrating explode-out/symbolic_test_1_0.js
Genrating explode-out/symbolic_test_1_1.js
       exec : (#source0 : __$Str)
Found 1 problems!
  replaying : explode-out/symbolic_test_0_0.js...
Genrating explode-out/symbolic_test_0_0/literal_0_0.js
    running : explode-out/symbolic_test_0_0/test-suite/witness-0.json
     status : true (created file "success")
       exec : (#source : __$Str)
Found 1 problems!
  replaying : explode-out/symbolic_test_0_1.js...
Genrating explode-out/symbolic_test_0_1/literal_0_1.js
    running : explode-out/symbolic_test_0_1/test-suite/witness-1.json
     status : true (created file "success")
       exec : (#source0 : __$Str)
Found 1 problems!
  replaying : explode-out/symbolic_test_1_0.js...
Genrating explode-out/symbolic_test_1_0/literal_1_0.js
    running : explode-out/symbolic_test_1_0/test-suite/witness-2.json
     status : true (created file "success")
       exec : (#source : __$Str)
Found 1 problems!
  replaying : explode-out/symbolic_test_1_1.js...
Genrating explode-out/symbolic_test_1_1/literal_1_1.js
    running : explode-out/symbolic_test_1_1/test-suite/witness-3.json
     status : true (created file "success")
```

The output show that explode-js first created two symbolic tests, `symbolic_test_0_0.js`
and `symbolic_test_1_0.js`, and then executed explode-js with each of them. The output
shows that both tests found a problem, and subsequently during the replaying phase
where the symbolic tests are executed with the concrete models generated in
`explode-out/symbolic_test_0_0/test-suite/witness-0.js` and `explode-out/symbolic_test_1_0/test-suite/witness-1.js`,
respectively, each being able to create a file named `success`. This confirms that
the vulnerabilities are present in the function `f`.

Below we analyse the directory structure created by explode-js:

```sh
$ tree explode-out
explode-out
├── graph
│   ├── dependency_graph.txt
│   ├── exec.js
│   ├── graph_stats.json
│   ├── graph.svg
│   ├── nodes.csv
│   └── rels.csv
├── run
│   ├── neo4j_import.txt
│   ├── neo4j_start.txt
│   ├── neo4j_stop.txt
│   └── time_stats.txt
├── symbolic_test_0_0
│   ├── literal_0_0.js
│   ├── report.json
│   └── test-suite
│       ├── witness-0.json
│       └── witness-0.smtml
├── symbolic_test_0_0.js
├── symbolic_test_0_1
│   ├── literal_0_1.js
│   ├── report.json
│   └── test-suite
│       ├── witness-1.json
│       └── witness-1.smtml
├── symbolic_test_0_1.js
├── symbolic_test_1_0
│   ├── literal_1_0.js
│   ├── report.json
│   └── test-suite
│       ├── witness-2.json
│       └── witness-2.smtml
├── symbolic_test_1_0.js
├── symbolic_test_1_1
│   ├── literal_1_1.js
│   ├── report.json
│   └── test-suite
│       ├── witness-3.json
│       └── witness-3.smtml
├── symbolic_test_1_1.js
├── taint_summary_detection.json
└── taint_summary.json

11 directories, 32 files
```

The directory `explode-out` contains the symbolic tests and the directories
`symbolic_test_0_0` and `symbolic_test_1_0` contain the result of the respective
symbolic test.

The `explode-out/symbolic_test_0_0/report.json` contains the symbolic
execution summary of the first symbolic test:

```sh
$ cat explode-out/symbolic_test_0_0/report.json
{
  "filename": "explode-out/symbolic_test_0_0.js",
  "execution_time": 0.00010999999999999899,
  "solver_time": 0.001522999999999719,
  "solver_queries": 1,
  "num_failures": 1,
  "failures": [
    {
      "type": "Exec failure",
      "sink": "(#source0 : __$Str)",
      "pc": "(str.contains source0 \"`touch success`\")",
      "pc_path": "explode-out/symbolic_test_0_0/test-suite/witness-0.smtml",
      "model": {
        "data": {
          "model": { "source0": { "ty": "str", "value": "`touch success`" } }
        },
        "path": "explode-out/symbolic_test_0_0/test-suite/witness-0.json"
      },
      "exploit": { "success": true, "effect": "(created file \"success\")" }
    }
  ]
}
```

Observe that the symbolic execution summary shows that the symbolic test
`symbolic_test_0_0.js` found a failure related to the sink "Exec" and that
the symbolic expression `(#source0 : __$Str)` was responsible for triggering
the failure.

Furthermore, the report contains the information related to the confirmation
of the respective failure in the `"exploit"` field.
The `"model"` field shows the model generated by symbolic execution. Here, it is
located at `explode-out/symbolic_test_0_0/test-suite/witness-0.js`.
Inspecting the contents of the file:

```sh
$ cat explode-out/symbolic_test_0_0/test-suite/witness-0.json
{ "model": { "source0": { "ty": "str", "value": "`touch success`" } } }
```

It shows that the a symbolic model with the assignment to the `#source0`,
which is the a concrete assignment that triggers the vulnerability in the
function `f`.

For reference, the `explode-out/symbolic_test_0_0.js` looks like this:

```sh
$ cat explode-out/symbolic_test_0_0.js
let exec = require('child_process').exec;

module.exports = function f(source) {
  if (Array.isArray(source)) {
    return exec(source.join(' '));
  }
  return exec(source);
};

var esl_symbolic = require("esl_symbolic");
esl_symbolic.sealProperties(Object.prototype);
// Vuln: command-injection
var source = [ esl_symbolic.string("source0") ];
module.exports(source);
```
