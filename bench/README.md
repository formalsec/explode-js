<!-- Normal Title -->
<!-- # Automated Exploit Generation for Node.js Packages -->

<!-- Centered Title -->
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
The artifact is available as a persistent DOI at <a style="color:yellow">TODO</a>.

#### A.1.2. Dependencies.
The evaluation of this artifact does not depend on specific hardware.
The software requirements to evaluate this artifact are:
- Linux <a style="color:yellow">(tested with Ubuntu 22.04 LTS and Debian 10/11, kernel 5.15.0, 5.10.0 and 4.19.0)</a>
- Docker <a style="color:yellow">(tested with version 24.0.1 and 25.0.3)</a>

The repository contains a Docker image named <a style="color:yellow">TODO</a>, built in <a style="color:yellow">Ubuntu 22.04 LTS</a>, and alternatively, a Dockerfile that installs the necessary dependencies for the evaluation.

#### A.1.3. Source Code and Benchmarks.
All source code and reference benchmarks are included in the repository.

#### A.1.4. Time.
We estimate that the time needed to run the artifact evaluation is as follows:
- Getting started: <a style="color:yellow">∼30 minutes</a>.
- Run the experiments: <a style="color:yellow">∼24 compute hours and ∼2 human hours (non-sequential)</a>.

#### A.1.5. Artifact Structure.
<a style="color:yellow">The artifact is organized as follows:</a>

```
Explode.js
├── bench/          # Benchmarks to be evaluated
├── example/        # Example programs for Explode.js
├── src/            # Source code of Explode.js
│ ...
├── Dockerfile
└── README.md
```

<br>

## A.2. Explode.js

Explode.js’s leverages a novel exploit generation algorithm comprising two phases: static analysis and symbolic execution (SE).
In the first phase, Explode.js computes an exploit template consisting of a chain of calls to the functions of the package with symbolic arguments.
In this stage, Explode.js determines which functions need to be called to reach the targeted sensitive sink, the order in which they should be called, and the structure of their corresponding arguments.
This information is organized in an intermediate representation called vulnerable interaction scheme (VIS), from which the tool subsequently creates the exploit template. 
<a style="color:yellow">This phase has N outputs:
1) output-1
2) output-N
</a>

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
<a style="color:red">If you opt to use the pre-built image, it should take at most 10 minutes, otherwise, it should only take a few seconds.</a> <!-- Isto devia de ser ao contrário right? -->
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

All of the scripts in this guide execute Docker commands and should be run in the <a style="color:yellow">`scripts`</a> folder of your machine.

<br>

## A.4. Basic Testing of Explode.js

To test that the artifact is running as expected, run the following script, which runs Explode.js for the `examples/exec.js` file with a simple code injection vulnerability:

<a style="color:yellow">TODO</a>

<br>

## A.5 Basic Testing of FAST

<a style="color:yellow">TODO</a>

<br>

## A.6 Basic Testing of NodeMedic-Fine

<a style="color:yellow">TODO</a>

<br>

## A.7 Basic Testing of the Artifact Experiments


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

<a style="color:yellow">TODO</a>

<br>

## B.3. Effectiveness in Exploit Generation

<a style="color:yellow">TODO</a>

<br>

## B.4. Exploit Generation in the Wild

<a style="color:yellow">TODO</a>

<br>

## B.5. Performance Evaluation

<a style="color:yellow">TODO</a>

<br>

## B.6 Necessity of Explode.js Components

<a style="color:yellow">TODO</a>





<!-- In an effort to organize and visualise benchmark runs a [google sheet](https://docs.google.com/spreadsheets/d/1T_-RcOprzrC_945zFUhkIDcJkiOc9PzzzsGpG7nCnEQ/edit?gid=0#gid=0) was created to summarise results. -->
