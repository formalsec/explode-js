from tabulate import tabulate
from pathlib import Path
import subprocess as sp
import pandas as pd
import argparse
import shutil
import time
import json
import sys
import os

from os.path import join as join_path

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
TIMEOUT = 'TIMEOUT'
# We set to 300 because it's faster for artifact evaluation
TIMEOUT_LIMIT = 300.0


def load_json(file_path):
    try:
        with open(file_path, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f'Error loading JSON: {e}')
        return None

def dump_json(filename, data):
    try:
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
    except Exception as e:
        print(f"Error writing JSON: {e}")

def dump_file(filename, data):
    with open(filename, "w") as file:
        file.write(data)

# RUN ------------------------------------------------------------------------------

def run_package(exploit, outputs):
    assert 'package' in exploit
    assert 'version' in exploit
    assert 'vulns' in exploit
    package = exploit['package']
    version = exploit['version']
    v = exploit['vulns'][0]
    cwe = v['cwe']
    cwe = 'CWE-1321' if cwe == 'CWE-471' else cwe
    run_package__(package, version, cwe, outputs)

def run_tool(cmd, timeout):
    result = sp.run(cmd, capture_output=True, text=True, timeout=timeout)
    stdout = result.stdout
    stderr = result.stderr
    retcode = result.returncode
    cmd_str = ' '.join(cmd)
    print(f'Running: {cmd_str}')

    if result.returncode != 0:
        print(f'Command failed: "{cmd_str}"')
        print(result.stderr)
        return retcode, stderr

    return retcode, stdout

def timed_run(cmd, timeout):
    start = time.perf_counter()
    code, out = run_tool(cmd, timeout)
    end = time.perf_counter()
    elapsed = end - start
    return elapsed, code, out

def run_package__(package, version, cwe, outputs):
    cwd = os.getcwd()
    out = join_path(cwd, outputs, f'{package}@{version}__nodeMedic')

    if os.path.isdir(out):
        shutil.rmtree(out)

    os.makedirs(out)

    cmd = ['docker', 'run', '-it', '--rm',
            '-v', f'{out}:/nodetaint/analysisArtifacts:rw',
             'nodemedic-fine:latest',
             f'--package={package}',
             f'--version={version}',
             '--mode=full']
    try:
        elapsed, code, stdout = timed_run(cmd, TIMEOUT_LIMIT)
    except sp.TimeoutExpired:
        elapsed = TIMEOUT
        code = None
        stdout = 'TIMEOUT'


    stats_file = join_path(out, 'stats.json')
    stdout_file = join_path(out, 'nodeMedic-stdout.log')

    stats = {
        'package': package,
        'version': version,
        'cwe': cwe,
        'time': elapsed,
        'exitcode': code
    }

    dump_file(stdout_file, stdout)
    dump_json(stats_file, stats)

def benchmark(datasets, outputs, packages, cwes):

    # Check if index.json exists and load
    index = join_path(datasets, 'index.json')
    if not os.path.exists(index):
        sys.exit(f'\'index.json\' not found in {datasets}')

    # Load index
    data = load_json(index)
    if packages:
        data = list(filter(lambda pkg: pkg['package'] in packages, data))

    if cwes:
        data = list(filter(lambda pkg: pkg['vulns'][0]['cwe'] in cwes, data))

    # Make outputs directory
    os.makedirs(outputs, exist_ok=True)

    # Run
    print(f'[*] {len(data)} package(s) selected for benchmarking')
    for exploit in data:
        print(f'[-] Running: {exploit['package']}@{exploit['version']}')
        run_package(exploit, outputs)


# PARSE -----------------------------------------------------------------------------

class Series:
    def __init__(self):
        self.package = []
        self.version = []
        self.benchmark = []
        self.id = []
        self.cwe = []
        self.marker = []
        self.total_time = []
        self.taintpath = []
        self.exploit = []
        self.fuzz_time = []
        self.expl_time = []

def task_time_or_zero(json_obj):
    return json_obj.get("time", 0.0) if json_obj else 0.0

def find_taint(content):
    return "Found the following input that causes a flow" in content
    # return bool(re.search(r".*Found the following input that causes a flow.*", content))

def find_expl(content):
     return "Exploit(s) found for functions:" in content
    # return bool(re.search(r".*Exploit\(s\) found for functions:.*", content))

