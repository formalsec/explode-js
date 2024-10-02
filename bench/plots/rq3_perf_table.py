import latextable

import pandas as pd
import numpy as np

from texttable import Texttable

def load_data(filename):
    return pd.read_csv(filename)

# TODO: these functions were a quick yank-paste. Ask chatgpt if this can be improved.
def fast(df):
    df = df[df['marker'] != "Timeout"]
    # Ensure total_time is treated as a float (it might be a string initially)
    df['total_time'] = pd.to_numeric(df['total_time'], errors='coerce')

    avg_path_time_df = df.groupby('cwe')['path_time'].mean().reset_index()
    avg_path_time_df = avg_path_time_df.sort_values(by='cwe')
    total_avg_path_time = df['path_time'].mean()

    avg_expl_time_df = df.groupby('cwe')['expl_time'].mean().reset_index()
    avg_expl_time_df = avg_expl_time_df.sort_values(by='cwe')
    total_avg_expl_time = df['expl_time'].mean()

    avg_total_time_df = df.groupby('cwe')['total_time'].mean().reset_index()
    avg_total_time_df = avg_total_time_df.sort_values(by='cwe')
    total_avg_total_time = df['total_time'].mean()

    return {
        "path_time" : (avg_path_time_df, total_avg_path_time),
        "expl_time" : (avg_expl_time_df, total_avg_expl_time),
        "total_time" : (avg_total_time_df, total_avg_total_time)
    }

def explode(df):
    df = df[df['marker'] != "Timeout"]
    # Ensure total_time is treated as a float (it might be a string initially)
    df['total_time'] = pd.to_numeric(df['total_time'], errors='coerce')

    avg_static_time_df = df.groupby('cwe')['static_time'].mean().reset_index()
    avg_static_time_df = avg_static_time_df.sort_values(by='cwe')
    total_avg_static_time = df['static_time'].mean()

    avg_symb_time_df = df.groupby('cwe')['symb_time'].mean().reset_index()
    avg_symb_time_df = avg_symb_time_df.sort_values(by='cwe')
    total_avg_symb_time = df['symb_time'].mean()

    avg_total_time_df = df.groupby('cwe')['total_time'].mean().reset_index()
    avg_total_time_df = avg_total_time_df.sort_values(by='cwe')
    total_avg_total_time = df['total_time'].mean()

    return {
        "static_time" : (avg_static_time_df, total_avg_static_time),
        "symb_time" : (avg_symb_time_df, total_avg_symb_time),
        "total_time" : (avg_total_time_df, total_avg_total_time)
    }

def nodemedic(df):
    df = df[df['marker'] != "Timeout"]
    # Ensure total_time is treated as a float (it might be a string initially)
    df['total_time'] = pd.to_numeric(df['total_time'], errors='coerce')

    avg_fuzz_time_df = df.groupby('cwe')['fuzz_time'].mean().reset_index()
    avg_fuzz_time_df = avg_fuzz_time_df.sort_values(by='cwe')
    total_avg_fuzz_time = df['fuzz_time'].mean()

    avg_expl_time_df = df.groupby('cwe')['expl_time'].mean().reset_index()
    avg_expl_time_df = avg_expl_time_df.sort_values(by='cwe')
    total_avg_expl_time = df['expl_time'].mean()

    avg_total_time_df = df.groupby('cwe')['total_time'].mean().reset_index()
    avg_total_time_df = avg_total_time_df.sort_values(by='cwe')
    total_avg_total_time = df['total_time'].mean()

    return {
        "fuzz_time" : (avg_fuzz_time_df, total_avg_fuzz_time),
        "expl_time" : (avg_expl_time_df, total_avg_expl_time),
        "total_time" : (avg_total_time_df, total_avg_total_time)
    }

# FIXME: This was a quick yyp, there's probably a correct way to do this
avg_explode = explode(load_data("explode-vulcan-results.csv"))
avg_static_explode_df, explode_total_static_avg_time = avg_explode["static_time"]
avg_symb_explode_df, explode_total_symb_avg_time = avg_explode["symb_time"]
avg_total_explode_df, explode_total_avg_time = avg_explode["total_time"]

