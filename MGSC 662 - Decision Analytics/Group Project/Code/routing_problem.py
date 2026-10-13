#%%
import gurobi as gp
import openpyxl
import os 
import pandas as pd
import numpy as np
import plotly.express as px
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler

#%% Import Data
w_cb = openpyxl.load_workbook(os.path.realpath(os.path.join('__file__',"..","Data","data_updated.xlsx")))

# Sets
ws_sets = w_cb['Sets']
W = [i+1 for i in range(ws_sets['A2'].value)]

# Clusters
clusters_to_check = 0
to_break = False

# Wind Farm Data
ws_wf = w_cb['WindFarm']
wb = {w: ws_wf[f"F{w+1}"].value/20 for w in W }
wx = {w: ws_wf[f"N{w+1}"].value*111 for w in W }
wy = {w: ws_wf[f"O{w+1}"].value*111 for w in W }

# Misc Data
dco = 29.5
tco = 1000000
tca = 300
ph = 50
dk = 111

#%% Clustering
while not to_break:
    to_break = True

    print(f"\tCluster Amount: {clusters_to_check +1}")
    C = [i for i in range(clusters_to_check +1)]

    # Scaling
    scaler = StandardScaler()
    w_dat = pd.DataFrame([wx, wy, wb]).T.rename(columns={0:'X', 1:'Y', 2:'blade_waste'})
    w_loc_tf = pd.DataFrame(scaler.fit_transform(w_dat),columns=w_dat.columns)

    # Clustering
    clusterer = KMeans(n_clusters=len(C))
    w_loc_label = clusterer.fit_predict(w_loc_tf[['X','Y']])
    w_dat['cluster'] = w_loc_label

    # Modelling
    cluster_travel_cost = []
    cluster_fixed_cost = len(C) * tca
    cluster_travel = []
    cluster_req_cap = []
    cluster_req_met = []

    for c in C:

        # Split Data into Clusters
        w_cdat = w_dat.query(f"cluster == {c}")
        w_cx = w_cdat.to_dict()['X']
        w_cy = w_cdat.to_dict()['Y']
        w_cb = w_cdat.to_dict()['blade_waste']
        Wc = list(w_cx.keys())


        # Generate Distance
        wdi = {}
        for w1 in Wc:
            for w2 in Wc:
                wdi[w1,w2] = np.abs(w_cx[w1] - w_cx[w2]) + np.abs(w_cy[w1] - w_cy[w2])


        # Model
        model = gp.Model('model')
        model.Params.LogToConsole = 0
        model.Params.TimeLimit = 600
        model.Params.MIPGap = 0.05

        # Decision Vars
        vt = model.addVars(Wc,Wc, vtype=gp.GRB.BINARY, name='var_travel_from_to')
        vu = model.addVars(Wc, vtype=gp.GRB.INTEGER, name='var_MTZ_form')

        # Basic Constraints
        c_en = model.addConstrs((gp.quicksum(vt[w1,w2] for w1 in Wc) == 1 for w2 in Wc), name='con_enter_once')
        c_ex = model.addConstrs((gp.quicksum(vt[w1,w2] for w2 in Wc) == 1 for w1 in Wc), name='con_exit_once')
        c_es = model.addConstrs((vt[w1,w1] == 0 for w1 in Wc), name='con_enter_self')

        # Miller-Tucker-Zemlin reformulation
        c_mtz_1 = model.addConstrs((vu[s1] - vu[s2] + len(Wc)*vt[s1,s2]
                                    <= len(Wc)-1
                                    for s1 in Wc[1:] for s2 in Wc[1:] if s1 != s2),
                                name='con_MTZ_1')
        c_mtz_2 = model.addConstrs((vu[s1] >= 1 for s1 in Wc[1:]), name='con_MTZ_2')
        c_mtz_3 = model.addConstrs((vu[s1] <= len(Wc)-1 for s1 in Wc[1:]), name='con_MTZ_3')

        # Objective
        tot_dist = gp.quicksum(wdi[(w1,w2)] for w1 in Wc for w2 in Wc)
        tot_cost = gp.quicksum(wdi[(w1,w2)]
                            * 50 * 29.5 * vt[(w1,w2)] 
                            / 1000000
                            for w1 in Wc for w2 in Wc)

        model.setObjective(tot_dist, sense=gp.GRB.MINIMIZE)
        model.optimize()


        # Summary Stats for Cluster
        cluster_travel_cost.append(round(tot_cost.getValue()*1000000,2))
        cluster_travel.append(round(tot_dist.getValue(),2))
        cluster_req_cap.append(round(sum(w_cb.values()),2))
        if 300 > sum(w_cb.values()): cluster_req_met.append(True)
        else: 
            cluster_req_met.append(False)
            clusters_to_check += 1
            to_break = False

    print(f"Clustering Travel Cost: ${sum(cluster_travel_cost):,.2f}")
    print(f"Clustering Fixed Cost: ${cluster_fixed_cost:,.2f}")
    print(f"Clustering Total Cost: ${sum(cluster_travel_cost)+cluster_fixed_cost:,.2f}")
    print(f"Clustering Total Travel (km): {cluster_travel}")
    print(f"Cluster Requirements (blades): {cluster_req_cap}")
    print(f"Cluster Requirements Met: {cluster_req_met}")
    print()

# %%
