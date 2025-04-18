import os
import csv
from table_nodemedic import fix_cwe_ty

def parse_csv(fpath):
    if not os.path.exists(fpath):
        return []
    with open(fpath, newline='') as csvfile:
        return list(csv.reader(csvfile, delimiter=","))

def safe_div(a, b):
    if b == 0:
        return 0
    return a / b

def print_markdown_table(tbl):
    # Determine column widths
    col_widths = {
        "CWE ID": max(len(cwe) for cwe in tbl.keys()),
        "Total": 9
    }

    # Formatting template
    row_format = "| {cwe:<{cwe_w}} | {total:>{total_w}} |"

    # Print header
    print(row_format.format(
        cwe="CWE ID", total="Avg. Time",
        cwe_w=col_widths["CWE ID"], total_w=col_widths["Total"]
    ))

    # Print separator
    print("|" + "-" * (col_widths["CWE ID"] + 2) + "|" + "-" * (col_widths["Total"] + 2) + "|")

    # Print rows
    for cwe, values in tbl.items():
        print(row_format.format(
            cwe=cwe, total=values['total'],
            cwe_w=col_widths["CWE ID"], total_w=col_widths["Total"]
        ))


def main():
    tbl = {
        "CWE-22": { "total" : 0. },
        "CWE-78": { "total" : 0. },
        "CWE-94": { "total" : 0. },
        "CWE-1321": { "total" : 0. },
        "Global Avg." : {  "total" : 0. }
    }

    csv_file = "./nodeMedic-parsed-results.csv"
    csv = parse_csv(csv_file)

    cwe22_times = []
    cwe78_times = []
    cwe94_times = []
    cwe1321_times = []

    for row in csv[1:]:
        ty = fix_cwe_ty(row[3])
        time = float(row[5])
        match ty:
            case "CWE-22":
                cwe22_times.append(time)
            case "CWE-78":
                cwe78_times.append(time)
            case "CWE-94":
                cwe94_times.append(time)
            case "CWE-1321":
                cwe1321_times.append(time)

    tbl["CWE-22"]["total"] = round(safe_div(sum(cwe22_times),len(cwe22_times)), 3)
    tbl["CWE-78"]["total"] = round(safe_div(sum(cwe78_times),len(cwe78_times)), 3)
    tbl["CWE-94"]["total"] = round(safe_div(sum(cwe94_times),len(cwe94_times)), 3)
    tbl["CWE-1321"]["total"] = round(safe_div(sum(cwe1321_times),len(cwe1321_times)), 3)
    total_times = cwe22_times + cwe78_times + cwe94_times + cwe1321_times
    tbl["Global Avg."]["total"] = round(safe_div(sum(total_times),len(total_times)), 3)

    print_markdown_table(tbl)

if __name__ == "__main__":
    main()
