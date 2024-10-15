import pandas as pd

def load_data(filename):
    return pd.read_csv(filename)

def recall(tp, fn):
    dem = tp + fn
    return 0 if dem == 0 else tp / dem

def er(e, tp, fp, fn):
    dem = tp + fp + fn
    return 0 if dem == 0 else e / dem
