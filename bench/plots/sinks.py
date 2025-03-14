import os
import csv
import sys
import json

# input_csv = 'datasets/res-20250311193142/results.csv'
input_csv = sys.argv[1]

def with_csv(filename, f):
    with open(filename, 'r') as csvfile:
        reader = csv.DictReader(csvfile, delimiter="|")
        return f(reader)

def parse_csv(reader):
    rows = []
    for row in reader:
        rows.append([ \
            row['package'], \
            row['version'], \
            row['id'], \
            row['cwe'], \
            row['filename'], \
            row['report'].encode().decode("unicode_escape"), \
            row['control_path'], \
            row['exploit'], \
        ])
    return rows

def main():
    rows = with_csv(input_csv, parse_csv)
    n_rows = [['package', 'version', 'id', 'cwe', 'filename', 'sym_test', 'control_path', 'exploit', 'sink']]
    for row in rows:
        package = row[0]
        version = row[1]
        id = row[2]
        cwe = row[3]
        filename  = row[4]
        report = row[5]
        control_path = True if row[6] == "true" else False
        exploit = True if row[7] == "true" else False
        if not control_path:
            n_rows.append([
                package,
                version,
                id,
                cwe,
                filename,
                "",
                str(control_path),
                str(exploit),
                ""
            ])
            continue

        data = json.loads(report)

        sinks = []
        for sym_test in data:
            sym_test_filename = sym_test["filename"]
            for failure in sym_test["failures"]:
                sinks.append({
                    "sym_test": sym_test_filename,
                    "sink": failure["sink"],
                    "exploit" : failure["exploit"]["success"]
                })

        assert (len(sinks) > 0)

        for sink in sinks:
            n_rows.append([
                package,
                version,
                id,
                cwe,
                filename,
                sink["sym_test"],
                str(control_path),
                str(sink["exploit"]),
                sink["sink"]
            ])

    output_csv = os.path.join(os.path.dirname(input_csv), "sinks.csv")
    with open(output_csv, "w") as csvfile:
        writer = csv.writer(csvfile, delimiter="|", quoting=csv.QUOTE_ALL)
        writer.writerows(n_rows)

main()
