<h1 align="center", style="font-size: 32px">Automated Exploit Generation for Node.js Packages</h1>

This artifact evaluates Explode.js, a novel tool for synthesizing exploits for Node.js applications. 
By combining static analysis and symbolic execution, Explode.js generates functional exploits that confirm the existence of command injection, code injection, prototype pollution, and path traversal vulnerabilities.
The repository includes all source code, reference datasets and instructions on how to build and run the experiments.
These experiments result in the tables and plots presented in the paper, which can be used to validate the results.

<br>

# A. Getting Started

This section contains an introduction to the Explode.js tool, requirements, and setup and basic testing instructions to run the artifact.

## A.1. Description & Requirements

#### A.1.1. How to access.
The artifact is available as a persistent DOI at ~~TODO~~.

#### A.1.2. Dependencies.
The evaluation of this artifact does not depend on specific hardware.
The software requirements to evaluate this artifact are:
- Linux ~~(tested with Ubuntu 22.04 LTS and Debian 10/11, kernel 5.15.0, 5.10.0 and 4.19.0)~~
- Docker ~~(tested with version 24.0.1 and 25.0.3)~~

The repository contains a Docker image named ~~TODO~~, built in ~~Ubuntu 22.04 LTS~~, and alternatively, a Dockerfile that installs the necessary dependencies for the evaluation.

#### A.1.3. Source Code and Benchmarks.
All source code and reference benchmarks are included in the repository.

#### A.1.4. Time.
We estimate that the time needed to run the artifact evaluation is as follows:
- Getting started: ~~∼30 minutes~~.
- Run the experiments: ~~∼24 compute hours and ∼2 human hours (non-sequential)~~.

#### A.1.5. Artifact Structure.
The artifact is organized as follows:

```
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
├── src                         # Source code of Explode.js
├── test                        # Unit tests of Explode.js
├── vendor                      # External dependencies of Explode.js
│ ...
├── Dockerfile
└── README.md
```

<br>

## A.2. Explode.js

Explode.js’s leverages a novel exploit generation algorithm comprising two phases: static analysis and symbolic execution (SE).
First, Explode.js computes an exploit template consisting of a chain of calls to the functions of the package with symbolic arguments.
In this stage, Explode.js determines which functions need to be called to reach the targeted sensitive sink, the order in which they should be called, and the structure of their corresponding arguments.
This information is organized in an intermediate representation called vulnerable interaction scheme (VIS), from which the tool subsequently creates the exploit template. 

~~TODO (if needed)~~
This phase has N outputs:
1) output-1
2) output-N

In the second phase, Explode.js symbolically executes the exploit template aiming to find a control path to the vulnerable sink.
If such a path is found, the identified path constraints are extended with additional constraints to
ensure that the arguments passed to the sink result in an observable effect.
Then, Explode.js uses an Satisfiability Modulo Theories (SMT) solver to generate concrete inputs that satisfy these constrains.
If such inputs are found, the tool produces a functional exploit by replacing the symbolic variables in the exploit template with the corresponding concrete values.
Currently, Explode.js can synthesize exploits for four types of vulnerabilities: path traversal (CWE-22), OS command injection (CWE-78), arbitrary code execution (CWE-94), and prototype pollution (CWE-1321).

<br>

## A.3. Setup the Environment

To setup the environment, you can opt to use a pre-built Docker image, or to build it using the Dockerfile.
For both cases, ensure that you have the Docker service running in your machine.
~~If you opt to use the pre-built image, it should take at most 10 minutes, otherwise, it should only take a few seconds.~~ <!-- Isto devia de ser ao contrário right? Leva tempo é a construir a imagem. -->
To use the pre-built image, from the repository’s root folder, run:

```
cd ???
./load_image.sh
```

Alternatively, build the required docker image, by executing:

```
cd ???
./build_image.sh
```

All of the scripts in this guide execute Docker commands and should be run in the ~~`scripts`~~ folder of your machine.

<br>

## A.4. Basic Testing of Explode.js

To test that the artifact is running as expected, run the following script, which runs Explode.js for the `examples/exec.js` file with a simple code injection vulnerability:

~~TODO~~
<!-- 
Aqui temos de ver porque o exemplo que o Filipe tem involve primeiro correr o graphjs com
>> graphjs --with-types -f exec.js -o _results/run
e depois correr o explode.js no resultado:
>> explode-js run --filename exec.js _results/run/taint_summary.json

