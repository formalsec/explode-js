import pandas as pd
import matplotlib.pyplot as plt

# CSV files
csv_fast = "fast-vulcan-secbench-results.csv"
csv_nodemedic = "nodemedic-vulcan-secbench-results.csv"
csv_explode = "explode-vulcan-secbench-results.csv"

# Upper bound of time to consider
time_ub = 124

# Parse data frames
df_fast = pd.read_csv(csv_fast)
df_fast = df_fast.sort_values(by="total_time")
df_fast_rows = len(df_fast)
df_fast = df_fast[df_fast['total_time'] <= time_ub]
df_fast['cumulative_markers'] = [ (i / df_fast_rows) * 100 for i in range(1, len(df_fast) + 1) ]

df_nodemedic = pd.read_csv(csv_nodemedic)
df_nodemedic = df_nodemedic.sort_values(by="total_time")
df_nodemedic_rows = len(df_nodemedic)
df_nodemedic = df_nodemedic[df_nodemedic['total_time'] <= time_ub]
df_nodemedic['cumulative_markers'] = [ (i / df_nodemedic_rows) * 100 for i in range(1, len(df_nodemedic) + 1) ]

df_explode = pd.read_csv(csv_explode, sep="|")
df_explode = df_explode.sort_values(by="rtime")
df_explode_rows = len(df_explode)
df_explode = df_explode[df_explode['rtime'] <= time_ub]
df_explode['cumulative_markers'] = [ (i / df_explode_rows) * 100 for i in range(1, len(df_explode) + 1) ]

# Plot configuration
thickness_grid = 2.0
thickness_plot = 5.0
fontsize_ticks = 30
fontsize_text = 36
plt.figure(figsize=(14, 8))

# Plot fast
plt.step(
    df_fast['total_time'],
    df_fast['cumulative_markers'],
    where='post',
    label='FAST',
    linewidth=thickness_plot
)

# Plot nodemedic
plt.step(
    df_nodemedic['total_time'],
    df_nodemedic['cumulative_markers'],
    where='post',
    label='NodeMedic',
    linewidth=thickness_plot
)

plt.step(
    df_explode['rtime'],
    df_explode['cumulative_markers'],
    where='post',
    label='Explode.js',
    linewidth=thickness_plot
)

plt.xlim(left=0)  # X-axis starts at 0
plt.xticks(fontsize=fontsize_ticks)
plt.xlabel('Time (s)', fontsize=fontsize_text)

plt.ylim(bottom=0)  # Y-axis starts at 0
plt.yticks(fontsize=fontsize_ticks)
plt.ylabel('Percentage of finished files [%]', fontsize=fontsize_ticks)

plt.minorticks_on()
plt.grid(True, which='major', linestyle='-', linewidth=thickness_grid)

ax = plt.gca()  # Get current axes

ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['bottom'].set_linewidth(thickness_grid)
ax.spines['left'].set_linewidth(thickness_grid)

ax.tick_params(axis='x', width=thickness_grid)
ax.tick_params(axis='y', width=thickness_grid)
ax.tick_params(axis='x', which='minor', width=thickness_grid)
ax.tick_params(axis='y', which='minor', width=thickness_grid)

# Put legend on
plt.legend(loc='lower right', fontsize=fontsize_text)
# Save fig
plt.tight_layout()
plt.savefig("rq3_cdf_finish.pdf")
