
import requests
import pandas as pd
import sqlalchemy
import os
import csv
import xlwings as xw
import time

# Functions' Definition
def gmsFile(file):
    if os.path.exists(file):
        os.remove(file)

    return file

def series(array):
    return pd.Series(data=array)

def intList(input_list):
    return list(map(int, input_list))


# Classes' Definition
class connectToDB:
    def __init__(self, username, password, database, servername):
        # Database data
        self.database = database
        self.password = password
        self.username = username
        self.servername = servername
        #
        # Create engine
        self.engine = sqlalchemy.create_engine(
            'mssql+pyodbc://' + self.username + ':' + self.password + '@' + self.servername + '/' + self.database + '?driver=SQL+Server&autocommit=true')
        #
        # Connect to engine
        self.connection = self.engine.connect()

start_time = time.time()

# Connect to database
conn = connectToDB(username="pythia_user", password="Dipbsia_01", database="PythiaDB", servername="10.124.21.72")
connEPM = connectToDB(username="heron_analyst", password="Dipbsia_01", database="heron_epm", servername="10.124.21.72")
connect_database_time = time.time()
print("Connect to database: " + str(round(connect_database_time - start_time, 2)) + " sec")

# Sql string
sql = "SELECT * FROM [PythiaDB].[dbo].[ThermalData]"

# Load data
units = pd.read_sql(sql="SELECT entity FROM [PythiaDB].[dbo].[ThermalData]", con=conn.connection)
unitdata = pd.read_sql(sql="SELECT * FROM [PythiaDB].[dbo].[ThermalData]", con=conn.connection)
oil_products = pd.read_sql(sql="SELECT * FROM [heron_epm].[dbo].[oil_products]", con=connEPM.connection)

oil_products_prices = pd.read_sql(sql="SELECT * FROM [heron_epm].[dbo].[oil_products_prices] WHERE TradingDay>'2021-04-01'", con=connEPM.connection)
oil_products = oil_products.rename(columns={"ID": "ProductID"})
oil_products_prices_merged = oil_products_prices.merge(oil_products, how="inner", on="ProductID")
oil_products_prices_merged = oil_products_prices_merged[["Product", "TradingDay", "ClosePrice"]]



#.replace(["-"], "_", regex=True)
#
# if isinstance(units, pd.DataFrame):
#     units = units.values[0]


class gmsAcronym:
    def __init__(self, elements, gms="", write=True):
        self.elements = elements.squeeze().drop_duplicates().str.replace("-", "_")
        self.gms = gms
        self.write = write
        #
        if self.write:
            self.write2gms()

    def write2gms(self):
        # Open file
        file = open(self.gms, "a+")

        # Write acronym elements
        counter = 0
        acronymElements = "Acronyms "
        for e in self.elements:
            counter = counter + 1
            if acronymElements == "Acronyms ":
                prefix = ""
            else:
                prefix = ", "

            if len(acronymElements) + len(prefix) + len(e) > 255:
                file.write(acronymElements + " ;")
                file.write("\n")
                acronymElements = "Acronyms " + e
            else:
                acronymElements = acronymElements + prefix + e

        # Write final acronyms elements and close acronym
        file.write(acronymElements + "; ")
        file.write("\n")
        file.write("\n")

        # Close file
        file.close

        # Return the whole acronym object
        return self

