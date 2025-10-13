from math import log
from tqdm import tqdm
import pandas as pd


class GentModel:
    def __init__(self, starting_dist, F, gamma):
        self.F = F
        self.gamma = gamma
        self.cld = starting_dist
        self.hist = []

    def score_zones(self, zones, F):
        zones = zones.copy()
        score = 1 - 4 * (zones['f'] - F)**2
        zones['R'] = score
        return zones

    def calc_zones_outflow(self, zones, gamma):
        zones = zones.copy()
        P_cl = zones['pop']
        zones[f'outflow'] = gamma * P_cl
        return zones

    def calc_fraction(self, zones):
        zones = zones.copy()
        zones['f'] = zones['pop'] / zones['P_tot']
        return zones

    def step(self):
        next_cld = self.cld.copy()

        self.cld['P_tot'] = self.cld.groupby('geom_id')['pop'].transform('sum')

        for cl in ['L', 'M', 'H']:
            class_mask = self.cld['cl'] == cl
            cld = self.cld.loc[class_mask, :]

            cld = self.calc_fraction(cld)
            cld = self.calc_zones_outflow(cld, self.gamma[cl])
            cld = self.score_zones(cld, self.F[cl])

            cld['inflow'] = 0.0
            for id in cld['geom_id']:
                oc_mask = cld['geom_id'] != id
                outflow = cld[cld['geom_id']
                              == id]['outflow'].iloc[0]
                inflow = outflow * \
                    cld.loc[oc_mask, 'R'] / \
                    cld.loc[oc_mask, 'R'].sum()

                cld.loc[oc_mask, 'inflow'] += inflow

            self.cld = self.cld.reindex(
                columns=self.cld.columns.union(cld.columns)
            )
            self.cld.loc[class_mask] = cld
            next_cld.loc[class_mask, 'pop'] += round(cld['inflow'])

        next_cld['year'] += 1

        self.hist.append(self.cld.copy())
        self.cld = next_cld

    def run(self, n_steps=10, progress=False):
        iter = range(n_steps)
        if progress:
            iter = tqdm(iter)
        for i in iter:
            self.step()
        return self.cld


class SchellingModel(GentModel):
    def score_zones(self, zones: pd.DataFrame, F):
        return zones.assign(R=zones['f'])

class PopWeightedModel(GentModel):
    def score_zones(self, zones: pd.DataFrame, F):
        return zones.assign(R=zones['P_tot'])
