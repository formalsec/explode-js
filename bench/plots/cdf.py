import sys
import pandas as pd
import matplotlib.pyplot as plt

if len(sys.argv) < 2:
    print(f"usage: {sys.argv[0]} /path/to/file.csv")
    exit(1)

csv_file = sys.argv[1]

df = pd.read_csv(csv_file)
df = df.sort_values(by="rtime")
n_rows = len(df)
df = df[df['rtime'] < 300]
df['cumulative_markers'] = [ (i / n_rows) * 100 for i in range(1, len(df) + 1)]
plt.figure(figsize=(14, 8))
plt.step(df['rtime'], df['cumulative_markers'], where='post', label='FAST', linewidth=5.0)
# Set the x and y axis to start at zero and remove margins
plt.xlim(left=0)  # X-axis starts at 0
plt.ylim(bottom=0)  # Y-axis starts at 0
#plt.margins(x=0, y=0)  # Remove any margins around the plot
plt.xlabel('Time (s)', fontsize=36)
plt.ylabel('Percentage of finished files [%]', fontsize=30)
plt.minorticks_on()
plt.grid(True, which='major', linestyle='-', linewidth=2.0)
# plt.grid(True, which='minor', linestyle=':', linewidth=2.0)

# Remove the top and right frame (spines)
ax = plt.gca()  # Get current axes
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['bottom'].set_linewidth(2.0)
ax.spines['left'].set_linewidth(2.0)
ax.tick_params(axis='x', width=2.0)
ax.tick_params(axis='y', width=2.0)
ax.tick_params(axis='x', which='minor', width=2)
ax.tick_params(axis='y', which='minor', width=2)

plt.xticks(fontsize=30)
plt.yticks(fontsize=30)
plt.legend(loc='lower right', fontsize=36)

plt.tight_layout()
plt.savefig("cdf.pdf")
