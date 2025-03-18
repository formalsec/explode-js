<h1 align="center", style="font-size: 32px">Automated Exploit Generation for Node.js Packages</h1>

This artifact evaluates Explode.js, a novel tool for synthesizing exploits for Node.js applications.
By combining static analysis and symbolic execution, Explode.js generates functional exploits that confirm the existence of command injection, code injection, prototype pollution, and path traversal vulnerabilities.
The repository includes all source code, reference datasets and instructions on how to build and run the experiments.
These experiments result in the tables and plots presented in the paper, which can be used to validate the results.

<br>

# A. Getting Started

This section contains an introduction to the Explode.js tool, requirements, and setup and basic testing instructions to run the artifact.

## A.1. Description & Requirements

**How to access.**
The artifact is available as a persistent DOI at 10.5281/zenodo.15009157.

**Dependencies.**
The evaluation of this artifact does not depend on specific hardware.
However for the evaluation is recommended following software and hardware specs.
- Linux (tested with Ubuntu Ubuntu 24.04.2 LTS and Debian 10/11)
- Docker (tested with version 28.0.1)
- 32GiB RAM
- Stable internet connection (Explode-js requires npm install to validate exploits)

**Source Code and Benchmarks.**
All source code and reference benchmarks are included in the repository and respective docker images.

