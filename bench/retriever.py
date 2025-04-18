import os
import sys
import glob
import json

def read_json(file):
    with open(file, "r") as fd:
        return json.load(fd)

package = sys.argv[1]

index = read_json("./datasets/index.json")

zeroday_index = read_json("./datasets/index-zeroday.json")

def search_index(index):
    results = []
    for pkg in index:
        pkg_name = pkg["package"]
        if pkg_name.startswith(package):
            results.append(pkg["vulns"][0]["id"])
    return results

groundtruth = search_index(index)

def search_dir(start_dir, ids):
    for id in ids:
        report_path = os.path.join(start_dir, str(id), "run/report.json")
        if not os.path.exists(report_path):
            continue
        report = read_json(report_path)
        for sym_test in report:
            found = False
            i = 0
            for failure in sym_test["failures"]:
                i += 1
                if failure["exploit"]["success"]:
                    found = True
                    break

            if found:
                prefix = os.path.dirname(report_path)
                prefix = os.path.join(prefix, os.path.splitext(sym_test["filename"])[0])
                glob_pattern = os.path.join(prefix, f"literal_{i}.js")
                for file in glob.glob(glob_pattern):
                    print(file)

if groundtruth == []:
    zeroday = search_index(zeroday_index)
    if zeroday_index == []:
        print(f"Could not find package: {package}", file=sys.stderr)
        sys.exit(1)
    search_dir("datasets/zeroday-output", zeroday)
else:
    search_dir("datasets/CWE-22", groundtruth)
    search_dir("datasets/CWE-78", groundtruth)
    search_dir("datasets/CWE-94", groundtruth)
    search_dir("datasets/CWE-1321", groundtruth)