class gmsSet:
    def __init__(self, name, elements, gms="", description="", hyperset="*", replace_spaces=" ", write=True):
        self.name = name
        self.elements = elements.squeeze()
        self.description = description
        self.gms = gms
        self.hyperset = hyperset
        self.replace_spaces = replace_spaces
        self.write = write
        #
        # # Check if elements are a pandas series and replace all elements with their string versions
        # if type(self.elements) == pd.Series:
        #     self.elements = self.elements.apply(str)

        #
        if self.write:
            self.write2gms()
        #
        if self.replace_spaces != " ":
            self.elements = self.elements.str.replace(" ", self.replace_spaces)

    def write2gms(self):
        # Open file
        file = open(self.gms, "a+")

        # Create set description
        set = "Set " + self.name + "(" + self.hyperset + ")          '" + self.description + "'"

        # Write set description
        file.write(set)
        file.write("\n")
        file.write("/")
        file.write("\n")

        # Write set elements
        counter = 0
        setElements = ""
        if isinstance(self.elements, pd.Series):
            for e in self.elements:
                counter = counter + 1
                if counter == 1:
                    prefix = ""
                else:
                    prefix = ", "

                if len(setElements) + len(prefix) + len(e) > 255:
                    file.write(setElements)
                    file.write("\n")
                    setElements = "" + prefix + e
                else:
                    setElements = setElements + prefix + e
        else:
            setElements = self.elements


        # Write final set elements and close set
        file.write(setElements)
        file.write("\n")
        file.write("/ ;")
        file.write("\n")
        file.write("\n")

        # Close file
        file.close

        # Return the whole set object
        return self

class gmsTable:
    def __init__(self, name, vset, hset, values, description, gms, write=True, replace_operators=False):
        self.name = name
        self.vset = vset
        self.hset = hset
        #
        if replace_operators:
            values = values.replace(["-"], "_", regex=True)
        #
        self.values = values.applymap(str)
        self.description = description
        self.gms = gms
        self.write = write
        #
        # Keep only values for non-None elements of the first vset

        #
        if self.write:
            self.write2gms()

    def write2gms(self):
        # Check if the input vset is a list or a simple set and create the initial vertical index and table set names
        if isinstance(self.vset, list):
            vIndex = self.vset[0].elements
            tableSets = self.vset[0].name

            for v in range(len(self.vset)):
                if v > 0:
                    tableSets = tableSets + "," + self.vset[v].name
                    vIndex = vIndex + "." + self.vset[v].elements

            # # Keep first set non-None elements
            # vIndex = vIndex[self.vset[0].elements != 0]
            # self.values = self.values[self.vset[0].elements != 0]

        else:
            vIndex = self.vset.elements
            tableSets = self.vset.name

            # vIndex = self.vset.elements[self.vset.elements != None]
            # self.values = self.values[self.vset.elements != 0]


        # Finalize table set names
        tableSets = tableSets + "," + self.hset.name

        # Set new index and column names
        vIndex = vIndex.values
        hIndex = self.hset.elements.values

        # Pass new index and column names
        self.values.index = vIndex
        self.values.columns = hIndex

        # Print the table
        with pd.option_context('display.max_rows', None, 'display.max_columns', None):
            with open(self.gms, 'a+') as file:
                file.write("Table " + self.name + "(" + tableSets + ")   '" + self.description + "'")
                file.write("\n")
                file.write(self.values.__repr__())
                file.write("\n")
                file.write(";")
                file.write("\n")
                file.write("\n")
                file.close()

        # Return the whole table object
        return self

class gmsParameter:
    def __init__(self, name, set, values, description, gms, write=True):
        self.name = name
        self.set = set
        self.values = values.map(str)
        self.description = description
        self.gms = gms
        self.write = write
        #
        if self.write:
            self.write2gms()

    def write2gms(self):
        # Check if the input set is a list or a simple set and create the initial index and parameter set names
        if isinstance(self.set, list):
            index = self.set[0].elements
            parameterSets = self.set[0].name

            for s in range(len(self.set)):
                if s > 0:
                    parameterSets = parameterSets + "," + self.set[s].name
                    index = index + "." + self.set[s].elements
        else:
            index = self.set.elements
            parameterSets = self.set.name

        # Set new index names
        index = index + " = "
        index = index.values

        # Pass new index and column names
        self.values.index = index

        # Print the parameter
        with pd.option_context('display.max_rows', None, 'display.max_columns', None):
            with open(self.gms, 'a+') as file:
                file.write("Parameter " + self.name + "(" + parameterSets + ")   '" + self.description + "'")
                file.write("\n")
                file.write("/")
                file.write("\n")
                self.values.to_csv(file, sep="\t", line_terminator='\n', header=False)
                file.write("/ ;")
                file.write("\n")
                file.write("\n")
                file.close()

        # Return the whole table object
        return self

