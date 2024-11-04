import os
import re
import utils

import matplotlib.pyplot as plt
from matplotlib_venn import venn3, venn2

index = utils.load_json("explodejs-datasets/index.json")
index_by_file = {}
for pkg in index:
    name_version = pkg["package"] + "_" + pkg["version"]
    for vuln in pkg["vulns"]:
        filename = vuln["filename"]
        short_filename = "/".join(filename.split("/")[:3])
        index_by_file[short_filename] = name_version

nm_re = r"([a-zA-Z0-9-]+)-(\d+\.\d+\.\d+(?:-[a-zA-Z]+\.\d+)?)"

def normalize_nm(path):
    match = re.search(nm_re, path)
    if match:
        return match.group(1) + "_" + match.group(2)
    # Should be unreachable
    assert(False)

def normalize_fast(path):
    path = os.path.splitext(path)[0] + ".js"
    split_path = path.split("/")
    path = "/".join(split_path[2:5])
    return index_by_file[path]

def normalize_explode(path):
    try:
        return index_by_file[path]
    except:
        print(path)
        return path

df_fast = utils.load_data("fast-vulcan-secbench-results.csv")
df_nodemedic = utils.load_data("nodemedic-vulcan-secbench-results.csv")
df_explode = utils.load_data("explode-vulcan-secbench-results.csv")

df_fast_cwe_22 = df_fast[(df_fast['cwe'] == 'CWE-22') & (df_fast['exploit'] == 'successful')]
df_explode_cwe_22 = df_explode[(df_explode['cwe'] == 'CWE-22') & (df_explode['control_path'] == 'true')]

df_fast_cwe_78 = df_fast[(df_fast['cwe'] == 'CWE-78') & (df_fast['exploit'] == 'successful')]
df_nodemedic_cwe_78 = df_nodemedic[(df_nodemedic['cwe'] == 'CWE-78') & (df_nodemedic['exploit'] == True)]
df_explode_cwe_78 = df_explode[(df_explode['cwe'] == 'CWE-78') & (df_explode['control_path'] == 'true')]

df_fast_cwe_94 = df_fast[(df_fast['cwe'] == 'CWE-94') & (df_fast['exploit'] == 'successful')]
df_nodemedic_cwe_94 = df_nodemedic[(df_nodemedic['cwe'] == 'CWE-94') & (df_nodemedic['exploit'] == True)]
df_explode_cwe_94 = df_explode[(df_explode['cwe'] == 'CWE-94') & (df_explode['control_path'] == 'true')]

df_fast_cwe_471 = df_fast[(df_fast['cwe'] == 'CWE-471') & (df_fast['exploit'] == 'successful')]
df_explode_cwe_471 = df_explode[(df_explode['cwe'] == 'CWE-471') & (df_explode['control_path'] == 'true')]

# Extract benchmark names for Venn diagram
fast_cwe_22 = set(map(normalize_fast, df_fast_cwe_22['benchmark']))
explode_cwe_22 = set(map(normalize_explode, df_explode_cwe_22['benchmark']))

fast_cwe_78 = set(map(normalize_fast, df_fast_cwe_78['benchmark']))
nodemedic_cwe_78 = set(map(normalize_nm, df_nodemedic_cwe_78['benchmark']))
explode_cwe_78 = set(map(normalize_explode, df_explode_cwe_78['benchmark']))

fast_cwe_94 = set(map(normalize_fast, df_fast_cwe_94['benchmark']))
nodemedic_cwe_94 = set(map(normalize_nm, df_nodemedic_cwe_94['benchmark']))
explode_cwe_94 = set(map(normalize_explode, df_explode_cwe_94['benchmark']))

fast_cwe_471 = set(map(normalize_fast, df_fast_cwe_471['benchmark']))
explode_cwe_471 = set(map(normalize_explode, df_explode_cwe_471['benchmark']))

fontsize_title = 14
width_edge = 1.5
color_fast = '#BAE1FF'
color_explode = '#FF5733'
color_nodemedic = '#3357FF'
color_edge = '#000000'

plt.figure(figsize=(12, 4))

plt.subplot(1, 3, 1)
cwe22 = venn2(
        [fast_cwe_22, explode_cwe_22],
        set_labels=('', ''),
        set_colors=(color_fast, color_explode)
)
plt.title("CWE-22", fontsize=fontsize_title)
for subset in ('10', '01', '11'):
    if cwe22.get_patch_by_id(subset):
        cwe22.get_patch_by_id(subset).set_edgecolor(color_edge)
        cwe22.get_patch_by_id(subset).set_linewidth(width_edge)

plt.subplot(1, 3, 2)
cwe78 = venn3(
        [nodemedic_cwe_78, fast_cwe_78, explode_cwe_78],
        set_labels=('', '', ''),
        set_colors=(color_nodemedic, color_fast, color_explode),
)
plt.title("CWE-78", fontsize=fontsize_title)
for subset in ('100', '010', '001', '110', '101', '011', '111'):
    if cwe78.get_patch_by_id(subset):
        cwe78.get_patch_by_id(subset).set_edgecolor(color_edge)
        cwe78.get_patch_by_id(subset).set_linewidth(width_edge)

plt.subplot(1, 3, 3)
cwe94 = venn3(
        [nodemedic_cwe_94, fast_cwe_94, explode_cwe_94],
        set_labels=('', '', ''),
        set_colors=(color_nodemedic, color_fast, color_explode),
)
plt.title("CWE-94", fontsize=fontsize_title)
for subset in ('100', '010', '001', '110', '101', '011', '111'):
    if cwe94.get_patch_by_id(subset):
        cwe94.get_patch_by_id(subset).set_edgecolor(color_edge)
        cwe94.get_patch_by_id(subset).set_linewidth(width_edge)

# plt.subplot(1, 4, 4)
# cwe1312 = venn2(
#         [fast_cwe_471, explode_cwe_471],
#         set_labels=('', ''),
#         set_colors=('firebrick', 'orange')
# )
# plt.title("CWE-1321", fontsize=14)

for text in cwe22.subset_labels + cwe78.subset_labels + cwe94.subset_labels:
    if text:
        text.set_fontsize(12)

plt.figlegend(['Detected by FAST', 'Detected by Explode-js', 'Detected by NodeMedic'], loc='lower center', ncol=3, fontsize=16)
plt.tight_layout(pad=5.0)#pad=1.0, rect=[0, 0.05, 1, 0.95])
plt.savefig("rq1_venn.pdf")
