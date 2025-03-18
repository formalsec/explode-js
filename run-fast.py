from tabulate import tabulate
from pathlib import Path
import subprocess as sp
import pandas as pd
import argparse
import shutil
import time
import json
import sys
import re
import os

from os.path import join as join_path

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))

OUTPUTS = ["run_log.log", "evaluation.ndjson",
            "opg_nodes.tsv", "opg_rels.tsv",
              "cf_paths.ndjson", "vul_func_names.csv", "solver_stats.json"]

TYPES = ["os_command", "code_exec",
          "path_traversal", "pp"]

CWE_MAPPING = {
    'CWE-22': 'path_traversal',
    'CWE-78': 'os_command',
    'CWE-94': 'code_exec',
    'CWE-1321': 'pp',
    'CWE-471': 'pp',
}

TIMEOUT = 'TIMEOUT'


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

def run_package(datasets, exploit, outputs):
    ran_filenames = []
    package = exploit['package']
    version = exploit['version']
    vulns = exploit['vulns']
    
    for v in vulns:
        exploit_id = str(v['id'])
        cwe = v['cwe']
        cwe = 'CWE-1321' if cwe == 'CWE-471' else cwe
        filename = v['filename']
        
        if filename not in ran_filenames:
            ran_filenames.append(filename)
            file = join_path(datasets, filename)
            run_exploit(package, version, exploit_id, cwe, file, outputs)
        else:
            continue

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

def run_exploit(package, version, exploit_id, cwe, file, outputs):
    
    t = CWE_MAPPING[cwe]
    cmd = ['python3', '-m', 'simurun', '-t', t, '-X', file]
    try:
        elapsed, code, stdout = timed_run(cmd, 600)
    except sp.TimeoutExpired:
        elapsed = TIMEOUT
        code = None
        stdout = "TIMEOUT"

    out = join_path(outputs, f'{exploit_id}_fast')

    if os.path.isdir(out):
        shutil.rmtree(out)
  
    os.makedirs(out)

    stats_file = join_path(out, 'stats.json')
    stdout_file = join_path(out, 'fast-stdout.log')

    move_output_files(out)
    stats = {
        'package': package,
        'version': version,
        'filename': file,
        'cwe': cwe,
        'time': elapsed,
        'exitcode': code
    }

    dump_file(stdout_file, stdout)
    dump_json(stats_file, stats)

def move_output_files(dest):
    pwd = os.getcwd()
    for f in OUTPUTS:
        out = join_path(pwd, f)
        if os.path.exists(out):
            shutil.move(out, dest)

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
        run_package(datasets, exploit, outputs)


# PARSE -----------------------------------------------------------------------------
    
class Series:
    def __init__(self):
        self.package = []
        self.version = []
        self.benchmark = []
        self.cwe = []
        self.marker = []
        self.path_time = []
        self.expl_time = []
        self.total_time = []
        self.detection = []
        self.exploit = []

def parse_solv_time(file_path):
    with open(file_path, "r") as f:
        contents = f.read()
    match = re.search(r'"pass":\s+"3",\s+"time":\s+([0-9.]+)', contents)
    return float(match.group(1)) if match else None

def parse_answer(file_path):
    with open(file_path, "r") as f:
        contents = f.read()
    detection_match = re.search(r"Detection:\s+(\w+)", contents)
    exploit_match = re.search(r"Exploit:\s+(\w+)", contents)
    detection = detection_match.group(1) if detection_match else "failed"
    exploit = exploit_match.group(1) if exploit_match else "failed"
    return detection, exploit

def parse_results(series:Series, dir_path):
    results_dir = str(dir_path)
    if not os.path.isdir(results_dir):
        return

    stats_file = join_path(results_dir, 'stats.json')
    stats = load_json(stats_file)
    package = stats['package']
    version = stats['version']
    total_time = stats['time']
    filename = stats['filename']
    cwe = stats['cwe']
    
    if total_time == TIMEOUT:
        marker = 'Timeout'
    else:
        code = stats['exitcode']
        marker = f'Exited {code}' 

    if marker == "Timeout":
        series.package.append(package)
        series.version.append(version)
        series.benchmark.append(filename)
        series.cwe.append(cwe)
        series.marker.append(marker)
        series.path_time.append(float('nan'))
        series.expl_time.append(float('nan'))
        series.total_time.append(600.0)
        series.detection.append("failed")
        series.exploit.append("failed")
        return

    
    eval_file = list(Path(dir_path).rglob("evaluation.ndjson"))[0]
    log_file = list(Path(dir_path).rglob("fast-stdout.log"))[0]
    solv_time = parse_solv_time(eval_file) if eval_file else None

    detection, exploit = parse_answer(log_file) if log_file else ("failed", "failed")

    expl_time = solv_time if solv_time else 0.0
    path_time = total_time - expl_time

    series.package.append(package)
    series.version.append(version)
    series.benchmark.append(filename)
    series.cwe.append(cwe)
    series.marker.append(marker)
    series.path_time.append(path_time)
    series.expl_time.append(expl_time)
    series.total_time.append(total_time)
    series.detection.append(detection)
    series.exploit.append(exploit)

def parse(outputs):

    series = Series()
    results = list(Path(outputs).rglob("*_fast"))
    for result in results:
        parse_results(series, result)
    
    data = {
        "package": series.package,
        "version": series.version,
        "benchmark": series.benchmark,
        "cwe": series.cwe,
        "marker": series.marker,
        "path_time": series.path_time,
        "expl_time": series.expl_time,
        "total_time": series.total_time,
        "detection": series.detection,
        "exploit": series.exploit
    }
    
    pd.DataFrame(data).to_csv("fast-parsed-results.csv", index=False)
    del data['benchmark']
    table_pipes = tabulate(pd.DataFrame(data), headers="keys", tablefmt="pipe", showindex=False)
    print('\n' + table_pipes)


def main():
    parser = argparse.ArgumentParser(description='Run fast benchmarks')
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
    
    parse(outputs)

if __name__ == '__main__':
    main()
