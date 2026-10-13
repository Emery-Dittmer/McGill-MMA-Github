# -*- coding: utf-8 -*-
"""
Created on Thu Dec  1 17:27:42 2022

@author: raymo
"""


import plotly.express as px
import pandas as pd
import kaleido

total_loc = pd.read_csv(r"C:\Users\raymo\Documents\Education\McGill\McGill Masters\2-Semseter F22\MGSC 662\Group Assignment\McGill-MGSC-662-DecisionSup-Project-main\Data\loactions.csv")

total_loc=total_loc[total_loc.type == "wind_farm"]

fig = px.scatter_geo(total_loc,
                     color='type',
                     lat=total_loc['X'],
                     lon=total_loc['Y'],
                     hover_name="type")
fig.update_geos(
visible=False, resolution=50, scope="north america",
showcountries=True, countrycolor="Black",
showsubunits=True, subunitcolor="grey")
fig.show()
fig.show(renderer='browser')     
import os 
if not os.path.exists("images"): 
    os.mkdir("images")
    
fig.write_image("C:/Users/raymo/Documents/fig1.jpeg")