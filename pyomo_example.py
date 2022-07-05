from pyomo.environ import *
import pandas as pd

"""
FUNCTIONS
"""
def load_csv(filepath, fill_empty_values=True):
    output_dataframe = pd.read_csv(filepath)
    if fill_empty_values:
        output_dataframe = output_dataframe.fillna(0)
    
    return output_dataframe


def check_list(input_data):
    output_list = []
    if not isinstance(input_data, list):
        output_list.append(input_data)
    else:
        output_list = input_data

    return output_list


def parameter(df, vindex, hindex):
    # Check the type of the indices
    vindex = check_list(vindex)
    hindex = check_list(hindex)

    # Initialize data
    output_table = dict()
    key = set()
        
    # Pass data to dictionary
    for r in range(len(df)):
        for h in hindex:
            key_list = []
            for v in vindex:
                key_list.append(df.at[r, v])
                
            # Add hindex value only if there exist more than one indices
            if len(hindex) > 1:
                key_list.append(h)

            # Get dictionary key
            key = tuple(key_list) if len(key_list) > 1 else key_list[0]

            # Get dictionary value
            value = df.at[r, h]

            # Pass key and value to dictionary
            output_table[key] = value

    return output_table

"""
LOAD DATA
"""
thermal_units_data = load_csv("C://Root//Projects//Heron//Pyomo Examples//Data//thermal.csv")
thermal_offers_data = load_csv("C://Root//Projects//Heron//Pyomo Examples//Data//thermal_offers.csv")

# Create sets
G = set(thermal_units_data["entity_name"])
T = {f"T{i}" for i in range(1,25)}
B = {f"B{i}" for i in range(1,11)}

# Create parameters
Pmax = parameter(thermal_units_data, "entity_name", "net_pmax")
Pmin = parameter(thermal_units_data, "entity_name", "net_pmin")

price_data = thermal_offers_data[["thermal_entities", "trading_period", "price1", "price2", "price3", "price4", "price5", "price6", "price7", "price8", "price9", "price10"]]
quantity_data = thermal_offers_data[["thermal_entities", "trading_period", "block1", "block2", "block3", "block4", "block5", "block6", "block7", "block8", "block9", "block10"]]

price_data.columns = ["thermal_entities", "trading_period", "B1", "B2", "B3", "B4", "B5", "B6", "B7", "B8", "B9", "B10"]
quantity_data.columns = ["thermal_entities", "trading_period", "B1", "B2", "B3", "B4", "B5", "B6", "B7", "B8", "B9", "B10"]

Qg = parameter(df=price_data, vindex=["thermal_entities", "trading_period"], hindex=["B1", "B2", "B3", "B4", "B5", "B6", "B7", "B8", "B9", "B10"])
Pg = parameter(df=quantity_data, vindex=["thermal_entities", "trading_period"], hindex=["B1", "B2", "B3", "B4", "B5", "B6", "B7", "B8", "B9", "B10"])

load = {"T1": 2558,
        "T2": 2382,
        "T3": 2324,
        "T4": 2197,
        "T5": 2087, 
        "T6": 2041,
        "T7": 2067,
        "T8": 2089,
        "T9": 2188,
        "T10": 2438, 
        "T11": 2732, 
        "T12": 2967, 
        "T13": 3014, 
        "T14": 2892, 
        "T15": 2659, 
        "T16": 2610, 
        "T17": 2637, 
        "T18": 2675, 
        "T19": 2885, 
        "T20": 2921,
        "T21": 2884,
        "T22": 2798,
        "T23": 2628,
        "T24": 252
}

"""
MODEL
"""
# Model
model = ConcreteModel(name="UC")

# Variables
model.q = Var(G, T, B, bounds=(0,1))
model.p = Var(G, T)
model.u = Var(G, T, within=Binary)
model.a = Var(T, within=NonNegativeReals)


# Equations
def obj_rule(model):
    return sum(Pg[g,t,b] * Qg[g,t,b] * model.q[g,t,b] for g in G for t in T for b in B) + sum (50000 * model.a[t] for t in T)
model.obj = Objective(rule=obj_rule, sense=minimize)

def power_balance(model, t):
    return sum(Qg[g,t,b] * model.q[g,t,b] for g in G for b in B) + model.a[t] == load[t]
model.power_balance = Constraint(T, rule=power_balance)

def cleared_quantity(model, g, t):
    return sum(model.q[g,t,b] for b in B) == model.p[g,t]
model.cleared_quantity = Constraint(G, T, rule=cleared_quantity)

def minimum_output(model, g, t):
    return model.p[g,t] >= 0
model.minimum_output = Constraint(G, T, rule=minimum_output)

def maximum_output(model, g, t):
    return model.p[g,t] <= Pmax[g]
model.maximum_output = Constraint(G, T, rule=maximum_output)

def minimum_cleared(model, g, t, b):
    return model.q[g,t,b] >= 0
model.minimum_cleared = Constraint(G, T, B, rule=minimum_cleared)

def maximum_cleared(model, g, t, b):
    return model.q[g,t,b] <= 1
model.maximum_cleared = Constraint(G, T, B, rule=maximum_cleared)

######################
# MODEL EXECUTION ####
######################

# Set solver
solver = SolverFactory("cplex")
solver.options[""]

# Solve model
solver.solve(model, tee=True)

# Print model output
# model.pprint()

artificial = []
for key in model.a.keys():
    artificial.append([key, value(model.a[key])])
a = pd.DataFrame(data=artificial, columns=["trading_period", "slack"])

power_output_data = []
for key in model.p.keys():
    power_output_data.append([key[0], key[1], value(model.p[key])])
power_output = pd.DataFrame(data=power_output_data, columns=["thermal_entity", "trading_period", "power_output"])

 