Se calhar é preferível ter um script que corre tudo e depois mostra os resultados?
-->

<br>

## A.5 Basic Testing of FAST

The claims of the paper rely on the comparison with FAST and NodeMedic-Fine, two Node.js state-of-the-art exploit generation tools.
<!-- Adicionar uma frase sobre o FAST se for preciso -->
To test that FAST is running as expected, run the command:

```
TODO: FAST cmd
```

**[Expected Output]** 
If the test was successful, you should see the following output (here truncated for space).
<!-- Adicionar uma frase sobre o resultado do FAST se for preciso -->

```
TODO: FAST output
```

**[Results]** 
Besides the output, FAST should generate the following files in the ~~`directory`~~ directory.
It also generates others, that are not relevant for this artifact. 

```
TODO: NodeMedic results
```

<br>

## A.6 Basic Testing of NodeMedic-Fine

<!-- Adicionar uma frase sobre o NodeMedic-Fine se for preciso -->
To test that FAST is running as expected, run the command:

```
TODO: NodeMedic cmd
```

**[Expected Output]** 
If the test was successful, you should see the following output (here truncated for space).
<!-- Adicionar uma frase sobre o resultado do NodeMedic-Fine se for preciso -->

```
TODO: NodeMedic output
```

**[Results]** 
Besides the output, FAST should generate the following files in the ~~`directory`~~ directory.
It also generates others, that are not relevant for this artifact. 

```
TODO: NodeMedic results
```

<br>

## A.7 Basic Testing of the Artifact Experiments

The artifact reproduces the experiments that support the major claims of the paper.
These experiments run Explode.js, FAST, and NodeMedic-Fine for the benchmark datasets (~~603~~ packages), and generate tables and plots similar to the ones presented in the paper.
To test that the artifact evaluation runs smoothly, this section tests that the artifact is able to run for a small percentage of the packages (~~8~~ packages) and generate the tables.
This should take ~~∼5-10~~ minutes.
We selected a set of small packages that cover all the types of vulnerabilities, and named them Test Dataset. Note that these packages are not representative of the overall expected results.
To run Explode.js, FAST, and NodeMedic-Fine for the test dataset, issue:

```
TODO: Explode.js cmd
TODO: FAST cmd
TODO: NodeMedic-Fine cmd
```

This command should generate ~~3~~ tables in the results folder, located in the root directory of the repository:
- ~~table-1~~: Measures something.
<!-- e1_detection_table.txt: Measures the true positives (TP), false positives (FP) and true false positives (TFP). The expected table is shown in Table 2, at the end of this document. -->
- ~~table-2~~: Measures something else.
<!-- e2_time_table.txt: Measures the time taken to analyze the packages. An example of an expected table is shown in Table 4. Note that this table is simply an example given that the actual numbers differ from machine to machine. -->
- ~~table-3~~: Measures something else else.
<!-- e3_graph_size_table.txt: Measures the size of the graphs generated by Graph.js and ODGen. An example of an expected table is shown in Table 3. -->

It should also generate ~~2~~ plots:
- ~~plot-1~~: Shows something
<!-- e1_venn_diagram.png: Illustrates a Venn diagram of the vulnerabilities detected by Graph.js and ODGen. The expected plot is shown in Figure 1. -->
- ~~plot-2~~: Shows something else
<!-- e2_time_cdf.png: Shows the cumulative distribution function (CDF) of the percentage of packages that each tool managed to analyze. The expected plot is shown in Figure 2. Similarly to e2_time_table.txt, the plot may differ from machine to machine. -->

<br>
<br>
<br>

# B. Step-By-Step Instructions

This section contains instructions to reproduce the experiments that support the claims of the paper. 
These experiments result in the tables and plots presented in the paper, which can be used to validate the results.

## B.1. Major Claims

- **C1:** *(RQ1) Effectiveness in Exploit Generation.*
Explode.js detects 49.1% of existing control paths in the ground truth datasets, outperforming FAST by 2.49× and NodeMedic by 4.34x. It achieves an exploit rate of 28.5% surpassing FAST by 2.49× and NodeMedic by 3.01×.

- **C2:** *(RQ2) Exploit Generation in the Wild.*
Out of 246 packages with vulnerable paths, Explode.js generated 131 exploits, of which 46 enable malicious actions, leading to 44 zero-days, for which 4 CVEs have already been assigned: CVE-2024-43370, CVE-2024-44711, CVE-2024-45390, CVE-2024-46503.

