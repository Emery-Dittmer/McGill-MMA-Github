#%%
import gurobipy as gp
import openpyxl
import os 
import pandas as pd
import numpy as np
import plotly.express as px


#%% Import Data
wb = openpyxl.load_workbook(os.path.realpath(os.path.join('__file__',"..","..",'Data',"data_updated.xlsx")))

# Sets
ws_sets = wb['Sets']
W = [i+1 for i in range(ws_sets['A2'].value)]
T = [i+1 for i in range(ws_sets['B2'].value)]
F = [i+1 for i in range(ws_sets['C2'].value)]

# Wind Farm Data
ws_wf = wb['WindFarm']
wx = {w: ws_wf[f"N{w+1}"].value for w in W }
wy = {w: ws_wf[f"O{w+1}"].value for w in W }
wd = {w: ws_wf[f"J{w+1}"].value for w in W }
ww = {w: ws_wf[f"L{w+1}"].value for w in W }
wt = {w: ws_wf[f"K{w+1}"].value for w in W }

# Facility Data
ws_f = wb['FacilityData']
co = {t: ws_f[f"C{t+1}"].value for t in T}
ca = {t: ws_f[f"B{t+1}"].value for t in T}

# Misc Data
dc = 29.5
ph = 50
dk = 111

# Bounds
x_min = np.floor(np.min(np.array(list(wx.values()))))
x_max = np.ceil(np.max(np.array(list(wx.values()))))
x_diff = x_max - x_min

y_min = np.floor(np.min(np.array(list(wy.values()))))
y_max = np.ceil(np.max(np.array(list(wy.values()))))
y_diff = y_max - y_min
ds_diff = x_diff + y_diff

d_min = np.floor(np.min(np.array(list(wd.values()))))
d_max = np.ceil(np.max(np.array(list(wd.values()))))
d_mean = np.mean(np.array(list(wd.values())))
d_diff = d_max - d_min

wb.close()


#%% Model
model = gp.Model('model')
model.Params.Heuristics = 0.001
model.Params.CutPasses = 3
model.Params.PreDepRow = 0
model.Params.PreQLinearize = 1

model.Params.TimeLimit = 60*1
model.Params.MIPGap = 0.01


# Decision Vars
fb = model.addVars(F,T, vtype=gp.GRB.BINARY, name='var_build_facility_FT')
fx = model.addVars(F,T, ub=x_max,lb=x_min, name='var_facility_lat_FT')
fy = model.addVars(F,T, ub=y_max,lb=y_min, name='var_facility_lon_FT')

dist_x = model.addVars(W,F,T, ub=ds_diff,lb=-ds_diff, name='var_facility_distx_WFT')
dist_y = model.addVars(W,F,T, ub=ds_diff,lb=-ds_diff, name='var_facility_disty_WFT')
dist = model.addVars(W,F,T, ub=ds_diff,lb=-ds_diff, name='var_facility_dist_WFT')
wa = model.addVars(W,F,T, vtype=gp.GRB.BINARY, name='var_wind_farm_assignment')


# Demand
c_d = model.addConstrs((gp.quicksum(wa[(w,f,t)] for t in T for f in F) == 1 for w in W), name = 'con_demand')


# Capacity
c_c = model.addConstrs((gp.quicksum(wa[(w,f,t)] * ww[w] * wd[w] for w in W)
                        <= ca[t] * fb[(f,t)] for f in F for t in T),
                        name = 'con_capacity')


# # Distance Constraints (Manhattan)
c_dx_1 = model.addConstrs((dist_x[(w,f,t)] >= fx[(f,t)] - wx[w] for w in W for f in F for t in T), name='con_dist_x1')
c_dx_2 = model.addConstrs((dist_x[(w,f,t)] >= -(fx[(f,t)] - wx[w]) for w in W for f in F for t in T), name='con_dist_x2')
c_dy_1 = model.addConstrs((dist_y[(w,f,t)] >= fy[(f,t)] - wy[w] for w in W for f in F for t in T), name='con_dist_y1')
c_dx_2 = model.addConstrs((dist_y[(w,f,t)] >= -(fy[(f,t)] - wy[w]) for w in W for f in F for t in T), name='con_dist_y2')
c_dist = model.addConstrs((dist[(w,f,t)] == dist_x[(w,f,t)] + dist_y[(w,f,t)] for w in W for f in F for t in T), name='con_dist')


