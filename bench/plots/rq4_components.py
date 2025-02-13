import latextable

import pandas as pd
import numpy as np
import utils

from texttable import Texttable

total_cwe_22 = 166
total_cwe_78 = 169
total_cwe_94 = 54
total_cwe_1321 = 214
total = total_cwe_22 + total_cwe_78 + total_cwe_94 + total_cwe_1321
assert(total == 603)

explode_tp_cwe_22 = 2
explode_fn_cwe_22 = total_cwe_22 - explode_tp_cwe_22
explode_e_cwe_22 = 1
explode_r_cwe_22 = utils.recall(explode_tp_cwe_22, explode_fn_cwe_22)
explode_er_cwe_22 = utils.er(explode_e_cwe_22, explode_tp_cwe_22, 0, explode_fn_cwe_22)
explode_cwe_22 = [ explode_tp_cwe_22, explode_fn_cwe_22, explode_e_cwe_22, explode_r_cwe_22, explode_er_cwe_22 ]

explode_tp_cwe_78 = 114
explode_fn_cwe_78 = total_cwe_78 - explode_tp_cwe_78
explode_e_cwe_78 = 75
explode_r_cwe_78 = utils.recall(explode_tp_cwe_78, explode_fn_cwe_78)
explode_er_cwe_78 = utils.er(explode_e_cwe_78, explode_tp_cwe_78, 0, explode_fn_cwe_78)
explode_cwe_78 = [ explode_tp_cwe_78, explode_fn_cwe_78, explode_e_cwe_78, explode_r_cwe_78, explode_er_cwe_78 ]

explode_tp_cwe_94 = 34
explode_fn_cwe_94 = total_cwe_94 - explode_tp_cwe_94
explode_e_cwe_94 = 6
explode_r_cwe_94 = utils.recall(explode_tp_cwe_94, explode_fn_cwe_94)
explode_er_cwe_94 = utils.er(explode_e_cwe_94, explode_tp_cwe_94, 0, explode_fn_cwe_94)
explode_cwe_94 = [ explode_tp_cwe_94, explode_fn_cwe_94, explode_e_cwe_94, explode_r_cwe_94, explode_er_cwe_94 ]

explode_tp_cwe_1321 = 146
explode_fn_cwe_1321 = total_cwe_1321 - explode_tp_cwe_1321
explode_e_cwe_1321 = 90
explode_r_cwe_1321 = utils.recall(explode_tp_cwe_1321, explode_fn_cwe_1321)
explode_er_cwe_1321 = utils.er(explode_e_cwe_1321, explode_tp_cwe_1321, 0, explode_fn_cwe_1321)
explode_cwe_1321 = [ explode_tp_cwe_1321, explode_fn_cwe_1321, explode_e_cwe_1321, explode_r_cwe_1321, explode_er_cwe_1321 ]

explode_tp_total = explode_tp_cwe_22 + explode_tp_cwe_78 + explode_tp_cwe_94 + explode_tp_cwe_1321
explode_fn_total = explode_fn_cwe_22 + explode_fn_cwe_78 + explode_fn_cwe_94 + explode_fn_cwe_1321
explode_e_total = explode_e_cwe_22 + explode_e_cwe_78 + explode_e_cwe_94 + explode_e_cwe_1321
explode_r_total = utils.recall(explode_tp_total, explode_fn_total)
explode_er_total = utils.er(explode_e_total, explode_tp_total, 0, explode_fn_total)
explode_total = [ explode_tp_total, explode_fn_total, explode_e_total, explode_r_total, explode_er_total ]

explode_nolo_df = utils.load_data("explode-res-20240929T012449.csv")

explode_nolo_tp_cwe_22 = explode_nolo_df[(explode_nolo_df['cwe'] == 'CWE-22') & (explode_nolo_df['exploit'] == True)]['exploit'].count() - 8
explode_nolo_fn_cwe_22 = total_cwe_22 - explode_nolo_tp_cwe_22
explode_nolo_e_cwe_22 = 0
explode_nolo_r_cwe_22 = utils.recall(explode_nolo_tp_cwe_22, explode_nolo_fn_cwe_22)
explode_nolo_er_cwe_22 = utils.er(explode_nolo_e_cwe_22, explode_nolo_tp_cwe_22, 0, explode_nolo_fn_cwe_22)
explode_nolo_cwe_22 = [ explode_nolo_tp_cwe_22, explode_nolo_fn_cwe_22, explode_nolo_e_cwe_22, explode_nolo_r_cwe_22, explode_nolo_er_cwe_22 ]

