import subprocess as sp
import argparse
import shutil
import timeit
import json
import sys
import os

from os.path import join as join_path

OUTPUTS = ["run_log.log", "evaluation.ndjson", "opg_nodes.tsv", "opg_rels.tsv"]
TYPES = ["os_command", "code_exec", "path_traversal", "pp"]
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


def run_package(datasets, exploit, outputs):
    assert 'vulns' in exploit
    vulns = exploit['vulns']
    for v in vulns:
        assert 'filename' in v
        assert 'id' in v
        filename = v['filename']
        exploit_id = str(v['id'])
        file = join_path(datasets, filename)
        run_exploit(exploit_id, file, outputs)

def run_tool(fast, cmd):
    result = sp.run(cmd, capture_output=True, text=True, cwd=fast) 
    cmd_str = ' '.join(cmd) 
    print(f'Running: {cmd_str}')

    if result.returncode != 0:
        print(f'Command failed: "{cmd_str}"')
        print(result.stderr)

def run_exploit(exploit_id, file, outputs):
    fast = join_path(CURRENT_DIR, 'fast')
    
    for t in TYPES:
        cmd = ['python3', '-m', 'simurun', '-t', t, '-X', file]
        time = timeit.timeit(lambda: run_tool(fast, cmd), number=1)

        out = join_path(outputs, exploit_id, t)
        if os.path.isdir(out):
            shutil.rmtree(out)
        
        os.makedirs(out)
        move_output_files(fast, out)
        time_file = join_path(out, 'time.json')
        dump_json(time_file, {'time': time})

def move_output_files(fast, dest):
    for f in OUTPUTS:
        out = join_path(fast, f)
        shutil.move(out, dest)

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
        run_package(datasets, exploit, outputs)

if __name__ == '__main__':
    main()
