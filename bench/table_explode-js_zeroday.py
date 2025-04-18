import os
import re
import json

index_file = "./datasets/index-zeroday.json"
output_dir = "./datasets/zeroday-output"

def read_json(input_file):
    with open(input_file, "r") as fd:
        return json.load(fd)

def parse_cwe(str):
    match str:
        case "path-traversal":
            return "CWE-22"
        case "command-injection":
            return "CWE-78"
        case "code-injection":
            return "CWE-94"
        case "prototype-pollution":
            return "CWE-1321"
    assert(False)

def print_markdown_table(tbl):
    # Determine column widths
    col_widths = {
        "CWE ID": max(len(cwe) for cwe in tbl.keys()),
        "Paths": 5,
        "Exploits": 8
    }

    # Formatting template
    row_format = "| {cwe:<{cwe_w}} | {tp:>{tp_w}} | {e:>{e_w}} |"

    # Print header
    print(row_format.format(
        cwe="CWE ID", tp="Paths", e="Exploits",
        cwe_w=col_widths["CWE ID"], tp_w=col_widths["Paths"],
        e_w=col_widths["Exploits"]
    ))

    # Print separator
    print("|" + "-" * (col_widths["CWE ID"] + 2) + "|" + "-" * (col_widths["Paths"] + 2) + "|" + "-" * (col_widths["Exploits"] + 2) + "|")

    # Print rows
    for cwe, values in tbl.items():
        print(row_format.format(
            cwe=cwe, tp=values['Paths'], e=values['Exploits'],
            cwe_w=col_widths["CWE ID"], tp_w=col_widths["Paths"],
            e_w=col_widths["Exploits"]
        ))


index = read_json(index_file)
pkgs = []
for pkg in index:
    for vuln in pkg["vulns"]:
        pkgs.append(vuln)

tbl = {
    "CWE-22": { "Paths" : 0, "Exploits" : 0 },
    "CWE-78": { "Paths" : 0, "Exploits" : 0 },
    "CWE-94": { "Paths" : 0, "Exploits" : 0 },
    "CWE-1321": { "Paths" : 0, "Exploits" : 0 },
    "Total": { "Paths" : 0, "Exploits" : 0 }
}

for pkg in pkgs:
    report_file = os.path.join(output_dir, str(pkg['id']), "run", "report.json")
    if not os.path.exists(report_file):
        print(f"Timeout for {pkg['id']}")
        continue

    ty = pkg["cwe"]
    report_json = read_json(report_file)
    for vuln in report_json:
        # We just count 1 failure if any is reported
        failures = vuln["failures"]
        num_failures = len(failures)
        base = os.path.dirname(report_file)
        filename = os.path.join(base, vuln["filename"])
        with open(filename, "r") as fd:
            file_data = fd.read()
        match = re.search(r'// Vuln: (.+)', file_data)
        if match:
            ty = parse_cwe(match.group(1))
        if num_failures > 0:
            tbl[ty]["Paths"] += num_failures
            for failure in failures:
                if failure["exploit"]["success"]:
                    tbl[ty]["Exploits"] += 1

tbl["Total"]["Paths"] = tbl["CWE-22"]["Paths"] + tbl["CWE-78"]["Paths"] + tbl["CWE-94"]["Paths"]+ tbl["CWE-1321"]["Paths"]
tbl["Total"]["Exploits"] = tbl["CWE-22"]["Exploits"] + tbl["CWE-78"]["Exploits"] + tbl["CWE-94"]["Exploits"]+ tbl["CWE-1321"]["Exploits"]
print_markdown_table(tbl)