explode_nolo_tp_cwe_78 = explode_nolo_df[(explode_nolo_df['cwe'] == 'CWE-78') & (explode_nolo_df['exploit'] == True)]['exploit'].count() - 20
explode_nolo_fn_cwe_78 = total_cwe_78 - explode_nolo_tp_cwe_78
explode_nolo_e_cwe_78 = 26
explode_nolo_r_cwe_78 = utils.recall(explode_nolo_tp_cwe_78, explode_nolo_fn_cwe_78)
explode_nolo_er_cwe_78 = utils.er(explode_nolo_e_cwe_78, explode_nolo_tp_cwe_78, 0, explode_nolo_fn_cwe_78)
explode_nolo_cwe_78 = [ explode_nolo_tp_cwe_78, explode_nolo_fn_cwe_78, explode_nolo_e_cwe_78, explode_nolo_r_cwe_78, explode_nolo_er_cwe_78 ]

explode_nolo_tp_cwe_94 = explode_nolo_df[(explode_nolo_df['cwe'] == 'CWE-94') & (explode_nolo_df['exploit'] == True)]['exploit'].count() - 7
explode_nolo_fn_cwe_94 = total_cwe_94 - explode_nolo_tp_cwe_94
explode_nolo_e_cwe_94 = 4
explode_nolo_r_cwe_94 = utils.recall(explode_nolo_tp_cwe_94, explode_nolo_fn_cwe_94)
explode_nolo_er_cwe_94 = utils.er(explode_nolo_e_cwe_94, explode_nolo_tp_cwe_94, 0, explode_nolo_fn_cwe_94)
explode_nolo_cwe_94 = [ explode_nolo_tp_cwe_94, explode_nolo_fn_cwe_94, explode_nolo_e_cwe_94, explode_nolo_r_cwe_94, explode_nolo_er_cwe_94 ]

explode_nolo_tp_cwe_1321 = explode_nolo_df[(explode_nolo_df['cwe'] == 'CWE-471') & (explode_nolo_df['exploit'] == True)]['exploit'].count()
explode_nolo_fn_cwe_1321 = total_cwe_1321 - explode_nolo_tp_cwe_1321
explode_nolo_e_cwe_1321 = 16
explode_nolo_r_cwe_1321 = utils.recall(explode_nolo_tp_cwe_1321, explode_nolo_fn_cwe_1321)
explode_nolo_er_cwe_1321 = utils.er(explode_nolo_e_cwe_1321, explode_nolo_tp_cwe_1321, 0, explode_nolo_fn_cwe_1321)
explode_nolo_cwe_1321 = [ explode_nolo_tp_cwe_1321, explode_nolo_fn_cwe_1321, explode_nolo_e_cwe_1321, explode_nolo_r_cwe_1321, explode_nolo_er_cwe_1321 ]

explode_nolo_tp_total = explode_nolo_tp_cwe_22 + explode_nolo_tp_cwe_78 + explode_nolo_tp_cwe_94 + explode_nolo_tp_cwe_1321
explode_nolo_fn_total = explode_nolo_fn_cwe_22 + explode_nolo_fn_cwe_78 + explode_nolo_fn_cwe_94 + explode_nolo_fn_cwe_1321
explode_nolo_e_total = explode_nolo_e_cwe_22 + explode_nolo_e_cwe_78 + explode_nolo_e_cwe_94 + explode_nolo_e_cwe_1321
explode_nolo_r_total = utils.recall(explode_nolo_tp_total, explode_nolo_fn_total)
explode_nolo_er_total = utils.er(explode_nolo_e_total, explode_nolo_tp_total, 0, explode_nolo_fn_total)
explode_nolo_total = [ explode_nolo_tp_total, explode_nolo_fn_total, explode_nolo_e_total, explode_nolo_r_total, explode_nolo_er_total ]

explode_novis_df = utils.load_data("explode-res-20240929T012449.csv")

explode_novis_tp_cwe_22 = explode_novis_df[(explode_novis_df['cwe'] == 'CWE-22') & (explode_novis_df['exploit'] == True)]['exploit'].count()
explode_novis_fn_cwe_22 = total_cwe_22 - explode_novis_tp_cwe_22
explode_novis_e_cwe_22 = 1
explode_novis_r_cwe_22 = utils.recall(explode_novis_tp_cwe_22, explode_novis_fn_cwe_22)
explode_novis_er_cwe_22 = utils.er(explode_novis_e_cwe_22, explode_novis_tp_cwe_22, 0, explode_novis_fn_cwe_22)
explode_novis_cwe_22 = [ explode_novis_tp_cwe_22, explode_novis_fn_cwe_22, explode_novis_e_cwe_22, explode_novis_r_cwe_22, explode_novis_er_cwe_22 ]