# Objective Equations
del_cost = gp.quicksum(dist[(w,f,t)] * wa[(w,f,t)] * wd[w] * dc * dk * 50 / 1000000 for w in W for f in F for t in T)
build_cost = gp.quicksum(co[t] * fb[(f,t)] / 1000000 for f in F for t in T)

#%% Optimize based on Relaxation
model.setObjective( del_cost + build_cost, sense=gp.GRB.MINIMIZE )
model.optimize()

print(f"Cost of delivery over 50 years: ${del_cost.getValue()*1000000:,.2f}")
print(f"Cost of building facilities: ${build_cost.getValue()*1000000:,.2f}")

# Fix Variables
for var in fb:
    fb[var].ub = fb[var].X
    fb[var].lb = fb[var].X

for var in fx:
    fx[var].ub = fx[var].X
    fx[var].lb = fx[var].X

for var in fy:
    fy[var].ub = fy[var].X
    fy[var].lb = fy[var].X

for var in dist:
    dist[var].ub = dist[var].X
    dist[var].lb = dist[var].X


#%% Optimize based on More Detailed Option
# Remove Extras
model.remove(wa)
model.remove(c_d)
model.remove(c_c)

# Add Additional
model.Params.NonConvex = 2
model.Params.MIPGap = 0.0001
dw = model.addVars(W,F,T, vtype=gp.GRB.INTEGER, ub=d_max, name='var_deliver_waste_WFT')
c_d = model.addConstrs((gp.quicksum(dw[(w,f,t)] for t in T for f in F) == wd[w] for w in W), name = 'con_demand')
c_c = model.addConstrs((gp.quicksum(dw[(w,f,t)] * ww[w] for w in W)
                        <= ca[t] * fb[(f,t)] for f in F for t in T),
                        name = 'con_capacity')
del_cost = gp.quicksum(dist[(w,f,t)] * dw[(w,f,t)] * dc * dk * 50 / 1000000 for w in W for f in F for t in T)

model.setObjective( del_cost + build_cost, sense=gp.GRB.MINIMIZE )
model.optimize()

print(f"Cost of delivery over 50 years: ${del_cost.getValue()*1000000:,.2f}")
print(f"Cost of building facilities: ${build_cost.getValue()*1000000:,.2f}")

#%% Visualize
loc_data = pd.DataFrame([wx.values()]+[wy.values()]).T.rename(columns={0:"X",1:"Y"})
loc_data['type'] = 'wind_farm'


for f in F:
    for t in T:
        if fb[(f,t)].X >= 0.01:
            loc_data = pd.concat([loc_data,
                                  pd.DataFrame([fx[(f,t)].X, fy[(f,t)].X, f"Facility {t}"],index=['X',"Y",'type']).T])

# fig = px.scatter(loc_data, x="X",y="Y",color='type')
# fig.show(renderer='browser')                             

#%%
fig = px.scatter_geo(loc_data,
                     color='type',
                     lat='Y',
                     lon='X',
                     hover_name="type")
fig.update_geos(
visible=False, resolution=50, scope="north america",
showcountries=True, countrycolor="Black",
showsubunits=True, subunitcolor="grey")

fig.show(renderer='browser')     

loc_data.to_csv(os.path.realpath(os.path.join(__file__,"..","..","Data","loactions_ontario.csv")))                  


# %%
# loc_data = pd.DataFrame([wx.values()]
#                         +[wy.values()]
#                         +[wd.values()]
#                         +[ww.values()]).T.rename(columns={0:"X",
#                                                           1:"Y",
#                                                           2:"deliveries",
#                                                           3:"waste_per"})
# loc_data['waste'] = loc_data['deliveries'] * loc_data['waste_per']
# loc_data['type'] = 'wind_farm'

# fig = px.scatter_3d(loc_data, x='X',y='Y',z='waste')
# fig.show(renderer='browser')
# %%