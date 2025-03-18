import os
import glob

cwe22_path = "./bench/datasets/CWE-22"
cwe78_path = "./bench/datasets/CWE-78"
cwe94_path = "./bench/datasets/CWE-94"
cwe1321_path = "./bench/datasets/CWE-1321"

def static_time(file):
    dir = os.path.dirname(file)
    return os.path.join(dir, "graphjs_time.txt")

def parse_time(file):
    with open(file, "r") as fd:
        lines = fd.readlines()
    head = lines[0].rstrip()
    return float(head)

def print_markdown_table(tbl):
    # Determine column widths
    col_widths = {
        "CWE ID": max(len(cwe) for cwe in tbl.keys()),
        "Static": 6,
        "Symbolic": 8,
        "Total": 6
    }

    # Formatting template
    row_format = "| {cwe:<{cwe_w}} | {tp:>{tp_w}} | {e:>{e_w}} | {total:>{total_w}} |"

    # Print header
    print(row_format.format(
        cwe="CWE ID", tp="Static", e="Symbolic", total="Total",
        cwe_w=col_widths["CWE ID"], tp_w=col_widths["Static"],
        e_w=col_widths["Symbolic"], total_w=col_widths["Total"]
    ))

    # Print separator
    print("|" + "-" * (col_widths["CWE ID"] + 2) + "|" + "-" * (col_widths["Static"] + 2) + "|" + "-" * (col_widths["Symbolic"] + 2) + "|" + "-" * (col_widths["Total"] + 2) + "|")

    # Print rows
    for cwe, values in tbl.items():
        print(row_format.format(
            cwe=cwe, tp=values['static'], e=values['symbolic'], total=values['total'],
            cwe_w=col_widths["CWE ID"], tp_w=col_widths["Static"],
            e_w=col_widths["Symbolic"], total_w=col_widths["Total"]
        ))



def main():
    tbl = {
        "CWE-22": { "static" : 0., "symbolic" : 0., "total" : 0. },
        "CWE-78": { "static" : 0., "symbolic" : 0., "total" : 0. },
        "CWE-94": { "static" : 0., "symbolic" : 0., "total" : 0. },
        "CWE-1321": { "static" : 0., "symbolic" : 0., "total" : 0. },
        "Total" : { "static" : 0., "symbolic": 0., "total" : 0. }
    }
    cwe22_times = os.path.join(cwe22_path, "**", "explode_time.txt")
    cwe22_explode_times = glob.glob(cwe22_times, recursive=True)
    cwe22_graphjs_times = list(map(static_time, cwe22_explode_times))
    cwe22_graphjs_times = list(map(parse_time, cwe22_graphjs_times))
    cwe22_explode_times = list(map(parse_time, cwe22_explode_times))
    tbl["CWE-22"]["static"] = round((sum(cwe22_graphjs_times) / len(cwe22_graphjs_times)), 3)
    tbl["CWE-22"]["symbolic"] = round((sum(cwe22_explode_times) / len(cwe22_explode_times)), 3)
    cwe22_total_times = list(map(lambda t: t[0]+ t[1], zip(cwe22_graphjs_times, cwe22_explode_times)))
    tbl["CWE-22"]["total"] = round((sum(cwe22_total_times) / len(cwe22_total_times)), 3)

    cwe78_times = os.path.join(cwe78_path, "**", "explode_time.txt")
    cwe78_explode_times = glob.glob(cwe78_times, recursive=True)
    cwe78_graphjs_times = list(map(static_time, cwe78_explode_times))
    cwe78_graphjs_times = list(map(parse_time, cwe78_graphjs_times))
    cwe78_explode_times = list(map(parse_time, cwe78_explode_times))
    tbl["CWE-78"]["static"] = round((sum(cwe78_graphjs_times) / len(cwe78_graphjs_times)), 3)
    tbl["CWE-78"]["symbolic"] = round((sum(cwe78_explode_times) / len(cwe78_explode_times)), 3)
    cwe78_total_times = list(map(lambda t: t[0]+ t[1], zip(cwe78_graphjs_times, cwe78_explode_times)))
    tbl["CWE-78"]["total"] = round((sum(cwe78_total_times) / len(cwe78_total_times)), 3)

    cwe94_times = os.path.join(cwe94_path, "**", "explode_time.txt")
    cwe94_explode_times = glob.glob(cwe94_times, recursive=True)
    cwe94_graphjs_times = list(map(static_time, cwe94_explode_times))
    cwe94_graphjs_times = list(map(parse_time, cwe94_graphjs_times))
    cwe94_explode_times = list(map(parse_time, cwe94_explode_times))
    tbl["CWE-94"]["static"] = round((sum(cwe94_graphjs_times) / len(cwe94_graphjs_times)), 3)
    tbl["CWE-94"]["symbolic"] = round((sum(cwe94_explode_times) / len(cwe94_explode_times)), 3)
    cwe94_total_times = list(map(lambda t: t[0]+ t[1], zip(cwe94_graphjs_times, cwe94_explode_times)))
    tbl["CWE-94"]["total"] = round((sum(cwe94_total_times) / len(cwe94_total_times)), 3)


    cwe1321_times = os.path.join(cwe1321_path, "**", "explode_time.txt")
    cwe1321_explode_times = glob.glob(cwe1321_times, recursive=True)
    cwe1321_graphjs_times = list(map(static_time, cwe1321_explode_times))
    cwe1321_graphjs_times = list(map(parse_time, cwe1321_graphjs_times))
    cwe1321_explode_times = list(map(parse_time, cwe1321_explode_times))
    tbl["CWE-1321"]["static"] = round(round((sum(cwe1321_graphjs_times) / len(cwe1321_graphjs_times)), 3), 3)
    tbl["CWE-1321"]["symbolic"] = round((sum(cwe1321_explode_times) / len(cwe1321_explode_times)), 3)
    cwe1321_total_times = list(map(lambda t: t[0]+ t[1], zip(cwe1321_graphjs_times, cwe1321_explode_times)))
    tbl["CWE-1321"]["total"] = round((sum(cwe1321_total_times) / len(cwe1321_total_times)), 3)


    total_graphjs_time = cwe22_graphjs_times + cwe78_graphjs_times + cwe94_graphjs_times + cwe1321_graphjs_times
    total_explode_time = cwe22_explode_times + cwe78_explode_times + cwe94_explode_times + cwe1321_explode_times
    tbl["Total"]["static"] = round((sum(total_graphjs_time) / len(total_graphjs_time)), 3)
    tbl["Total"]["symbolic"] = round((sum(total_explode_time) / len(total_graphjs_time)), 3)
    total_times = list(map(lambda t: t[0]+ t[1], zip(total_graphjs_time, total_explode_time)))
    tbl["Total"]["total"] = round((sum(total_times) / len(total_times)), 3)

    print_markdown_table(tbl)

if __name__ == "__main__":
    main()