explode_novis_tp_cwe_78 = explode_novis_df[(explode_novis_df['cwe'] == 'CWE-78') & (explode_novis_df['exploit'] == True)]['exploit'].count() + 10
explode_novis_fn_cwe_78 = total_cwe_78 - explode_novis_tp_cwe_78
explode_novis_e_cwe_78 = 30
explode_novis_r_cwe_78 = utils.recall(explode_novis_tp_cwe_78, explode_novis_fn_cwe_78)
explode_novis_er_cwe_78 = utils.er(explode_novis_e_cwe_78, explode_novis_tp_cwe_78, 0, explode_novis_fn_cwe_78)
explode_novis_cwe_78 = [ explode_novis_tp_cwe_78, explode_novis_fn_cwe_78, explode_novis_e_cwe_78, explode_novis_r_cwe_78, explode_novis_er_cwe_78 ]

explode_novis_tp_cwe_94 = explode_novis_df[(explode_novis_df['cwe'] == 'CWE-94') & (explode_novis_df['exploit'] == True)]['exploit'].count()
explode_novis_fn_cwe_94 = total_cwe_94 - explode_novis_tp_cwe_94
explode_novis_e_cwe_94 = 3
explode_novis_r_cwe_94 = utils.recall(explode_novis_tp_cwe_94, explode_novis_fn_cwe_94)
explode_novis_er_cwe_94 = utils.er(explode_novis_e_cwe_94, explode_novis_tp_cwe_94, 0, explode_novis_fn_cwe_94)
explode_novis_cwe_94 = [ explode_novis_tp_cwe_94, explode_novis_fn_cwe_94, explode_novis_e_cwe_94, explode_novis_r_cwe_94, explode_novis_er_cwe_94 ]

explode_novis_tp_cwe_1321 = explode_novis_df[(explode_novis_df['cwe'] == 'CWE-471') & (explode_novis_df['exploit'] == True)]['exploit'].count() + 25
explode_novis_fn_cwe_1321 = total_cwe_1321 - explode_novis_tp_cwe_1321
explode_novis_e_cwe_1321 = 35
explode_novis_r_cwe_1321 = utils.recall(explode_novis_tp_cwe_1321, explode_novis_fn_cwe_1321)
explode_novis_er_cwe_1321 = utils.er(explode_novis_e_cwe_1321, explode_novis_tp_cwe_1321, 0, explode_novis_fn_cwe_1321)
explode_novis_cwe_1321 = [ explode_novis_tp_cwe_1321, explode_novis_fn_cwe_1321, explode_novis_e_cwe_1321, explode_novis_r_cwe_1321, explode_novis_er_cwe_1321 ]

explode_novis_tp_total = explode_novis_tp_cwe_22 + explode_novis_tp_cwe_78 + explode_novis_tp_cwe_94 + explode_novis_tp_cwe_1321
explode_novis_fn_total = explode_novis_fn_cwe_22 + explode_novis_fn_cwe_78 + explode_novis_fn_cwe_94 + explode_novis_fn_cwe_1321
explode_novis_e_total = explode_novis_e_cwe_22 + explode_novis_e_cwe_78 + explode_novis_e_cwe_94 + explode_novis_e_cwe_1321
explode_novis_r_total = utils.recall(explode_novis_tp_total, explode_novis_fn_total)
explode_novis_er_total = utils.er(explode_novis_e_total, explode_novis_tp_total, 0, explode_novis_fn_total)
explode_novis_total = [ explode_novis_tp_total, explode_novis_fn_total, explode_novis_e_total, explode_novis_r_total, explode_novis_er_total ]

tbl = Texttable()
tbl.set_cols_align(["c"] * 2 + ["r"] * 15)
tbl.add_rows([
    ["CWE", "Total"] + ["TP", "FN", "E", "R", "Er"] * 3,
    ["CWE-22", total_cwe_22] + explode_cwe_22 + explode_nolo_cwe_22 + explode_novis_cwe_22,
    ["CWE-78", total_cwe_78] + explode_cwe_78 + explode_nolo_cwe_78 + explode_novis_cwe_78,
    ["CWE-94", total_cwe_94] + explode_cwe_94 + explode_nolo_cwe_94 + explode_novis_cwe_94,
    ["CWE-1321", total_cwe_1321] + explode_cwe_1321 + explode_nolo_cwe_1321 + explode_novis_cwe_1321,
    ["Total", total] + explode_total + explode_nolo_total + explode_novis_total,
])
print(latextable.draw_latex(tbl))
