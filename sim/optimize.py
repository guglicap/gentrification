import multiprocessing
from tqdm import tqdm
import pandas as pd
import numpy as np
from model import *
from scipy.optimize import differential_evolution

F = {
    'L': 0.5,
    'M': 0.4,
    'H': 0.1
}


def cost_function(target, model, cost_classes=['L', 'M', 'H'], cost_columns=['pop']):
    merged = target.merge(
        model, on=["geom_id", "cl"], suffixes=("_target", "_model"))
    merged = merged.loc[merged['cl'].isin(cost_classes), :]

    def sqdiff(column):
        return (merged[f'{column}_model'] - merged[f'{column}_target'])**2
    merged['sqdiff'] = sum([sqdiff(col) for col in cost_columns])
    return merged['sqdiff'].sum()


def obj_function(params):
    cld = pd.read_csv("export/sim/class_distribution_MILANO_2011.csv")
    model = PopWeightedModel(cld, F, {
        'L': params[0],
        'M': params[1],
        'H': params[2]
    })
    model_res = model.run()

    target = pd.read_csv("export/sim/class_distribution_MILANO_2021.csv")
    return cost_function(target, model_res)


if __name__ == "__main__":

    bounds = [
        (1e-4, 0.1),
        (1e-4, 0.1),
        (1e-4, 0.1)
    ]

    result = differential_evolution(
        obj_function,
        bounds,
        workers=multiprocessing.cpu_count(),
        updating="deferred",
        maxiter=100,
        disp=True
    )
    print(f"optimization ended, final cost = {result.fun}")

    optimal_params = result.x
    print(f"found gamma: {optimal_params}")