explode_static_cwe_22 = avg_static_explode_df[avg_static_explode_df['cwe'] == 'CWE-22']['static_time'].values[0]
explode_static_cwe_78 = avg_static_explode_df[avg_static_explode_df['cwe'] == 'CWE-78']['static_time'].values[0]
explode_static_cwe_94 = avg_static_explode_df[avg_static_explode_df['cwe'] == 'CWE-94']['static_time'].values[0]
explode_static_cwe_471 = avg_static_explode_df[avg_static_explode_df['cwe'] == 'CWE-471']['static_time'].values[0]
explode_static_cwe_471 += avg_static_explode_df[avg_static_explode_df['cwe'] == 'CWE-1321']['static_time'].values[0]

explode_symb_cwe_22 = avg_symb_explode_df[avg_symb_explode_df['cwe'] == 'CWE-22']['symb_time'].values[0]
explode_symb_cwe_78 = avg_symb_explode_df[avg_symb_explode_df['cwe'] == 'CWE-78']['symb_time'].values[0]
explode_symb_cwe_94 = avg_symb_explode_df[avg_symb_explode_df['cwe'] == 'CWE-94']['symb_time'].values[0]
explode_symb_cwe_471 = avg_symb_explode_df[avg_symb_explode_df['cwe'] == 'CWE-471']['symb_time'].values[0]
explode_symb_cwe_471 += avg_symb_explode_df[avg_symb_explode_df['cwe'] == 'CWE-1321']['symb_time'].values[0]

explode_total_cwe_22 = avg_total_explode_df[avg_total_explode_df['cwe'] == 'CWE-22']['total_time'].values[0]
explode_total_cwe_78 = avg_total_explode_df[avg_total_explode_df['cwe'] == 'CWE-78']['total_time'].values[0]
explode_total_cwe_94 = avg_total_explode_df[avg_total_explode_df['cwe'] == 'CWE-94']['total_time'].values[0]
explode_total_cwe_471 = avg_total_explode_df[avg_total_explode_df['cwe'] == 'CWE-471']['total_time'].values[0]
explode_total_cwe_471 += avg_total_explode_df[avg_total_explode_df['cwe'] == 'CWE-1321']['total_time'].values[0]

avg_fast = fast(load_data("fast-vulcan-secbench-results.csv"))
avg_path_fast_df, fast_total_path_avg_time = avg_fast["path_time"]
avg_expl_fast_df, fast_total_expl_avg_time = avg_fast["expl_time"]
avg_total_fast_df, fast_total_avg_time = avg_fast["total_time"]

fast_path_cwe_22 = avg_path_fast_df[avg_path_fast_df['cwe'] == 'CWE-22']['path_time'].values[0]
fast_path_cwe_78 = avg_path_fast_df[avg_path_fast_df['cwe'] == 'CWE-78']['path_time'].values[0]
fast_path_cwe_94 = avg_path_fast_df[avg_path_fast_df['cwe'] == 'CWE-94']['path_time'].values[0]
fast_path_cwe_471 = avg_path_fast_df[avg_path_fast_df['cwe'] == 'CWE-471']['path_time'].values[0]

fast_expl_cwe_22 = avg_expl_fast_df[avg_expl_fast_df['cwe'] == 'CWE-22']['expl_time'].values[0]
fast_expl_cwe_78 = avg_expl_fast_df[avg_expl_fast_df['cwe'] == 'CWE-78']['expl_time'].values[0]
fast_expl_cwe_94 = avg_expl_fast_df[avg_expl_fast_df['cwe'] == 'CWE-94']['expl_time'].values[0]
fast_expl_cwe_471 = avg_expl_fast_df[avg_expl_fast_df['cwe'] == 'CWE-471']['expl_time'].values[0]

fast_total_cwe_22 = avg_total_fast_df[avg_total_fast_df['cwe'] == 'CWE-22']['total_time'].values[0]
fast_total_cwe_78 = avg_total_fast_df[avg_total_fast_df['cwe'] == 'CWE-78']['total_time'].values[0]
fast_total_cwe_94 = avg_total_fast_df[avg_total_fast_df['cwe'] == 'CWE-94']['total_time'].values[0]
fast_total_cwe_471 = avg_total_fast_df[avg_total_fast_df['cwe'] == 'CWE-471']['total_time'].values[0]

avg_nodemedic = nodemedic(load_data("nodemedic-vulcan-secbench-results.csv"))
avg_fuzz_nodemedic_df, nodemedic_total_fuzz_avg_time = avg_nodemedic["fuzz_time"]
avg_expl_nodemedic_df, nodemedic_total_expl_avg_time = avg_nodemedic["expl_time"]
avg_total_nodemedic_df, nodemedic_total_avg_time = avg_nodemedic["total_time"]

