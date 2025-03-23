import json
import pandas as pd

def load_json(filename):
    with open(filename, 'r') as fd:
        return json.load(fd)

def load_data(filename, sep=','):
    return pd.read_csv(filename, sep=sep)

def recall(tp, fn):
    dem = tp + fn
    return 0 if dem == 0 else tp / dem

def er(e, tp, fp, fn):
    dem = tp + fp + fn
    return 0 if dem == 0 else e / dem