class gmsScalar:
    def __init__(self, name, value, description, gms, write=True):
        self.name = name
        self.value = value
        self.description = description
        self.gms = gms
        self.write = write
        #
        if self.write:
            self.write2gms()

    def write2gms(self):
        # Print the scalar
        with open(self.gms, 'a+') as file:
            file.write("Scalar " + self.name + "\t '" + self.description + "'\t / " + str(self.value) + " / ;")
            file.write("\n")
            file.write("\n")
            file.close()

        # Return the whole scalar object
        return self



base_directory = "C://Users//dchatzigiannis.HERON//OneDrive - HERON//Projects//Tools//GMS Classes//Data//"
sets = gmsFile(base_directory + "sets.gms")
tables = gmsFile(base_directory + "data.gms")

# Acronyms
acronym = gmsAcronym(elements=oil_products["ProductType"], gms=sets)
acronym = gmsAcronym(elements=oil_products["ShortName"], gms=sets)

# Scalar
test_scalar = gmsScalar(name="Test", value=5, description="This is a test scalar", gms=sets)

# Sets
g = gmsSet(name="g", elements=units, description="Generating units", gms=sets)
thr = gmsSet(name="g_thr", elements=units, description="Thermal generating units", gms=sets, hyperset="g")
gThrData = gmsSet(name="gThrData", elements=series(["Pmax", "Pmin"]), description="Thermal units data", gms=sets)
timePeriods = gmsSet(name="t", elements=series(["T1", "T2", "T3"]), gms=sets)
product = gmsSet(name="p", elements=oil_products["Product"], description="Oil products", gms=sets)
productdat = gmsSet(name="pdat", elements=series(["ProductType", "ShortName"]), description="Oil products", gms=sets)


dates = gmsSet(name="trd", elements=oil_products_prices_merged["TradingDay"].drop_duplicates(), description="Set of dates", gms=sets)
oil_dates = gmsSet(name=dates.name, elements=oil_products_prices_merged["TradingDay"], write=False)
oil_prod = gmsSet(name=product.name, elements=oil_products_prices_merged["Product"], write=False)

# Tables
data = unitdata.drop(columns=["ID", "entity"])
unitData = gmsTable(name="ThermalData", vset=[thr, timePeriods], hset=gThrData, values=data,
                     description="Table containing the thermal data", gms=sets)

data = oil_products.drop(columns=["ProductID", "Product", "DateFrom", "DateTo"])
productData = gmsTable(name="ProductData", vset=product, hset=productdat, values=data,
                        description="Table containing the oil product data", gms=sets, replace_operators=True)

# oilData = gmsParameter(name="OilData", set=[oil_prod, oil_dates], values=oil_products_prices_merged["ClosePrice"], description="Oil data", gms=sets)


# DAPEEP data
res = pd.read_sql(sql="SELECT * FROM [heron_epm].[dbo].[res_analytical] WHERE TradingDay='2019-12-01'", con=connEPM.connection)


resdates = gmsSet(name='resdates', elements=res["TradingDay"].drop_duplicates(), description="RES dates", gms=sets)
tech = gmsSet(name='tech', elements=res["Technology"].drop_duplicates(), description="RES technology", replace_spaces="_", gms=sets)
losszone = gmsSet(name='lz', elements=res["LossZone"].drop_duplicates(), description="Loss zones", gms=sets)

periods = []
for t in range(24):
    periods.append("T" + str(t+1))
res_print = res[periods]

print_database_gms_time = time.time()
print("Print database data: " + str(round(print_database_gms_time - connect_database_time, 2)) + " sec")