nodemedic_fuzz_cwe_22 = avg_fuzz_nodemedic_df[avg_fuzz_nodemedic_df['cwe'] == 'CWE-22']['fuzz_time'].values[0]
nodemedic_fuzz_cwe_78 = avg_fuzz_nodemedic_df[avg_fuzz_nodemedic_df['cwe'] == 'CWE-78']['fuzz_time'].values[0]
nodemedic_fuzz_cwe_94 = avg_fuzz_nodemedic_df[avg_fuzz_nodemedic_df['cwe'] == 'CWE-94']['fuzz_time'].values[0]
nodemedic_fuzz_cwe_471 = avg_fuzz_nodemedic_df[avg_fuzz_nodemedic_df['cwe'] == 'CWE-471']['fuzz_time'].values[0]

nodemedic_expl_cwe_22 = avg_expl_nodemedic_df[avg_expl_nodemedic_df['cwe'] == 'CWE-22']['expl_time'].values[0]
nodemedic_expl_cwe_78 = avg_expl_nodemedic_df[avg_expl_nodemedic_df['cwe'] == 'CWE-78']['expl_time'].values[0]
nodemedic_expl_cwe_94 = avg_expl_nodemedic_df[avg_expl_nodemedic_df['cwe'] == 'CWE-94']['expl_time'].values[0]
nodemedic_expl_cwe_471 = avg_expl_nodemedic_df[avg_expl_nodemedic_df['cwe'] == 'CWE-471']['expl_time'].values[0]

nodemedic_total_cwe_22 = avg_total_nodemedic_df[avg_total_nodemedic_df['cwe'] == 'CWE-22']['total_time'].values[0]
nodemedic_total_cwe_78 = avg_total_nodemedic_df[avg_total_nodemedic_df['cwe'] == 'CWE-78']['total_time'].values[0]
nodemedic_total_cwe_94 = avg_total_nodemedic_df[avg_total_nodemedic_df['cwe'] == 'CWE-94']['total_time'].values[0]
nodemedic_total_cwe_471 = avg_total_nodemedic_df[avg_total_nodemedic_df['cwe'] == 'CWE-471']['total_time'].values[0]

table_str = Texttable()
table_str.set_cols_align(["c"] + ["r"] * 9)
table_str.add_rows([
    ["CWE"    , "Static"                     , "Symbolic"                 , "Total"               , "Path Gen.", "Expl. Gen.", "FAST", "Fuzz", "Exp. Synth", "NodeMedic"],
    ["CWE-22" , explode_static_cwe_22        , explode_symb_cwe_22        , explode_total_cwe_22  ,
                fast_path_cwe_22             , fast_expl_cwe_22           , fast_total_cwe_22     ,
                nodemedic_fuzz_cwe_22        , nodemedic_expl_cwe_22      , nodemedic_total_cwe_22
    ],
    ["CWE-78" , explode_static_cwe_78        , explode_symb_cwe_78        , explode_total_cwe_78  ,
                fast_path_cwe_78             , fast_expl_cwe_78           , fast_total_cwe_78     ,
                nodemedic_fuzz_cwe_78        , nodemedic_expl_cwe_78      , nodemedic_total_cwe_78
    ],
    ["CWE-94" , explode_static_cwe_94        , explode_symb_cwe_94        , explode_total_cwe_94  ,
                fast_path_cwe_94             , fast_expl_cwe_94           , fast_total_cwe_94     ,
                nodemedic_fuzz_cwe_94        , nodemedic_expl_cwe_94      , nodemedic_total_cwe_94
    ],
    ["CWE-471", explode_static_cwe_471       , explode_symb_cwe_471       , explode_total_cwe_471 ,
                fast_path_cwe_471            , fast_expl_cwe_471          , fast_total_cwe_471,
                nodemedic_fuzz_cwe_471       , nodemedic_expl_cwe_471     , nodemedic_total_cwe_471
    ],
    ["Total"  , explode_total_static_avg_time, explode_total_symb_avg_time, explode_total_avg_time,
                fast_total_path_avg_time     , fast_total_expl_avg_time   , fast_total_avg_time   ,
                nodemedic_total_fuzz_avg_time, nodemedic_total_expl_avg_time, nodemedic_total_avg_time
     ]
])
print(latextable.draw_latex(table_str))