def __parse_results(results_file, stdout_file):
    with open(results_file, "r") as f:
        json_data = json.load(f)

    results = json_data.get("rows", [])
    if len(results) == 0:
        return 0., 0., False, False
    assert len(results) == 1
    results = results[0]
    task_results = results.get("taskResults", {})

    fuzz_time = task_time_or_zero(task_results.get("runInstrumented"))
    expl_time = sum(
        task_time_or_zero(task_results.get(task))
        for task in ["trivialExploit", "checkExploit", "smt"]
    )

    with open(stdout_file, "r") as f:
        data = f.read()

    has_taintpath = str(find_taint(data)).lower()
    has_exploit = str(find_expl(data)).lower()

    return fuzz_time / 1000.0, expl_time / 1000.0, has_taintpath, has_exploit

def parse_results(dir_path):
    results_dir = str(dir_path)
    if not os.path.isdir(results_dir):
        return None

    stats_file = join_path(results_dir, 'stats.json')
    stats = load_json(stats_file)
    package = stats['package']
    version = stats['version']
    total_time = stats['time']
    cwe = stats['cwe']

    if total_time == TIMEOUT:
        marker = 'Timeout'
    else:
        code = stats['exitcode']
        marker = f'Exited {code}'

    if marker == "Timeout":
        return {
            "package": package,
            "version": version,
            "cwe": cwe,
            "marker": marker,
            "fuzz_time": float('nan'),
            "expl_time": float('nan'),
            "total_time": TIMEOUT_LIMIT,
            "taintpath": False,
            "exploit": False
        }

    log_file = list(Path(dir_path).rglob("nodeMedic-stdout.log"))[0]
    results_file = list(Path(dir_path).rglob("results.json"))[0]
    fuzz_time, expl_time, has_taintpath, has_exploit = __parse_results(results_file, log_file)

    return {
        "package": package,
        "version": version,
        "cwe": cwe,
        "marker": marker,
        "fuzz_time": fuzz_time,
        "expl_time": expl_time,
        "total_time": total_time,
        "taintpath": has_taintpath,
        "exploit": has_exploit
    }

def get_ids(data, package, version):
    ids = []
    for pkg in data:
        if pkg["package"] == package and pkg["version"] == version:
            for vuln in pkg["vulns"]:
                ids.append(vuln["id"])
    return ids

def parse(datasets, outputs):

    series = Series()
    results = []
    outputs = list(Path(outputs).rglob("*__nodeMedic"))
    for output in outputs:
        result = parse_results(output)
        if result is not None:
            results.append(result)

    index_file = os.path.join(datasets, "index.json")
    data = load_json(index_file)
    for result in results:
        package = result["package"]
        version = result["version"]
        ids = get_ids(data, package, version)
        # Like FAST we can only count 1 vulnerability per id
        for id in ids:
            series.package.append(package)
            series.version.append(version)
            series.id.append(id)
            series.cwe.append(result["cwe"])
            series.marker.append(result["marker"])
            series.total_time.append(result["total_time"])
            series.taintpath.append(result["taintpath"])
            series.exploit.append(result["exploit"])
            series.fuzz_time.append(result["fuzz_time"])
            series.expl_time.append(result["expl_time"])

    data = {
        "package": series.package,
        "version": series.version,
        "id" : series.id,
        "cwe": series.cwe,
        "marker": series.marker,
        "total_time": series.total_time,
        "taintpath": series.taintpath,
        "exploit": series.exploit,
        "fuzz_time": series.fuzz_time,
        "expl_time": series.expl_time
    }

    pd.DataFrame(data).to_csv("nodeMedic-parsed-results.csv", index=False)
    table_pipes = tabulate(pd.DataFrame(data), headers="keys", tablefmt="pipe", showindex=False)
    print('\n' + table_pipes)


def main():
    parser = argparse.ArgumentParser(description='Run nodeMedic benchmarks')
    parser.add_argument('datasets', help='Path to the datasets')
    parser.add_argument('outputs', help='Path to save outputs')
    parser.add_argument('--packages', nargs="+", help="Package names for filtering")
    parser.add_argument('--cwes', nargs="+", help="CWES for filtering")
    parser.add_argument('-parse-only', action="store_true", help="Only parse data without benchmarking")
    args = parser.parse_args()

    datasets = args.datasets
    outputs = args.outputs
    packages = args.packages
    cwes = args.cwes
    parse_only = args.parse_only

    if not parse_only:
        benchmark(datasets, outputs, packages, cwes)

    parse(datasets, outputs)

if __name__ == '__main__':
    main()
