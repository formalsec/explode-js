import os
import csv
import sys
import json

index_file = "./bench/datasets/index.json"

def get_index():
    with open(index_file, "r") as fd:
        return json.load(fd)

def parse_csv(fpath):
    if not os.path.exists(fpath):
        return []
    with open(fpath, newline='') as csvfile:
        return list(csv.reader(csvfile, delimiter="|"))

def print_markdown_table(tbl):
    # Determine column widths
    col_widths = {
        "CWE ID": max(len(cwe) for cwe in tbl.keys()),
        "TP": 3,
        "E": 3,
        "Total": 6
    }

    # Formatting template
    row_format = "| {cwe:<{cwe_w}} | {tp:>{tp_w}} | {e:>{e_w}} | {total:>{total_w}} |"

    # Print header
    print(row_format.format(
        cwe="CWE ID", tp="TP", e="E", total="Total",
        cwe_w=col_widths["CWE ID"], tp_w=col_widths["TP"],
        e_w=col_widths["E"], total_w=col_widths["Total"]
    ))

    # Print separator
    print("|" + "-" * (col_widths["CWE ID"] + 2) + "|" + "-" * (col_widths["TP"] + 2) + "|" + "-" * (col_widths["E"] + 2) + "|" + "-" * (col_widths["Total"] + 2) + "|")

    # Print rows
    for cwe, values in tbl.items():
        print(row_format.format(
            cwe=cwe, tp=values['tp'], e=values['e'], total=values['total'],
            cwe_w=col_widths["CWE ID"], tp_w=col_widths["TP"],
            e_w=col_widths["E"], total_w=col_widths["Total"]
        ))

def main():
    if len(sys.argv) < 2:
        print("ERROR: Please provided a csvfile")
        return 1
    tbl = {
        "CWE-22": { "tp" : 0, "e" : 0, "total" : 166 },
        "CWE-78": { "tp" : 0, "e" : 0, "total" : 169 },
        "CWE-94": { "tp" : 0, "e" : 0, "total" : 54 },
        "CWE-1321": { "tp" : 0, "e" : 0, "total" : 214 },
        "Total" : { "tp" : 0, "e": 0, "total" : 603 }
    }
    # index = get_index()

    results_file = sys.argv[1]
    if not os.path.exists(results_file):
        print(f"File {results_file} does not exist")
        return 1
    results = parse_csv(results_file)

    for row in results:
        ty = row[3]
        tp = row[6]
        if tp == "true":
            tbl[ty]["tp"] += 1
            tbl["Total"]["tp"] += 1
            e = row[7]
            if e == "true":
                tbl[ty]["e"] += 1
                tbl["Total"]["e"] += 1

    print_markdown_table(tbl)
    return 0

if __name__ == "__main__":
    sys.exit(main())