- **C3:** *(RQ3) Performance Evaluation.*
Although Explode.js takes longer to analyze the dataset than FAST and NodeMedic, by the 40-second mark, it finds 1.3× more vulnerability than FAST and 9× more than NodeMedic.

- **C4:** *(RQ4) Necessity of Explode.js Components.*
The core techniques of Explode.js (VISes and lazy values) are key to its effectiveness.

<br>

## B.2. Analyzing the Datasets

As described in Sections A.4, A.5, and A.6, Explode.js, FAST, and NodeMedic-Fine generate a set of metrics for each analyzed package.
For the artifact evaluation, the first step is to run all three tools on the reference datasets: VulcaN and SecBench, which will generate metrics for the analyzed packages.
Then, experiments E1 and E3 process the metrics generated during this analysis, and generate the tables and plots that support the claims of the paper.
Experiments E2 and E4 require running Explode.js on the Collected dataset and reruning Explode.js on the reference datasets while disabling certain mechanisms of the tool, respectively.
Both experiments are fully described in their corresponding sections: B.4 and B.6.
As VulcaN and SecBench contain ~~219~~ and ~~384~~ vulnerabilities, respectively, this analysis is expected to take about ~~∼20 to 23 hours~~ in total compute time.
Table 1 presents the estimated times for each tool and dataset.

| Tool | Estimated Time (Vulcan) | Estimated Time (SecBench) | Estimated Time (Total) |
|:---:|:---:|:---:|:---:|
| Explode.js | | | |
| FAST | | | |
| NodeMedic-Fine | | | |
| **Total** | | | |

You can opt to run both tools for all of the packages in the datasets at once, or to run the tools for each vulnerability type separately, if running the experiments for such an extensive period of time is not feasible.
To run both tools for all of the packages in the datasets at once, run:

```
./run_explodejs_dataset.sh -d vulcan        # Run Explode.js in VulcaN
./run_explodejs_dataset.sh -d secbench      # Run Explode.js in SecBench
./run_fast_dataset.sh -d vulcan             # Run FAST in VulcaN
./run_fast_dataset.sh -d secbench           # Run FAST in SecBench
./run_nodemedic_dataset.sh -d vulcan        # Run NodeMedic-Fine in VulcaN
./run_nodemedic_dataset.sh -d secbench      # Run NodeMedic-Fine in SecBench
```

Alternatively, to run the tools for each vulnerability type separately, run the following commands:

```
Run Explode.js in VulcaN for each vulnerability type
./run_explodejs_dataset.sh -d vulcan -v path-traversal
./run_explodejs_dataset.sh -d vulcan -v command-execution
./run_explodejs_dataset.sh -d vulcan -v code-injection
./run_explodejs_dataset.sh -d vulcan -v prototype-pollution

# Run Explode.js in SecBench for each vulnerability type
./run_explodejs_dataset.sh -d secbench -v path-traversal
./run_explodejs_dataset.sh -d secbench -v command-execution
./run_explodejs_dataset.sh -d secbench -v code-injection
./run_explodejs_dataset.sh -d secbench -v prototype-pollution

# Run FAST in VulcaN for each vulnerability type
./run_fast_dataset.sh -d vulcan -v path-traversal
./run_fast_dataset.sh -d vulcan -v command-execution
./run_fast_dataset.sh -d vulcan -v code-injection
./run_fast_dataset.sh -d vulcan -v prototype-pollution

# Run FAST in SecBench for each vulnerability type
./run_fast_dataset.sh -d secbench -v path-traversal
./run_fast_dataset.sh -d secbench -v command-execution
./run_fast_dataset.sh -d secbench -v code-injection
./run_fast_dataset.sh -d secbench -v prototype-pollution

# Run NodeMedic-Fine in VulcaN for each vulnerability type
./run_nodemedic_dataset.sh -d vulcan -v path-traversal
./run_nodemedic_dataset.sh -d vulcan -v command-execution
./run_nodemedic_dataset.sh -d vulcan -v code-injection
./run_nodemedic_dataset.sh -d vulcan -v prototype-pollution

# Run NodeMedic-Fine in SecBench for each vulnerability type
./run_nodemedic_dataset.sh -d secbench -v path-traversal
./run_nodemedic_dataset.sh -d secbench -v command-execution
./run_nodemedic_dataset.sh -d secbench -v code-injection
./run_nodemedic_dataset.sh -d secbench -v prototype-pollution
```

