import subprocess as sp
import argparse
import shutil
import timeit
import json
import sys
import os

from os.path import join as join_path

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))

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


def run_package(exploit, outputs):
    assert 'package' in exploit
    assert 'version' in exploit
    assert 'vulns' in exploit
    package = exploit['package']
    version = exploit['version']
    vulns = exploit['vulns']
    ids = [str(v['id']) for v in vulns]
    run_package__(ids, package, version, outputs)

def run_tool(cmd):
    print(f'Running: {cmd_str}')
    result = sp.run(cmd, capture_output=True, text=True) 
    cmd_str = ' '.join(cmd) 

    if result.returncode != 0:
        print(f'Command failed: "{cmd_str}"')
        print(result.stderr)


def run_package__(ids, package, version, outputs):
    cwd = os.getcwd()
    out = join_path(cwd, outputs, f'{package}@{version}')
    
    if os.path.isdir(out):
        shutil.rmtree(out)
    os.makedirs(out)
        
    cmd = ['docker', 'run', '-it', '--rm',
            '-v', f'{out}:/nodetaint/analysisArtifacts:rw',
             'nodemedic-fine:latest',
             f'--package={package}',
             f'--version={version}',
             '--mode=full']
    
    time = timeit.timeit(lambda: run_tool(cmd), number=1)

    time_file = join_path(out, 'time.json')
    dump_json(time_file, {'time': time, 'ids': ids})


def main():
    parser = argparse.ArgumentParser(description='Run fast benchmarks')
    parser.add_argument('datasets', help='Path to the datasets')
    parser.add_argument('outputs', help='Path to save outputs')
    parser.add_argument("--packages", nargs="+", help="Package names for filtering")

    args = parser.parse_args()
    datasets = args.datasets
    outputs = args.outputs
    packages = args.packages

    # Check if index.json exists and load
    index = join_path(datasets, 'index.json')
    if not os.path.exists(index):
        sys.exit(f'\'index.json\' not found in {datasets}')

    # Load index    
    data = load_json(index)
    if packages:
        data = list(filter(lambda pkg: pkg['package'] in packages, data))
    
    # Make outputs directory
    os.makedirs(outputs, exist_ok=True)    

    # Run 
    for exploit in data:
        run_package(exploit, outputs)

if __name__ == '__main__':
    main()