### LOAD ATLAS RESULTS ###
# app = xw.App(visible=False)
atlas = xw.Book("ATLAS_HERON_v2.5_20210629.xlsb")

block_titles = ["B1", "B2", "B3", "B4", "B5", "B6", "B7", "B8", "B9", "B10"]
blocks = gmsSet(name="b", elements=series(["B1", "B2", "B3", "B4", "B5", "B6", "B7", "B8", "B9", "B10"]), description="Set of blocks", gms=sets)

for entity in ["THR", "HDR", "RES", "DEM"]:
    entities = pd.Series(data=atlas.names("ISP_" + entity + "_ENTITIES").refers_to_range.value)
    periods = pd.Series(data=atlas.names("ISP_" + entity + "_SCHEDULING_PERIODS").refers_to_range.value).fillna(0).astype(int).astype(str)

    # Create sets
    entities_set = gmsSet(name=entity + "_anc_set", elements=entities, write=False)
    periods_set = gmsSet(name=entity + "_periods_anc_set", elements=periods, write=False)


    for direction in ["up", "dn"]:
        quantities = pd.DataFrame(columns=blocks.elements.values)
        prices = pd.DataFrame(columns=blocks.elements.values)
        for b in range(10):
            quantities["B" + str(b+1)] = atlas.names("ISP_" + entity + "_BE" + direction + "_MAX_QUANTITY_" + str(b+1)).refers_to_range.value
            prices["B" + str(b + 1)] = atlas.names("ISP_" + entity + "_BE" + direction + "_PRICE_" + str(b + 1)).refers_to_range.value
        quantities = quantities.fillna(0)
        prices = prices.fillna(0)

        # Print tables
        quantities_table = gmsTable(name=entity + "quantities", vset=[entities_set, periods_set], hset=blocks, values=quantities, description="Quantities for entity " + entity, gms=sets)
        prices_table = gmsTable(name=entity + "prices", vset=[entities_set, periods_set], hset=blocks, values=prices, description="Prices for entity " + entity, gms=sets)


# Reserves
for entity in ["HDR", "HDR", "RES", "DEM"]:
    entities = pd.Series(data=atlas.names("ISP_" + entity + "_ENTITIES").refers_to_range.value[:960])
    periods = pd.Series(data=atlas.names("ISP_" + entity + "_SCHEDULING_PERIODS").refers_to_range.value[:960]).fillna(0).astype(int).astype(str)

    # Create sets
    entities_set = gmsSet(name=entity + "_anc_set", elements=entities, write=False)
    periods_set = gmsSet(name=entity + "_periods_anc_set", elements=periods, write=False)

    for res in ["FCR", "aFRR", "mFRR", "RR"]:
        for direction in ["up", "dn"]:
            print(entity + " -- " + res + " -- " + direction)
            quantities = pd.DataFrame(columns=blocks.elements.values)
            prices = pd.DataFrame(columns=blocks.elements.values)
            for b in range(10):
                quantities["B" + str(b+1)] = atlas.names("ISP_" + entity + "_" + res + direction + "_BLOCK_" + str(b+1)).refers_to_range.value[:960]
                prices["B" + str(b + 1)] = atlas.names("ISP_" + entity + "_" + res + direction + "_PRICE_" + str(b + 1)).refers_to_range.value[:960]
            quantities = quantities.fillna(0)
            prices = prices.fillna(0)

            # Print tables
            quantities_table = gmsTable(name=entity + "quantities" + res + direction, vset=[entities_set, periods_set], hset=blocks, values=quantities, description="Quantities for entity " + entity, gms=sets)
            prices_table = gmsTable(name=entity + "prices" + res + direction, vset=[entities_set, periods_set], hset=blocks, values=prices, description="Prices for entity " + entity, gms=sets)



# atlas.close()

load_atlas_time = time.time()
print("Load ATLAS data: " + str(round(load_atlas_time - print_database_gms_time, 2)) + " sec")
