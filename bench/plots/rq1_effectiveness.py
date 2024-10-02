import latextable

import pandas as pd
import numpy as np

from texttable import Texttable

def load_data(filename):
    return pd.read_csv(filename)

def recall(tp, fn):
    return tp / (tp + fn)

def er(e, tp, fp):
    return e / (tp + fp)

total_cwe_22 = 166
total_cwe_78 = 169
total_cwe_94 = 54
total_cwe_1321 = 214
total = total_cwe_22 + total_cwe_78 + total_cwe_94 + total_cwe_1321
assert(total == 603)

explode_df = load_data("explode-vulcan-results.csv")

explode_tp_cwe_22 = 2
explode_fn_cwe_22 = total_cwe_22 - explode_tp_cwe_22
explode_e_cwe_22 = 1
explode_r_cwe_22 = recall(explode_tp_cwe_22, explode_fn_cwe_22)
explode_er_cwe_22 = er(explode_e_cwe_22, explode_tp_cwe_22, 0)
explode_cwe_22 = [ explode_tp_cwe_22, explode_fn_cwe_22, explode_e_cwe_22, explode_r_cwe_22, explode_er_cwe_22 ]

explode_tp_cwe_78 = 114
explode_fn_cwe_78 = total_cwe_78 - explode_tp_cwe_78
explode_e_cwe_78 = 75
explode_r_cwe_78 = recall(explode_tp_cwe_78, explode_fn_cwe_78)
explode_er_cwe_78 = er(explode_e_cwe_78, explode_tp_cwe_78, 0)
explode_cwe_78 = [ explode_tp_cwe_78, explode_fn_cwe_78, explode_e_cwe_78, explode_r_cwe_78, explode_er_cwe_78 ]

explode_tp_cwe_94 = 34
explode_fn_cwe_94 = total_cwe_94 - explode_tp_cwe_94
explode_e_cwe_94 = 6
explode_r_cwe_94 = recall(explode_tp_cwe_94, explode_fn_cwe_94)
explode_er_cwe_94 = er(explode_e_cwe_94, explode_tp_cwe_94, 0)
explode_cwe_94 = [ explode_tp_cwe_94, explode_fn_cwe_94, explode_e_cwe_94, explode_r_cwe_94, explode_er_cwe_94 ]

explode_tp_cwe_1321 = 146
explode_fn_cwe_1321 = total_cwe_1321 - explode_tp_cwe_1321
explode_e_cwe_1321 = 90
explode_r_cwe_1321 = recall(explode_tp_cwe_1321, explode_fn_cwe_1321)
explode_er_cwe_1321 = er(explode_e_cwe_1321, explode_tp_cwe_1321, 0)
explode_cwe_1321 = [ explode_tp_cwe_1321, explode_fn_cwe_1321, explode_e_cwe_1321, explode_r_cwe_1321, explode_er_cwe_1321 ]

explode_tp_total = explode_tp_cwe_22 + explode_tp_cwe_78 + explode_tp_cwe_94 + explode_tp_cwe_1321
explode_fn_total = explode_fn_cwe_22 + explode_fn_cwe_78 + explode_fn_cwe_94 + explode_fn_cwe_1321
explode_e_total = explode_e_cwe_22 + explode_e_cwe_78 + explode_e_cwe_94 + explode_e_cwe_1321
explode_r_total = recall(explode_tp_total, explode_fn_total)
explode_er_total = er(explode_e_total, explode_tp_total, 0)
explode_total = [ explode_tp_total, explode_fn_total, explode_e_total, explode_r_total, explode_er_total ]

fast_df = load_data("fast-vulcan-secbench-results.csv")

fast_tp_cwe_22 = fast_df[(fast_df['cwe'] == 'CWE-22') & (fast_df['exploit'] == 'successful')]['exploit'].count()
fast_fn_cwe_22 = total_cwe_22 - fast_tp_cwe_22
fast_e_cwe_22 = 0
fast_r_cwe_22 = recall(fast_tp_cwe_22, fast_fn_cwe_22)
fast_er_cwe_22 = er(fast_e_cwe_22, fast_tp_cwe_22, 0)
fast_cwe_22 = [ fast_tp_cwe_22, fast_fn_cwe_22, fast_e_cwe_22, fast_r_cwe_22, fast_er_cwe_22 ]

fast_tp_cwe_78 = fast_df[(fast_df['cwe'] == 'CWE-78') & (fast_df['exploit'] == 'successful')]['exploit'].count()
fast_fn_cwe_78 = total_cwe_78 - fast_tp_cwe_78
fast_e_cwe_78 = 0
fast_r_cwe_78 = recall(fast_tp_cwe_78, fast_fn_cwe_78)
fast_er_cwe_78 = er(fast_e_cwe_78, fast_tp_cwe_78, 0)
fast_cwe_78 = [ fast_tp_cwe_78, fast_fn_cwe_78, fast_e_cwe_78, fast_r_cwe_78, fast_er_cwe_78 ]