Similarly to Sections A.4 and A.5, the results for each package will be located in the respective folder of the package. 
For instance, the results for package ~~datasets/vulcan-dataset/CWE-22/374~~ will be located in ~~datasets/vulcan-dataset/CWE-22/374/tool_outputs~~. 

**[Analysis Timeout]** The analysis of each package has a timeout of ~~5 minutes, defined in file `configs/config.ini`~~.
This parameter can affect the results produced, since different machines may experience a different number of timeouts.
Consequently, there can be slight variations in the results, but all claims are expected to verified.

<br>

## B.3. Effectiveness in Exploit Generation

This experiment measures the effectiveness of Explode.js, FAST, and NodeMedic-Fine in detecting and confirming vulnerabilities in the ground truth datasets: VulcaN and SecBench, and verifies claim (C1).

In particular, it measures the true positives (TP), false negatives (FN) and exploits generated (E).
Please refer to the paper for details on these metrics.
Run the experiment by issuing:

```
TODO: E1 cmd
```

<!-- Additional information regarding the command -->
<!-- This command may output some warnings for packages where the detection files do not exist, which happens when the analysis times out. You can ignore these. -->

**[Results]** Similarly to Section A.4, the resulting figure ~~`f1.png`~~ and table ~~`t1.txt`~~ are stored in the results folder.
Figure ~~`f1.png`~~ should resemble Figure 6 of the paper, and Table ~~`t1.txt`~~ should resemble Table 5 of the paper, both with possible slight variations due to the number of timeouts.

<br>

## B.4. Exploit Generation in the Wild

This experiment shows Explode.js's capability of detecting zero-day vulnerabilities by applying it to the Collected dataset comprising 32k Node.js packages taken from the npm repository, and verifies claim (C2).
For the paper, we ran Explode.js for 32K packages, which took several days to complete, even though
we used six servers to distribute the load and speed up the analysis.
Therefore, for the artifact evaluation, we built a scaled-down version of the dataset with the ~~49~~ exploited vulnerabilities claimed to be detected by Explode.js accompanied by the relevant proof of
concepts (POCs).

To run Explode.js for the Collected Dataset, run the following command. This should take about ~~1~~ hour.

```
TODO: E2 cmd
```

To analyze the results and generate a summary table, run:

```
TODO: E2 cmd
```

<!-- Additional information regarding the command -->
<!-- Similarly to E1, this command may output some warnings for packages where the time metric files do not exist. You can ignore. -->

**[Results]** Similarly to Section A.4, the resulting table ~~`t2.txt`~~ is stored in the results folder.
It should resemble the column "0-Day" from Table 5 of the paper, with possible slight variations due to the number of timeouts.

<br>

## B.5. Performance Evaluation

This experiment measures the the scalability of Explode.js by measuring the time taken by Explode.js, FAST, and NodeMedic-Fine to detect vulnerabilities in each npm package from the reference datasets, and verifies claim (C3).
Run the experiment by issuing:

```
TODO: E3 cmd
```

<!-- Additional information regarding the command -->
<!-- Similarly to E1, this command may output some warnings for packages where the time metric files do not exist. You can ignore. -->

**[Results]** Similarly to Section A.4, the resulting figure ~~`e3.png`~~ and table ~~`t3.txt`~~ are stored in the results folder.
Figure ~~`e3.png`~~ should resemble Figure 7 of the paper, and Table ~~`t3.txt`~~ should resemble Table 6 of the paper, both with possible slight variations due to the number of timeouts.

<br>

## B.6 Necessity of Explode.js Components

This experiment assess the effectiveness and necessity of Explode.js’s components in generating exploits by performing two experiments: (1) running Explode.js without using lazy values; and (2) running Explode.js without using VISes.
Run the experiment by issuing:

```
TODO: E4 cmd
```

**[Results]** Similarly to Section A.4, the resulting tables ~~`t41.txt`~~ and ~~`t42.txt`~~ are stored in the results folder.
Table ~~`t41.txt`~~ should resemble the column "No LVes" from Table 7 of the paper, and Table ~~`t42.txt`~~ should resemble the column "No VIS" from Table 7 of the paper, with possible slight variations due to the number of timeouts.




<!-- In an effort to organize and visualise benchmark runs a [google sheet](https://docs.google.com/spreadsheets/d/1T_-RcOprzrC_945zFUhkIDcJkiOc9PzzzsGpG7nCnEQ/edit?gid=0#gid=0) was created to summarise results. -->
