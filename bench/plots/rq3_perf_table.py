import pandas as pd
import numpy as np
from texttable import Texttable
import latextable

def load_data(filename):
    return pd.read_csv(filename)

def compute_average_rtime(df):
    df = df[df['marker'] != "Timeout"]
    # Ensure rtime is treated as a float (it might be a string initially)
    df['rtime'] = pd.to_numeric(df['rtime'], errors='coerce')

    avg_rtime_df = df.groupby('cwe')['rtime'].mean().reset_index()
    avg_rtime_df = avg_rtime_df.sort_values(by='cwe')

    total_avg_rtime = df['rtime'].mean()
    return avg_rtime_df, total_avg_rtime

fast_df = load_data("fast-vulcan-secbench-results.csv")
nodemedic_df = load_data("nodemedic-vulcan-secbench-results.csv")
explode_df = load_data("explode-vulcan-results.csv")

avg_fast_df, fast_total_avg_time = compute_average_rtime(fast_df)
avg_nodemedic_df, nodemedic_total_avg_time = compute_average_rtime(nodemedic_df)
avg_explode_df, explode_total_avg_time = compute_average_rtime(explode_df)

explode_cwe_22 = avg_explode_df[avg_explode_df['cwe'] == 'CWE-22']['rtime'].values[0]
explode_cwe_78 = avg_explode_df[avg_explode_df['cwe'] == 'CWE-78']['rtime'].values[0]
explode_cwe_94 = avg_explode_df[avg_explode_df['cwe'] == 'CWE-94']['rtime'].values[0]
explode_cwe_471 = avg_explode_df[avg_explode_df['cwe'] == 'CWE-471']['rtime'].values[0]
explode_cwe_471 += avg_explode_df[avg_explode_df['cwe'] == 'CWE-1321']['rtime'].values[0]

fast_cwe_22 = avg_fast_df[avg_fast_df['cwe'] == 'CWE-22']['rtime'].values[0]
fast_cwe_78 = avg_fast_df[avg_fast_df['cwe'] == 'CWE-78']['rtime'].values[0]
fast_cwe_94 = avg_fast_df[avg_fast_df['cwe'] == 'CWE-94']['rtime'].values[0]
fast_cwe_471 = avg_fast_df[avg_fast_df['cwe'] == 'CWE-471']['rtime'].values[0]

nodemedic_cwe_22 = avg_nodemedic_df[avg_nodemedic_df['cwe'] == 'CWE-22']['rtime'].values[0]
nodemedic_cwe_78 = avg_nodemedic_df[avg_nodemedic_df['cwe'] == 'CWE-78']['rtime'].values[0]
nodemedic_cwe_94 = avg_nodemedic_df[avg_nodemedic_df['cwe'] == 'CWE-94']['rtime'].values[0]
nodemedic_cwe_471 = avg_nodemedic_df[avg_nodemedic_df['cwe'] == 'CWE-471']['rtime'].values[0]

table_str = Texttable()
table_str.set_cols_align(["c"] + ["r"] * 5)
table_str.add_rows([
    ["CWE", "Static", "Symbolic", "Total", "FAST", "NodeMedic"],
    ["CWE-22", "", "", str(explode_cwe_22), str(fast_cwe_22), str(nodemedic_cwe_22)],
    ["CWE-78", "", "", str(explode_cwe_78), str(fast_cwe_78), str(nodemedic_cwe_78)],
    ["CWE-94", "", "", str(explode_cwe_94), str(fast_cwe_94), str(nodemedic_cwe_94)],
    ["CWE-471", "", "", str(explode_cwe_471), str(fast_cwe_471), str(nodemedic_cwe_471)],
    ["Total", "", "", str(explode_total_avg_time), str(fast_total_avg_time), str(nodemedic_total_avg_time)]
])
print(latextable.draw_latex(table_str))