fast_tp_cwe_94 = fast_df[(fast_df['cwe'] == 'CWE-94') & (fast_df['exploit'] == 'successful')]['exploit'].count()
fast_fn_cwe_94 = total_cwe_94 - fast_tp_cwe_94
fast_e_cwe_94 = 0
fast_r_cwe_94 = recall(fast_tp_cwe_94, fast_fn_cwe_94)
fast_er_cwe_94 = er(fast_e_cwe_94, fast_tp_cwe_94, 0)
fast_cwe_94 = [ fast_tp_cwe_94, fast_fn_cwe_94, fast_e_cwe_94, fast_r_cwe_94, fast_er_cwe_94 ]

fast_tp_cwe_1321 = fast_df[(fast_df['cwe'] == 'CWE-471') & (fast_df['exploit'] == 'successful')]['exploit'].count()
fast_fn_cwe_1321 = total_cwe_1321 - fast_tp_cwe_1321
fast_e_cwe_1321 = 0
fast_r_cwe_1321 = recall(fast_tp_cwe_1321, fast_fn_cwe_1321)
fast_er_cwe_1321 = er(fast_e_cwe_1321, fast_tp_cwe_1321, 0)
fast_cwe_1321 = [ fast_tp_cwe_1321, fast_fn_cwe_1321, fast_e_cwe_1321, fast_r_cwe_1321, fast_er_cwe_1321 ]

fast_tp_total = fast_tp_cwe_22 + fast_tp_cwe_78 + fast_tp_cwe_94 + fast_tp_cwe_1321
fast_fn_total = fast_fn_cwe_22 + fast_fn_cwe_78 + fast_fn_cwe_94 + fast_fn_cwe_1321
fast_e_total = fast_e_cwe_22 + fast_e_cwe_78 + fast_e_cwe_94 + fast_e_cwe_1321
fast_r_total = recall(fast_tp_total, fast_fn_total)
fast_er_total = er(fast_e_total, fast_tp_total, 0)
fast_total = [ fast_tp_total, fast_fn_total, fast_e_total, fast_r_total, fast_er_total ]

nodemedic_df = load_data("nodemedic-vulcan-secbench-results.csv")

nodemedic_tp_cwe_78 = nodemedic_df[((nodemedic_df['cwe'] == 'CWE-78') | (nodemedic_df['cwe'] == 'CWE-XYZ')) & (nodemedic_df['exploit'] == True)]['exploit'].count()
nodemedic_fn_cwe_78 = total_cwe_78 - nodemedic_tp_cwe_78
nodemedic_e_cwe_78 = nodemedic_tp_cwe_78
nodemedic_r_cwe_78 = recall(nodemedic_tp_cwe_78, nodemedic_fn_cwe_78)
nodemedic_er_cwe_78 = er(nodemedic_e_cwe_78, nodemedic_tp_cwe_78, 0)
nodemedic_cwe_78 = [ nodemedic_tp_cwe_78, nodemedic_fn_cwe_78, nodemedic_e_cwe_78, nodemedic_r_cwe_78, nodemedic_er_cwe_78 ]

nodemedic_tp_cwe_94 = nodemedic_df[((nodemedic_df['cwe'] == 'CWE-94') | (nodemedic_df['cwe'] == 'CWE-XYZ')) & (nodemedic_df['exploit'] == True)]['exploit'].count()
nodemedic_fn_cwe_94 = total_cwe_94 - nodemedic_tp_cwe_94
nodemedic_e_cwe_94 = nodemedic_tp_cwe_94
nodemedic_r_cwe_94 = recall(nodemedic_tp_cwe_94, nodemedic_fn_cwe_94)
nodemedic_er_cwe_94 = er(nodemedic_e_cwe_94, nodemedic_tp_cwe_94, 0)
nodemedic_cwe_94 = [ nodemedic_tp_cwe_94, nodemedic_fn_cwe_94, nodemedic_e_cwe_94, nodemedic_r_cwe_94, nodemedic_er_cwe_94 ]

nodemedic_tp_total = nodemedic_tp_cwe_78 + nodemedic_tp_cwe_94
nodemedic_fn_total = total - nodemedic_tp_total
nodemedic_e_total = nodemedic_e_cwe_78 + nodemedic_e_cwe_94
nodemedic_r_total = recall(nodemedic_tp_total, nodemedic_fn_total)
nodemedic_er_total = er(nodemedic_e_total, nodemedic_tp_total, 0)
nodemedic_total = [ nodemedic_tp_total, nodemedic_fn_total, nodemedic_e_total, nodemedic_r_total, nodemedic_er_total ]

tbl = Texttable()
tbl.set_cols_align(["c"] * 2 + ["r"] * 15)
tbl.add_rows([
    ["CWE", "Total"] + ["TP", "FN", "E", "R", "Er"] * 3,
    ["CWE-22", total_cwe_22] + explode_cwe_22 + fast_cwe_22 + ["--"] * 5,
    ["CWE-78", total_cwe_78] + explode_cwe_78 + fast_cwe_78 + nodemedic_cwe_78,
    ["CWE-94", total_cwe_94] + explode_cwe_94 + fast_cwe_94 + nodemedic_cwe_94,
    ["CWE-1321", total_cwe_1321] + explode_cwe_1321 + fast_cwe_1321 + ["--"] * 5,
    ["Total", total] + explode_total + fast_total + nodemedic_total
])
print(latextable.draw_latex(tbl))
