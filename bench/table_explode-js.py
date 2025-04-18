import os
import csv
import json

index_file = "./datasets/index.json"

def get_index():
    with open(index_file, "r") as fd:
        return json.load(fd)

cwe22_file = "./datasets/CWE-22/results.csv"
cwe78_file = "./datasets/CWE-78/results.csv"
cwe94_file = "./datasets/CWE-94/results.csv"
cwe1321_file = "./datasets/CWE-1321/results.csv"

def parse_csv(fpath):
    if not os.path.exists(fpath):
        return []
    with open(fpath, newline='') as csvfile:
        return list(csv.reader(csvfile, delimiter="|"))

def count(csv, ty, tbl):
    for row in csv:
        tp = row[6]
        if tp == "true":
            tbl[ty]["tp"] += 1
            tbl["Total"]["tp"] += 1
            e = row[7]
            if e == "true":
                tbl[ty]["e"] += 1
                tbl["Total"]["e"] += 1

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
    tbl = {
        "CWE-22": { "tp" : 0, "e" : 0, "total" : 166 },
        "CWE-78": { "tp" : 0, "e" : 0, "total" : 169 },
        "CWE-94": { "tp" : 0, "e" : 0, "total" : 54 },
        "CWE-1321": { "tp" : 0, "e" : 0, "total" : 214 },
        "Total" : { "tp" : 0, "e": 0, "total" : 603 }
    }
    cwe22 = parse_csv(cwe22_file)
    count(cwe22, "CWE-22", tbl)
    cwe78 = parse_csv(cwe78_file)
    count(cwe78, "CWE-78", tbl)
    cwe94 = parse_csv(cwe94_file)
    count(cwe94, "CWE-94", tbl)
    cwe1321 = parse_csv(cwe1321_file)
    count(cwe1321, "CWE-1321", tbl)
    print_markdown_table(tbl)

if __name__ == "__main__":
    main()
