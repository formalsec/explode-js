import re
import utils

import pandas as pd
import matplotlib.pyplot as plt
from matplotlib_venn import venn2

nm_re = r"([a-zA-Z0-9-]+)-(\d+\.\d+\.\d+(?:-[a-zA-Z]+\.\d+)?)"

def normalize_nm(path):
    print(path)
    match = re.search(nm_re, path)
    if match:
        return match.group(1) + "_" + match.group(2)
    # Should be unreachable
    assert(False)

fast_re = r"([a-zA-Z0-9-]+)_(\d+\.\d+\.\d+(?:-[a-zA-Z]+\.\d+)?)"

def normalize_fast(path):
    print(path)
    match = re.search(fast_re, path)
    if match:
        return match.group(1) + "_" + match.group(2)
    # Should be unreachable
    # assert(False)
    return path

df_fast = utils.load_data("fast-vulcan-secbench-results.csv")
df_nodemedic = utils.load_data("nodemedic-vulcan-secbench-results.csv")

df_nodemedic_cwe_78 = df_nodemedic[(df_nodemedic['cwe'] == 'CWE-78') & (df_nodemedic['exploit'] == True)]
df_fast_cwe_78 = df_fast[(df_fast['cwe'] == 'CWE-78') & (df_fast['exploit'] == 'successful')]

df_nodemedic_cwe_94 = df_nodemedic[(df_nodemedic['cwe'] == 'CWE-94') & (df_nodemedic['exploit'] == True)]
df_fast_cwe_94 = df_fast[(df_fast['cwe'] == 'CWE-94') & (df_fast['exploit'] == 'successful')]

# Extract benchmark names for Venn diagram
nodemedic_cwe_78 = set(map(normalize_nm, df_nodemedic_cwe_78['benchmark']))
fast_cwe_78 = set(map(normalize_fast, df_fast_cwe_78['benchmark']))

nodemedic_cwe_94 = set(map(normalize_nm, df_nodemedic_cwe_94['benchmark']))
fast_cwe_94 = set(map(normalize_fast, df_fast_cwe_94['benchmark']))

plt.figure(figsize=(12, 6))

plt.subplot(1, 2, 1)
venn = venn2([nodemedic_cwe_78, fast_cwe_78], set_labels=('NodeMedic', 'FAST'))
plt.title("CWE-78")

plt.subplot(1, 2, 2)
venn = venn2([nodemedic_cwe_94, fast_cwe_94], set_labels=('NodeMedic', 'FAST'))
plt.title("CWE-94")

plt.figlegend(['Detected by NodeMedic', 'Detected by Fast', 'Detected by Both'], loc='lower center', ncol=3)
plt.tight_layout()#rect=[0, 0, 1, 0.95])  # Make space for the legend
plt.savefig("rq1_venn.pdf")
