import os
import csv

def parse_csv(fpath):
    if not os.path.exists(fpath):
        return []
    with open(fpath, newline='') as csvfile:
        return list(csv.reader(csvfile, delimiter=","))

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

def fix_cwe_ty(ty):
    # FIXME: I don't know why this happens, but 2 vulnerabilities reported by
    # nodemedic have incorrect CWE types here. Look at index to see?
    if ty == "CWE-22":
        return "CWE-78"
    if ty == "CWE-1321":
        return "CWE-94"
    return ty

def main():
    tbl = {
        "CWE-22": { "tp" : 0, "e" : 0, "total" : 166 },
        "CWE-78": { "tp" : 0, "e" : 0, "total" : 169 },
        "CWE-94": { "tp" : 0, "e" : 0, "total" : 54 },
        "CWE-1321": { "tp" : 0, "e" : 0, "total" : 214 },
        "Total" : { "tp" : 0, "e": 0, "total" : 603 }
    }
    csv_file = "./nodeMedic-parsed-results.csv"
    csv = parse_csv(csv_file)
    for row in csv[1:]:
        ty = fix_cwe_ty(row[3])
        tp = row[6]
        e = row[7]
        if tp == "true":
            tbl[ty]["tp"] += 1
            tbl["Total"]["tp"] += 1
        if e == "true":
            tbl[ty]["e"] += 1
            tbl["Total"]["e"] += 1

    print_markdown_table(tbl)

if __name__ == "__main__":
    main()
