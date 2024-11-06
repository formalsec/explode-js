import utils

import matplotlib.pyplot as plt

df_explode = utils.load_data("explode-vulcan-secbench-results.csv")
df_explode = df_explode[df_explode['control_path'] == 'false']
df_explode = df_explode[df_explode['fn_reason'] != 'unknown']

# sanity check
print(df_explode)

fn_reason_counts = df_explode['fn_reason'].value_counts()
total = fn_reason_counts.sum()

fn_reason_counts.plot(kind='bar', edgecolor='black')
ax = fn_reason_counts.plot(kind='bar', edgecolor='black')

fontsize = 14

plt.xlabel('',fontsize=fontsize)
plt.ylabel('Frequency',fontsize=fontsize)
plt.xticks(rotation=45,fontsize=fontsize)

ax.set_ylim(0, fn_reason_counts.max() * 1.15)
ax.set_xticklabels([
    "Lazy values\nlimitations",
    "Unsupported VIS",
    "Summary\nlimitations",
    "Unsupported\nJS semantics",
    "Timeout"
])

for i, count in enumerate(fn_reason_counts):
    percentage = f"{(count / total) * 100:.1f}%"
    ax.text(i, count + 0.5, percentage, ha='center', fontsize=fontsize)

plt.tight_layout()
plt.savefig("rq1_histogram.pdf")