**Time.**
We estimate that the time needed to run the artifact evaluation is as follows:
- Getting started: 30 minutes.
- Run the experiments: XX compute hours.

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
├── src                         # Source code of Explode.js
├── test                        # Unit tests of Explode.js
├── vendor                      # External dependencies of Explode.js
│ ...
├── Dockerfile
└── README.md
```

There are three Docker containers, `[FIXME]`, `[FIXME]`, and `[FIXME]`, one for each of the tools under evaluation: Explode.js, FAST, and NodeMedic-Fine, respectively.
The experiments for each tool must be executed within its designated Docker container.

<br>

## A.2. Getting Started with Explode.js

**Setup.** 
To setup the environment, load the Explode.js Docker image `[FIXME]`, with the following command:

```sh
[FIXME]
```

**Basic Testing.**
To verify that the image is properly loaded and that the tool is running as expected, run Explode.js for the [TODO] example using the following command:

```sh
[FIXME]
```

**Output.** The output of the previous command should be:

```
[FIXME]
```

The generated exploit can be found in the file `[FIXME]`.

<br>

## A.3. Getting Started with FAST

**Setup.** 
To setup the environment, load the FAST Docker image `[FIXME]`, with the following command:

```sh
[FIXME]
```

**Basic Testing.**
To verify that the image is properly loaded and that the tool is running as expected, run FAST for the [TODO] example using the following command:

```sh
[FIXME]
```

**Output.** The output of the previous command should be:

```
[FIXME]
```

FAST does not generate exploits. 
Instead, it generates a trace with information regarding the inputs to activate the exploit.
In this case, FAST generates the trace:

```
[FIXME]
```

, from which one can  manually construct the exploit:

```
[FIXME]
```

<br>

## A.4. Getting Started with NodeMedic-Fine

**Setup.** 
To setup the environment, load the NodeMedic-Fine Docker image `[FIXME]`, with the following command:

```sh
[FIXME]
```

**Basic Testing.**
To verify that the image is properly loaded and that the tool is running as expected, run NodeMedic-Fine for the [TODO] example using the following command:

```sh
[FIXME]
```

**Output.** The output of the previous command should be:

```
[FIXME]
```

The generated exploit can be found in the file `[FIXME]`.



<br>



# B. Step-By-Step Instructions


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

<br>

## B.1. Claims 1 and 3

The goal of this section is to confirm the results presented in Sections 6.1 and 6.2 of the paper;
specifically those of Tables 3 and 6, which we reproduce below:

**Table 3. [Effectiveness]**

`[TODO]`

**Table 6. [Performance]**

`[TODO]`

To reproduce the results of the tables above, one must first run Explode.js, FAST, and NodeMedic-Fine in the Vulcan and SecBench.js datasets.
We have to do this separately for each tool.

### B.1.1. Explode.js

Run the following command in the folder `[FIXME]`:

```sh
[FIXME]
```

This will take approximately `[FIXME]` hours. 
To determine if the execution was successful, check if `[FIXME]`.

The generated exploits are stored `[FIXME]`.
To check the exploit generated for a specific package, say the `[FIXME]` package, see file `[FIXME]`. 

To generate the Explode.js results of Table 3, run in the folder `[FIXME]`:

```sh
[FIXME]
```

To generate the Explode.js results of Table 6, run in the folder `[FIXME]`:

```sh
[FIXME]
```

### B.1.2. FAST

Run the following command in the folder `[FIXME]`:

```sh
[FIXME]
```

This will take approximately `[FIXME]` hours. 
To determine if the execution was successful, check if `[FIXME]`

As stated before, FAST does not generate executable exploits; those have to be manually put together from the output trace information.
We have done that for all the generated traces in the dataset, which can be consulted in the folder `[FIXME]`.
To check the exploit generated for a specific package, say the `[FIXME]` package, see file `[FIXME]`. 

To generate the FAST results of Table 3, run in the folder `[FIXME]`:

```sh
[FIXME]
```

To generate the FAST results of Table 6, run in the folder `[FIXME]`:

```sh
[FIXME]
```

### B.1.3. NodeMedic-Fine

Run the following command in the folder `[FIXME]`:

```sh
[FIXME]
```

This will take approximately `[FIXME]` hours. 
To determine if the execution was successful, check if `[FIXME]`.

The generated exploits are stored `[FIXME]`.
To check the exploit generated for a specific package, say the `[FIXME]` package, see file `[FIXME]`. 

To generate the NodeMedic-Fine results of Table 3, run in the folder `[FIXME]`:

```sh
[FIXME]
```

To generate the NodeMedic-Fine results of Table 6, run in the folder `[FIXME]`:

```sh
[FIXME]
```

### B.1.4. Speed-up the Analysis

For the sake of time, instead of confirming the results for the entire dataset, the reviewers can confirm the results for just one specific type of vulnerability.
To this end, we it suffices to provide a flag indicating that vulnerability to the analysis script.
For instance, if we wanted to confirm the results of Explode.js for just code-injection run the command:

```sh
[FIXME]
```

The flags for the other types of vulnerabilities are: `command-injection`, `prototype-pollution`, and `path-traversal`. 

<br>

## Claim 2

The goal of this section is to confirm the results presented in Section 6.2 of the paper;
specifically those of Table 5, which we reproduce below:

**Table 5. [Explode.js in the Wild]**

`[TODO]`

To reproduce the results of the table above, we provide the set of packages for which Explode.js found 
new vulnerabilities in `[FIXME]` and a script to run Explode.js on these packages.
To run Explode.js on the wild packages in which new vulnerabilities were found, run:

```sh
[FIXME]
```

The scripts output a version of the table above and the generated exploits can be found in the `FIXME` folder.
To check the exploit generated for a specific package, say the `[FIXME]` package, see file `[FIXME]`. 

To generate Table 5, run in the folder `[FIXME]`:

```sh
[FIXME]
```

<br>

## Claim 4

The goal of this section is to confirm the results presented in Section 6.4 of the paper;
specifically those of Table 7, which we reproduce below:

**Table 7. [Explode.js Components]**

`[TODO]`

To reproduce the results of the table above, one must first run Explode.js without VISes and Lazy Values.
Importantly, you must have previously run Explode.js with lazy values and VISes as instructed in section B.1. 

To execute Explode.js without VISes run in the folder `[FIXME]`:

```sh
[FIXME]
```

This will take approximately `[FIXME]` hours. 
To determine if the execution was successful, check if `[FIXME]`.

To execute Explode.js without Lazy Values, run in the folder `[FIXME]`:

```sh
[FIXME]
```

This will take approximately `[FIXME]` hours. 
To determine if the execution was successful, check if `[FIXME]`.

To generate Table 7, run in the folder `[FIXME]`:

```sh
[FIXME]
```
