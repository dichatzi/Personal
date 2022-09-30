from flask import Flask, request, Response
from flask_restful import Resource, Api, reqparse
import sys
import subprocess
import datetime
import numpy as np
import pandas as pd
import importlib
import sqlalchemy
import json
from vm_classes import *
from vm_external import *
import time

def addParameters(params):
    parser = reqparse.RequestParser()
    for p in params:
        parser.add_argument(p)

    return parser.parse_args()

class JsonObj:
    def __init__(self):
        self.obj = "{"

    def addValues(self, name, value, string=False):
        # Check if value is None and replace value with the string "Null", else process value
        if value is None:
            value = '"Null"'
        else:
            value = value if not string else '"' + str(value) + '"'

        delimeter = ", " if len(self.obj) > 1 else ""
        self.obj = self.obj + delimeter + '"' + str(name) + '": ' + str(value)

    def end(self):
        self.obj = self.obj + "}"
        return self.obj



app = Flask(__name__)
api = Api(app)

fileDir = dict()
fileDir["KEBE"] = "E://Scripts//Python//Shift//Dnld_KEBE"
fileDir["OPSFA"] = "E://Scripts//Python//Shift//Download_Opsfa_Files"



class ExecutePythonScripts(Resource):
    def get(self, name):

        if name == "KEBE":
            sys.path.append(fileDir[name])
            import Dnld_KEBE
            return "KEBE files have been successfully downloaded!"

        if name == "OPSFA":
            sys.path.append(fileDir[name])
            import download_opsfa_files_v2
            return "Opsfa files have been successfully downloaded"

class RunPython(Resource):
    def get(self):
        sys.path.append("E://Scripts//Python//Shift//Download_Opsfa_Files")

        return "Operation Completed!"
        # module = importlib.import_module("E://Scripts//Python//Shift//Download_Opsfa_Files//download_opsfa_files_v2.py", package=None)



        # return {'about': 'Hello World!'}

    def post(self):
        some_json = request.get_json()
        return {'you sent': some_json}, 201

class Multi(Resource):
    def get(self, num):
        return {'result': num * 10}


""" ===============================================================================================
 GENERAL DATA =====================================================================================
"""
# Power Plant HERON I Availability and Temperature (GET)
class powerPlantAvailabilityHeronI(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["dispatchDate"])
        dispatchDate = args["dispatchDate"]

        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM [heron_epm].[market_data].[heron_i_availability] WHERE dispatchDate='" + str(dispatchDate) + "'"
        data = pd.read_sql(sql_query, con=conn)
        data = data.fillna(50)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("dispatchDate", data["dispatchDate"].iloc[r], True)
            Json.addValues("dispatchPeriod", data["dispatchPeriod"].iloc[r])
            Json.addValues("temperature", data["temperature"].iloc[r])
            Json.addValues("declaredNetPmax1", data["declaredNetPmax1"].iloc[r])
            Json.addValues("declaredNetPmax2", data["declaredNetPmax2"].iloc[r])
            Json.addValues("declaredNetPmax3", data["declaredNetPmax3"].iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))
        #
        # Return JSON array
        return jsonData

# Power Plant HERON II Availability and Temperature (GET)
class powerPlantAvailabilityHeronII(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["dispatchDate"])
        dispatchDate = args["dispatchDate"]

        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM [heron_epm].[market_data].[heron_ii_availability] WHERE dispatchDate='" + str(dispatchDate) + "'"
        data = pd.read_sql(sql_query, con=conn)
        data = data.fillna(422)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("dispatchDate", data["dispatchDate"].iloc[r], True)
            Json.addValues("dispatchPeriod", data["dispatchPeriod"].iloc[r])
            Json.addValues("temperature", data["temperature"].iloc[r])
            Json.addValues("declaredNetPmax", data["declaredNetPmax"].iloc[r])
            Json.addValues("degradedNetPmax", data["degradedNetPmax"].iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))
        #
        # Return JSON array
        return jsonData

# ISP Balancing Energy Orders (GET, POST)
class ispBalancingEnergyOrders(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["dispatchDate", "unit"])
        dispatchDate = args["dispatchDate"]
        unit = args["unit"]
        #
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM [heron_epm].[market_data].[isp_balancing_energy_offers] WHERE dispatchDate='" + str(dispatchDate) + "' AND unit='" + str(unit) + "'"
        print(sql_query)
        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("dispatchDate", data["dispatchDate"].iloc[r], True)
            Json.addValues("unit", data["unit"].iloc[r], True)
            Json.addValues("direction", data["direction"].iloc[r], True)
            Json.addValues("halfHour", data["halfHour"].iloc[r])
            Json.addValues("step", data["step"].iloc[r])
            Json.addValues("minQuantity", data["minQuantity"].iloc[r])
            Json.addValues("maxQuantity", data["maxQuantity"].iloc[r])
            Json.addValues("price", data["price"].iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))
        #
        # Return JSON array
        return jsonData

    def post(self):
        # Get parameters
        dispatchDate = request.args.get("dispatchDate")
        units = request.args.get("units")

        # Initialize parameters
        units = units.split(",")
        examinedUnits = "("
        for unit in units:
            examinedUnits = examinedUnits + "'" + unit + "',"
        examinedUnits = examinedUnits[:-1] + ")"

        # Get json file
        json_file = request.json
        order = pd.DataFrame(data=json.loads(json_file))
        order.columns = ["unit", "direction", "halfHour", "step", "minQuantity", "maxQuantity", "price"]
        order.insert(0, "dispatchDate", dispatchDate)

        # Connect to database
        connection = ConnectToDatabase(username="heron_analyst", password="Dipbsia_01", servername="10.124.21.72", database="heron_epm").engine.connect()

        # Delete previous orders
        sqlstring = "DELETE FROM market_data.isp_balancing_energy_offers WHERE dispatchDate='" + dispatchDate + "' AND unit in " + examinedUnits
        connection.execute(sqlstring)

        # Pass new data to database
        mergeTable(dataframe=order, connection=connection, table="market_data.isp_balancing_energy_offers", onFields=["dispatchDate", "unit", "direction", "halfHour", "step"], updFields=["minQuantity", "maxQuantity", "price"])

        return 200

# ISP Reserve Orders (GET, POST)
class ispReserveOrders(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["dispatchDate", "unit"])
        dispatchDate = args["dispatchDate"]
        unit = args["unit"]
        #
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM [heron_epm].[market_data].[isp_reserve_offers] WHERE dispatchDate='" + str(dispatchDate) + "' AND unit='" + unit + "'"
        print(sql_query)
        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("dispatchDate", data["dispatchDate"].iloc[r], True)
            Json.addValues("unit", data["unit"].iloc[r], True)
            Json.addValues("direction", data["direction"].iloc[r], True)
            Json.addValues("reserveType", data["reserveType"].iloc[r], True)
            Json.addValues("halfHour", data["halfHour"].iloc[r])
            Json.addValues("step", data["step"].iloc[r])
            Json.addValues("minQuantity", data["minQuantity"].iloc[r])
            Json.addValues("maxQuantity", data["maxQuantity"].iloc[r])
            Json.addValues("price", data["price"].iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))
        #
        # Return JSON array
        return jsonData

    def post(self):
        # Get parameters
        dispatchDate = request.args.get("dispatchDate")
        reserveType = request.args.get("reserveType")
        units = request.args.get("units")

        # Initialize parameters
        units = units.split(",")
        examinedUnits = "("
        for unit in units:
            examinedUnits = examinedUnits + "'" + unit + "',"
        examinedUnits = examinedUnits[:-1] + ")"

        # Get json file
        json_file = request.json
        order = pd.DataFrame(data=json.loads(json_file))
        order.columns = ["unit", "direction", "halfHour", "step", "minQuantity", "maxQuantity", "price"]
        order.insert(0, "dispatchDate", dispatchDate)
        order.insert(2, "reserveType", reserveType)

        # Connect to database
        connection = ConnectToDatabase(username="heron_analyst", password="Dipbsia_01", servername="10.124.21.72", database="heron_epm").engine.connect()

        # Delete previous orders
        sqlstring = "DELETE FROM market_data.isp_reserve_offers WHERE dispatchDate='" + dispatchDate + "' AND reserveType='" + reserveType + "' AND unit in " + examinedUnits
        connection.execute(sqlstring)

        # Pass new data to database
        mergeTable(dataframe=order, connection=connection, table="market_data.isp_reserve_offers", onFields=["dispatchDate", "unit", "reserveType", "direction", "halfHour", "step"], updFields=["minQuantity", "maxQuantity", "price"])

        return 200





# Imbalance Statement (POST)
class imbalStatement(Resource):
    def post(self):
        json_file = request.json
        #
        data = imbStatementEnergyPrices(json_file=json_file)
        data.engine = engine
        data.pass_to_db()

        return 200

# HENEX Trades (GET)
class henexTrades(Resource):
    def get(self, date):
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM henex_api_trades WHERE LEFT(deliveryStartDT,10)='" + str(date) + "'"
        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("targetMarket", data["targetMarket"].iloc[r], True)
            Json.addValues("participantId", data["participantId"].iloc[r], True)
            Json.addValues("assetId", data["assetId"].iloc[r], True)
            Json.addValues("orderType", data["orderType"].iloc[r], True)
            Json.addValues("side", data["side"].iloc[r], True)
            Json.addValues("deliveryStartDT", data["deliveryStartDT"].iloc[r], True)
            Json.addValues("price", data["price"].iloc[r])
            Json.addValues("volume", data["volume"].iloc[r])
            Json.addValues("tradeValue", data["tradeValue"].iloc[r])
            Json.addValues("orderId", data["orderId"].iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))
        #
        # Return JSON array
        return jsonData

# DAM results - EET (POST)
class damResultsSMP(Resource):
    def post(self):
        json_file = request.json
        #
        data = damSmpResults(json_file=json_file)
        data.engine = engine
        data.pass_to_db()

        return 200



# ISP Technoeconomic Declaration (POST)
class ispTED(Resource):
    def post(self):
        # Get parameters
        dispatchDate = request.args.get("dispatchDate")
        tedType = request.args.get("tedType")
        units = request.args.get("units")

        # Initialize parameters
        units = units.split(",")
        examinedUnits = "("
        for unit in units:
            examinedUnits = examinedUnits + "'" + unit + "',"
        examinedUnits = examinedUnits[:-1] + ")"


        if tedType == "technical":
            # Get json file
            json_file = request.json
            ted = pd.DataFrame(data=json.loads(json_file))
            ted.columns = ["unit", "maxEnergy", "rawCost", "maintenanceCost", "coldSuCost", "warmSuCost", "hotSuCost", "sdCost", "co2Cost", "fuelCostA", "fuelCostB", "fuelCostC", "fuelLhvA", "fuelLhvB", "fuelLhvC"]
            ted.insert(0, "dispatchDate", dispatchDate)

            # Connect to database
            connection = ConnectToDatabase(username="heron_analyst", password="Dipbsia_01", servername="10.124.21.72", database="heron_epm").engine.connect()

            # Delete previous orders
            sqlstring = "DELETE FROM market_data.isp_ted_technical WHERE dispatchDate='" + dispatchDate + "' AND unit in " + examinedUnits
            connection.execute(sqlstring)

            # Pass new data to database
            mergeTable(dataframe=ted, connection=connection, table="market_data.isp_ted_technical",
                       onFields=["dispatchDate", "unit"], updFields=["maxEnergy", "rawCost", "maintenanceCost", "coldSuCost", "warmSuCost", "hotSuCost", "sdCost", "co2Cost", "fuelCostA", "fuelCostB", "fuelCostC", "fuelLhvA", "fuelLhvB", "fuelLhvC"])

        if tedType == "fuel":
            # Get json file
            json_file = request.json
            ted = pd.DataFrame(data=json.loads(json_file))
            ted.columns = ["unit", "step", "outLevel", "fuelA", "fuelB", "fuelC"]
            ted.insert(0, "dispatchDate", dispatchDate)

            # Connect to database
            connection = ConnectToDatabase(username="heron_analyst", password="Dipbsia_01", servername="10.124.21.72", database="heron_epm").engine.connect()

            # Delete previous orders
            sqlstring = "DELETE FROM market_data.isp_ted_fuel WHERE dispatchDate='" + dispatchDate + "' AND unit in " + examinedUnits
            connection.execute(sqlstring)

            # Pass new data to database
            mergeTable(dataframe=ted, connection=connection, table="market_data.isp_ted_fuel",
                       onFields=["dispatchDate", "unit"], updFields=["step", "outLevel", "fuelA", "fuelB", "fuelC"])

        return 200

# ENTSO-e load forecast (POST):
class entsoeLoadForecast(Resource):
    def post(self):
        json_file = request.json
        #
        data = entsoLF(json_file=json_file)
        data.engine = engine
        data.pass_to_db()

        return "Success", 200

# ENTSO-e RES forecast (POST, GET):
class entsoeRESForecast(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["date", "res"])
        dispatchDate = args["date"]
        resType = args["res"]
        #
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM entsoe_res_forecast WHERE dispatchDate='" + dispatchDate + "'"
        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("dispatchDate", data["dispatchDate"].iloc[r], True)
            Json.addValues("dispatchPeriod", data["dispatchPeriod"].iloc[r])
            Json.addValues("resType", data["resType"].iloc[r], True)
            Json.addValues("forecast", data["forecast"].iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))
        #
        # Return JSON array
        return jsonData

    def post(self):
        json_file = request.json
        #
        data = entsoRES(json_file=json_file)
        data.engine = engine
        data.pass_to_db()

        return "Success", 200

# ENTSO-e NTC forecast (POST):
class entsoeNTCForecast(Resource):
    def post(self):
        json_file = request.json
        #
        data = entsoNTC(json_file=json_file)
        data.engine = engine
        data.pass_to_db()

        return "Success", 200

# HERON Updated Schedule (GET, POST)
class updatedSchedule(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["dispatchDate"])
        dispatchDate = args["dispatchDate"]

        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        # sql_query = "SELECT * FROM em_results.heron_schedule WHERE Convert(varchar, [tradingDate], 23)='" + str(date) + "'"
        sql_query = "SELECT hs.[ID], hs.[tradingDate], hs.[halfHour], hs.[updateTime], hs.[ispSolution], hs.[fileVersion], hs.[unit], hs.[powerOutput] " + \
                    "FROM [heron_epm].[em_results].[heron_schedule] hs INNER JOIN (SELECT [tradingDate], [halfHour], [unit], MAX([updateTime]) as maxUpdateTime " + \
                    "FROM [heron_epm].[em_results].[heron_schedule] WHERE CONVERT(varchar, [tradingDate], 23) = '" + str(dispatchDate) + "' GROUP BY [tradingDate],[halfHour], [unit]) maxes " + \
                    "ON hs.tradingDate = maxes.tradingDate AND hs.[halfHour] = maxes.[halfHour] AND hs.[updateTime] = maxes.maxUpdateTime AND hs.[unit] = maxes.[unit] " + \
                    "WHERE CONVERT(varchar, hs.[tradingDate], 23) = '" + str(dispatchDate) + "' ORDER BY hs.tradingDate, hs.halfHour, hs.updateTime"

        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("tradingDate", data["tradingDate"].iloc[r], True)
            Json.addValues("halfHour", data["halfHour"].iloc[r])
            Json.addValues("updateTime", data["updateTime"].iloc[r], True)
            Json.addValues("ispSolution", data["ispSolution"].iloc[r], True)
            Json.addValues("fileVersion", data["fileVersion"].iloc[r])
            Json.addValues("unit", data["unit"].iloc[r], True)
            Json.addValues("powerOutput", data["powerOutput"].iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))
        #
        # Return JSON array
        return jsonData

    def post(self):
        global pexec
        pfile = "E://Scripts//Python//Electricity Markets//ISP//isp_results.py"

        p = subprocess.run([pexec, pfile, "There is additional text only in the VM"], shell=True, stdout=subprocess.PIPE, text=True)
        out = p.stdout

        return out, 200





""" ===============================================================================================
 MARKET DATA ======================================================================================
"""
# DAPEEP Quantities (GET)
class dapeepQuantities(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["dispatchDate", "market", "portfolio"])
        dispatchDate = args["dispatchDate"] if args["dispatchDate"] is not None else "Empty"
        market = args["market"] if args["market"] is not None else "Empty"
        portfolio = args["portfolio"] if args["portfolio"] is not None else "Empty"

        reqDispatchDate = "dispatchDate='" + dispatchDate + "'" if dispatchDate != "Empty" else ""
        reqMarket = " AND market='" + market + "'" if market != "Empty" else ""
        reqPortfolio = " AND portfolio='" + portfolio + "'" if portfolio != "Empty" else ""

        reqParameters = " WHERE " + reqDispatchDate + reqMarket + reqPortfolio

        if dispatchDate == "Empty":
            return "Please select an active date"
        #
        """
         CONNECT TO DATABASE AND GET DATA
        """
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM [heron_epm].[market_data].[dapeep_quantities]" + reqParameters
        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("dispatchDate", data["dispatchDate"].iloc[r], True)
            Json.addValues("market", data["market"].iloc[r], True)
            Json.addValues("portfolio", data["portfolio"].iloc[r], True)
            Json.addValues("dispatchPeriod", data["dispatchPeriod"].iloc[r])
            Json.addValues("quantity", data["quantity"].iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))
        #
        # Return JSON array
        return jsonData

# HENEX Asset Capapcities (GET)
class henexAssetCapacities(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["dispatchDate", "participant"])
        dispatchDate = args["dispatchDate"]
        participant = args["participant"]

        #
        """
         CONNECT TO DATABASE AND GET DATA
        """
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM [heron_epm].[em_results].[asset_capacities] WHERE LEFT(deliveryStartDT,10)='" + dispatchDate + "' AND participantId='" + participant + "'"
        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("assetId", data["assetId"].iloc[r], True)
            Json.addValues("participantId", data["participantId"].iloc[r], True)
            Json.addValues("dispatchDate", data["deliveryStartDT"].iloc[r], True)
            Json.addValues("maxAvailCapacity", data["maxAvailCapacity"].fillna(0).iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))

        # Return JSON array
        return jsonData

# VOLUE Price Forecasts (GET)
class volueForecasts(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["tradingDate", "biddingArea"])
        tradingDate = args["tradingDate"]
        biddingArea = args["biddingArea"]

        biddingArea = biddingArea.split(",")

        # Create the biddingAreas string, used in the SQL query
        biddingAreas = "("
        counter = 0

        for area in biddingArea:
            counter = counter + 1
            if counter == 1:
                prefix = ""
            else:
                prefix = ", "

            biddingAreas = biddingAreas + prefix + "'" + area + "'"

        biddingAreas = biddingAreas + ")"
        #
        #
        """
         CONNECT TO DATABASE AND GET DATA
        """
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM [heron_epm].[market_data].[price_forecasts_volue] WHERE LEFT(tradingDate,10)='" + tradingDate + "' AND biddingArea IN " + biddingAreas
        print(sql_query)
        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("tradingDate", data["tradingDate"].iloc[r], True)
            Json.addValues("biddingArea", data["biddingArea"].iloc[r], True)
            Json.addValues("priceForecast", data["priceForecast"].fillna(0).iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))

        # Return JSON array
        return jsonData


""" ===============================================================================================
 MARKET RESULTS ===================================================================================
"""
' Electricity Market '
# HENEX Results - Clearing Prices (GET)
class henexResultsClearingPrices(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["dispatchDateFrom", "dispatchDateTo"])
        dispatchDateFrom = args["dispatchDateFrom"]
        dispatchDateTo = args["dispatchDateTo"]
        #
        #
        """
         CONNECT TO DATABASE AND GET DATA
        """
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM [heron_epm].[em_results].[results] WHERE LEFT(deliveryStartDT,10)>='" + dispatchDateFrom + "' AND LEFT(deliveryStartDT,10)<='" + dispatchDateTo + "'"
        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("dispatchDate", data["deliveryStartDT"].iloc[r], True)
            Json.addValues("targetMarket", data["targetMarket"].iloc[r], True)
            Json.addValues("biddingZone", data["biddingZone"].iloc[r], True)
            Json.addValues("clearingPrice", data["clearingPrice"].fillna(0).iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))

        # Return JSON array
        return jsonData

# RTBM Prices (POST, GET)
class rtbmPrices(Resource):
    def post(self):
        json_file = request.json
        print(json_file)
        #
        data = RTBMprices(json_file=json_file)
        print(data)
        data.engine = engine
        data.pass_to_db()

    def get(self):
        # Get parameters
        args = addParameters(["dateFrom", "dateTo"])
        dateFrom = args["dateFrom"] if args["dateFrom"] is not None else "Empty"
        dateTo = args["dateTo"] if args["dateTo"] is not None else "Empty"

        reqDateFrom = "CONVERT(varchar, rtbm.referenceTimeFrom, 23)>='" + dateFrom + "'" if dateFrom != "Empty" else ""
        reqDateTo = " AND CONVERT(varchar, rtbm.referenceTimeTo, 23)<='" + dateTo + "'" if dateTo != "Empty" else ""

        reqParameters = " WHERE " + reqDateFrom + reqDateTo + " ORDER BY rtbm.referenceTimeFrom ASC"


        if dateFrom == "Empty":
            return "Please select an active date from"
        if dateTo == "Empty":
            return "Please select an active date to"
        #
        """
         CONNECT TO DATABASE AND GET DATA
        """
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT rtbm.referenceTimeFrom, rtbm.referenceTimeTo, rtbm.currentVersion, rtbm.imbalancePriceUp, rtbm.imbalancePriceDown, rtbm.activatedEnergyUp, rtbm.activatedEnergyDown, rtbm.systemEnergy " + \
                    "FROM [heron_epm].[dbo].[aperiodic_rtbm_data] rtbm " + \
                    "INNER JOIN (SELECT referenceTimeFrom, MAX(currentVersion) AS MaxVersion FROM [heron_epm].[dbo].[aperiodic_rtbm_data] GROUP BY referenceTimeFrom) rtbmgroup " + \
                    "ON rtbm.referenceTimeFrom = rtbmgroup.referenceTimeFrom AND rtbm.currentVersion = rtbmgroup.MaxVersion " + reqParameters
        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("referenceTimeFrom", data["referenceTimeFrom"].iloc[r], True)
            Json.addValues("referenceTimeTo", data["referenceTimeTo"].iloc[r], True)
            Json.addValues("currentVersion", data["currentVersion"].iloc[r])
            Json.addValues("imbalancePriceUp", data["imbalancePriceUp"].iloc[r])
            Json.addValues("imbalancePriceDown", data["imbalancePriceDown"].iloc[r])
            Json.addValues("activatedEnergyUp", data["activatedEnergyUp"].iloc[r])
            Json.addValues("activatedEnergyDown", data["activatedEnergyDown"].iloc[r])
            Json.addValues("systemEnergy", data["systemEnergy"].iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))
        #
        # Return JSON array
        return jsonData

# RTBM HERON Results (POST, GET)
class rtbmHeronResults(Resource):
    def post(self):
        # Get parameters
        asset = request.args.get("asset")

        # Get json file
        json_file = request.json

        # Get data
        data = RTBMheron(json_file=json_file, asset=asset)

        # Pass data to database
        data.engine = engine
        data.pass_to_db()

# Volue Day-Ahead Market Clearing Prices (GET)
class volueMarketClearingPrices(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["tradingDateFrom", "tradingDateTo", "biddingArea"])
        tradingDateFrom = args["tradingDateFrom"]
        tradingDateTo = args["tradingDateTo"]
        biddingArea = args["biddingArea"]
        #
        if biddingArea is not None:
            biddingAreaList = biddingArea.split(",")

            biddingAreas = ""
            for area in biddingAreaList:
                prefix = "," if len(biddingAreas) > 0 else ""
                biddingAreas = biddingAreas + prefix + "'" + area + "'"
        #
        #
        """
         CONNECT TO DATABASE AND GET DATA
        """
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM [heron_epm].[em_results].[clearing_prices_volue] WHERE LEFT(tradingDate,10)>='" + tradingDateFrom + "' AND LEFT(tradingDate,10)<='" + tradingDateTo + "'"
        if biddingArea is not None:
            sql_query = sql_query + " AND biddingArea in (" + biddingAreas + ")"

        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("tradingDate", data["tradingDate"].iloc[r], True)
            Json.addValues("biddingArea", data["biddingArea"].iloc[r], True)
            Json.addValues("clearingPrice", data["clearingPrice"].fillna(0).iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))

        # Return JSON array
        return jsonData

# Day-Ahead Market Clearing Prices (POST, GET)
class marketClearingPrices(Resource):
    def post(self):

        # Set python executable
        python_exec = "C://Python39//pythonw.exe"

        # Set python code
        python_code_mcps = "E://Scripts//Python//Shift//Download_MCP//Download_Market_Clearing_Prices.py"
        python_code_volue_mcps = "E://Scripts//Python//Shift//Volue_Price_Forecasts//Download_Volue_Forecasts.pyw"

        # Set output dictionary
        output = dict()

        # Run code for market clearing prices
        process = subprocess.Popen([python_exec, python_code_mcps], stdout=subprocess.PIPE)
        output["MCPs"] = process.communicate()[0]

        # Run code for VOLUE market clearing prices
        process = subprocess.Popen([python_exec, python_code_volue_mcps], stdout=subprocess.PIPE)
        output["VolueMCPs"] = process.communicate()[0]

        return "Operation completed!"

    def get(self):
        # Get parameters
        args = addParameters(["tradingDateFrom", "tradingDateTo", "biddingArea"])
        tradingDateFrom = args["tradingDateFrom"]
        tradingDateTo = args["tradingDateTo"]
        biddingArea = args["biddingArea"]
        #
        if biddingArea is not None:
            biddingAreaList = biddingArea.split(",")

            biddingAreas = ""
            for area in biddingAreaList:
                prefix = "," if len(biddingAreas) > 0 else ""
                biddingAreas = biddingAreas + prefix + "'" + area + "'"
        #
        #
        """
         CONNECT TO DATABASE AND GET DATA
        """
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM [heron_epm].[em_results].[mcp] WHERE LEFT(tradingDate,10)>='" + tradingDateFrom + "' AND LEFT(tradingDate,10)<='" + tradingDateTo + "'"
        if biddingArea is not None:
            sql_query = sql_query + " AND biddingArea in (" + biddingAreas + ")"

        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("tradingDate", data["tradingDate"].iloc[r], True)
            Json.addValues("biddingArea", data["biddingArea"].iloc[r], True)
            Json.addValues("clearingPrice", data["clearingPrice"].fillna(0).iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))

        # Return JSON array
        return jsonData

# Day-Ahead Market Clearing Prices for Turkey (GET)
class marketClearingPricesTR(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["tradingDateFrom", "tradingDateTo"])
        tradingDateFrom = args["tradingDateFrom"]
        tradingDateTo = args["tradingDateTo"]
        #
        #
        """
         CONNECT TO DATABASE AND GET DATA
        """
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM [heron_epm].[em_results].[mcp_tr] WHERE LEFT(tradingDate,10)>='" + tradingDateFrom + "' AND LEFT(tradingDate,10)<='" + tradingDateTo + "'"

        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("tradingDate", data["tradingDate"].iloc[r], True)
            Json.addValues("clearingPrice", data["clearingPrice"].fillna(0).iloc[r])
            Json.addValues("clearingPriceEUR", data["clearingPriceEUR"].fillna(0).iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))

        # Return JSON array
        return jsonData

# RTBM Results (Prices & Energy) (GET)
class rtbmResults(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["referenceTimeFrom", "referenceTimeTo"])
        reference_time = args["referenceTime"]
        reference_time_from = args["referenceTimeFrom"]
        reference_time_to = args["referenceTimeTo"]

        # Process data
        reference_time_from_condition = "=" if reference_time_to is None else ">="
        reference_time_to_string = f" AND LEFT(referenceTimeTo, 10)<='{reference_time_to}'" if reference_time_to is not None else ""

        """
         CONNECT TO DATABASE AND GET DATA
        """
        # Connect to engine
        conn = connectToDB().connection

        # Get data
        sql_query = f"SELECT * FROM [heron_epm].[em_results].[rtbm_energy_prices] WHERE LEFT(referenceTimeFrom, 10){reference_time_from_condition}'{reference_time_from}'" + reference_time_to_string
        data = pd.read_sql(sql_query, con=conn)


        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Set product code
            product_code = products[data["productCode"].iloc[r][:2]] + data["productCode"].iloc[r][2:]
            #
            # Pass data to json object
            Json.addValues("tradingDate", data["tradedatetimegmt"].iloc[r], True)
            Json.addValues("biddingArea", data["biddingArea"].iloc[r], True)
            Json.addValues("productCode", product_code, True)
            Json.addValues("productType", data["productType"].iloc[r], True)
            Json.addValues("closePrice", data["closePrice"].fillna(0).iloc[r])
            Json.addValues("volumeOffEEX", data["offexchtradevolumeeex"].fillna(0).iloc[r])
            Json.addValues("volumeOnEEX", data["onexchtradevolumeeex"].fillna(0).iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))

        # Return JSON array
        return jsonData


' Gas Market '
# Customers forecasted gas consumption (GET)
class icisPrices(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["dateFrom", "dateTo"])
        dateFrom = args["dateFrom"]
        dateTo = args["dateTo"]
        #
        #
        """
         PROCESS DATA
        """
        products = {
            "January": "Jan.",
            "February": "Feb.",
            "March": "Mar.",
            "April": "Apr.",
            "May": "May.",
            "June": "Jun.",
            "July": "Jul.",
            "August": "Aug.",
            "September": "Sep.",
            "October": "Oct.",
            "November": "Nov.",
            "December": "Dec.",
            "Q1": "Qr1.",
            "Q2": "Qr2.",
            "Q3": "Qr3.",
            "Q4": "Qr4.",
            "Summer": "Sum.",
            "Winter": "Win.",
            "Year": "Cal.",
            "Day-ahead": "Dm1.",
            "Weekend": "Wkd."
        }
        #
        #
        """
         CONNECT TO DATABASE AND GET DATA
        """
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM [heron_epm].[gm_data].[icis_prices] WHERE tradingDate>='" + dateFrom + "' AND tradingDate<='" + dateTo + "'"

        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize data
            trading_date = data["tradingDate"].iloc[r]
            series_name = data["seriesName"].fillna(0).iloc[r]
            price = data["price"].fillna(0).iloc[r]

            # Process data
            split_product = data["contractPeriod"].fillna(0).iloc[r].split("_")
            product_period = products[split_product[0]]
            if len(split_product) > 1:
                product_year = split_product[1] if len(split_product[1]) == 2 else split_product[1][2:]
            else:
                product_year = trading_date.year - 2000
            #
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("tradingDate", trading_date, True)
            Json.addValues("seriesName", series_name, True)
            Json.addValues("contractPeriod", str(product_period) + str(product_year), True)
            Json.addValues("price", price)
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))

        # Return JSON array
        return jsonData

# Customers forecasted gas consumption (GET)
class customerGasConsumptionForecast(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["dateFrom", "dateTo"])
        dateFrom = args["dateFrom"]
        dateTo = args["dateTo"]
        #
        #
        """
         CONNECT TO DATABASE AND GET DATA
        """
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM [heron_epm].[gm_data].[customer_gas_consumption_forecast] WHERE dispatchDate>='" + dateFrom + "' AND dispatchDate<='" + dateTo + "'"

        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("dispatchDate", data["dispatchDate"].iloc[r], True)
            Json.addValues("customer", data["customer"].fillna(0).iloc[r], True)
            Json.addValues("forecast", data["forecast"].fillna(0).iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))

        # Return JSON array
        return jsonData

# Gas balancing prices (GET)
class gasBalancingPrices(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["dateFrom", "dateTo"])
        dateFrom = args["dateFrom"]
        dateTo = args["dateTo"]
        #
        #
        """
         CONNECT TO DATABASE AND GET DATA
        """
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM [heron_epm].[gm_results].[gas_balancing_prices] WHERE dispatchDate>='" + dateFrom + "' AND dispatchDate<='" + dateTo + "'"

        data = pd.read_sql(sql_query, con=conn)
        data["dispatchDate"] = data["dispatchDate"].apply(lambda x: x.strftime("%Y-%m-%d"))
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("dispatchDate", data["dispatchDate"].iloc[r], True)
            Json.addValues("TAEE", data["TAEE"].fillna(0).iloc[r])
            Json.addValues("OTAAE", data["OTAAE"].fillna(0).iloc[r])
            Json.addValues("OTPAE", data["OTPAE"].fillna(0).iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))

        # Return JSON array
        return jsonData

# ICE prices (GET)
class icePrices(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["tradingDateFrom", "tradingDateTo", "productType", "priceType"])
        trading_date_from = args["tradingDateFrom"]
        trading_date_to = args["tradingDateTo"]
        product_type = args["productType"]
        price_type = args["priceType"]
        #
        # Initialize data
        abbreviations = {
            "Q1": "Qr1",
            "Q2": "Qr2",
            "Q3": "Qr3",
            "Q4": "Qr4",
            "Summer": "Sum",
            "Winter": "Win"
        }
        #
        #
        """
         CONNECT TO DATABASE AND GET DATA
        """
        # Connect to engine
        conn = connectToDB().connection

        # Find the number of examined dates
        trading_date_from_date = datetime.datetime.strptime(trading_date_from, "%Y-%m-%d")
        trading_date_to_date = datetime.datetime.strptime(trading_date_to, "%Y-%m-%d")
        no_days = (trading_date_to_date - trading_date_from_date).days

        # Initialize dataframe containing data and populate it
        data = pd.DataFrame()
        for d in range(no_days + 1):
            examined_date = trading_date_from_date + datetime.timedelta(days=d)
            examined_date_string = examined_date.strftime("%Y-%m-%d")

            if price_type == "real-time":
                sql_query = f"""
                            SELECT t.marketStrip, t.lastTime, t.endDate, t.change, t.volume, t.lastPrice
                            FROM (SELECT * FROM [heron_epm].[market_data].[ice_{product_type.lower()}] WHERE LEFT(lastTime,10)='{examined_date_string}') t
                            inner join (SELECT marketStrip, max(lastTime) as MaxLastTime
                                        from [heron_epm].[market_data].[ice_{product_type.lower()}]
                                        WHERE LEFT(lastTime,10)='{examined_date_string}'
                                        group by marketStrip
                                        ) tm on t.marketStrip = tm.marketStrip and t.lastTime = tm.MaxLastTime
                            """
            else:
                sql_query = f"SELECT * FROM [heron_epm].[market_data].[ice_{product_type.lower()}_close] WHERE tradingDate='{examined_date_string}'"

            daily_data = pd.read_sql(sql_query, con=conn)

            data = data.append(daily_data)

        # Reset dataframe indices
        data = data.reset_index()

        # sql_query = f"""
        #     SELECT t.marketStrip, t.lastTime, t.endDate, t.change, t.volume, t.lastPrice
        #     FROM (SELECT * FROM [heron_epm].[market_data].[ice_{product_type.lower()}] WHERE LEFT(lastTime,10)>='{trading_date_from}' AND LEFT(lastTime,10)<='{trading_date_to}') t
        #     inner join (SELECT marketStrip, max(lastTime) as MaxLastTime
        #                 from [heron_epm].[market_data].[ice_{product_type.lower()}]
        #                 group by marketStrip
        #                 ) tm on t.marketStrip = tm.marketStrip and t.lastTime = tm.MaxLastTime
        # """
        #
        # data = pd.read_sql(sql_query, con=conn)

        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Process data
            product_period = data["marketStrip"].iloc[r][:-2].replace(".", "").replace(" ","")
            product_period = abbreviations[product_period] if product_period in abbreviations.keys() else product_period
            product_year = data["marketStrip"].iloc[r][-2:]
            #
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            if price_type == "real-time":
                Json.addValues("marketStrip", f"{product_period}.{product_year}", True)
                Json.addValues("lastTime", data["lastTime"].iloc[r], True)
                Json.addValues("endDate", data["endDate"].iloc[r], True)
                Json.addValues("change", data["change"].fillna(0).iloc[r])
                Json.addValues("volume", data["volume"].fillna(0).iloc[r])
                Json.addValues("lastPrice", data["lastPrice"].fillna(0).iloc[r])
            else:
                Json.addValues("marketStrip", f"{product_period}.{product_year}", True)
                Json.addValues("tradingDate", data["tradingDate"].iloc[r], True)
                Json.addValues("closePrice", data["closePrice"].fillna(0).iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))

        # Return JSON array
        return jsonData

# EEX Power Forwards (GET)
class eexPowerForwards(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["tradingDateFrom", "tradingDateTo", "biddingArea", "productType"])
        tradingDateFrom = args["tradingDateFrom"]
        tradingDateTo = args["tradingDateTo"]
        biddingArea = args["biddingArea"]
        product_type = args["productType"]

        # Initialize data
        bidding_area_string = "" if biddingArea is None else f" AND biddingArea='{biddingArea}'"
        product_type_string = "" if product_type is None else f" AND productType='{product_type}'"

        products = {
            "MF": "Jan.",
            "MG": "Feb.",
            "MH": "Mar.",
            "MJ": "Apr.",
            "MK": "May.",
            "MM": "Jun.",
            "MN": "Jul.",
            "MQ": "Aug.",
            "MU": "Sep.",
            "MV": "Oct.",
            "MX": "Nov.",
            "MZ": "Dec.",
            "QF": "Qr1.",
            "QJ": "Qr2.",
            "QN": "Qr3.",
            "QV": "Qr4.",
            "YF": "Cal."
         }
        #
        #
        """
         CONNECT TO DATABASE AND GET DATA
        """
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = f"SELECT * FROM [heron_epm].[market_data].[eex_power_forwards] WHERE LEFT(tradedatetimegmt,10)>='{tradingDateFrom}' AND LEFT(tradedatetimegmt,10)<='{tradingDateTo}'" + \
                    bidding_area_string + product_type_string
        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Set product code
            product_code = products[data["productCode"].iloc[r][:2]] + data["productCode"].iloc[r][2:]
            #
            # Pass data to json object
            Json.addValues("tradingDate", data["tradedatetimegmt"].iloc[r], True)
            Json.addValues("biddingArea", data["biddingArea"].iloc[r], True)
            Json.addValues("productCode", product_code, True)
            Json.addValues("productType", data["productType"].iloc[r], True)
            Json.addValues("closePrice", data["closePrice"].fillna(0).iloc[r])
            Json.addValues("volumeOffEEX", data["offexchtradevolumeeex"].fillna(0).iloc[r])
            Json.addValues("volumeOnEEX", data["onexchtradevolumeeex"].fillna(0).iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))

        # Return JSON array
        return jsonData


""" ===============================================================================================
 SALES ============================================================================================
"""
# LV costing data (POST)
class lvCosting(Resource):
    def post(self):
        # Read json file
        json_file = request.json

        # Create dataframe
        lv = pd.DataFrame(data=json.loads(json_file))

        # Connect to database
        conn = connectToDB(username="heron_analyst", password="Dipbsia_01", database="heron_epm",
                           servername="10.124.21.72")

        # Pass data to database
        on_fields_lv = ["publicationYear", "publicationMonth", "settlementYear", "settlementMonth", "voltageLevel"]
        updated_fields_lv = ["losses", "dsoMeasurementSettlement", "currentSteals", "salesWithoutLosses", "marketClearingPrice", "profileCost",
                             "imbalanceSettlement", "upliftAccount1Cost", "upliftAccount2Cost", "upliftAccount3Cost",
                             "upliftAccountCost", "capacityPayments", "resUpliftCost", "lowVoltageSettlement",
                             "nominalLosses", "lowVoltageLosses", "otherCharges", "totalCost"]
        try:
            mergeTable(dataframe=lv, connection=conn.connection, table="[sales].[costing_lv]", onFields=on_fields_lv, updFields=updated_fields_lv)
        except:
            print("Could not load LV costing data to database")

# MV costing data (POST)
class mvCosting(Resource):
    def post(self):
        # Read json file
        json_file = request.json

        # Create dataframe
        mv = pd.DataFrame(data=json.loads(json_file))

        # Connect to database
        conn = connectToDB(username="heron_analyst", password="Dipbsia_01", database="heron_epm",
                           servername="10.124.21.72")

        # Pass data to database
        on_fields_mv = ["publicationYear", "publicationMonth", "settlementYear", "settlementMonth", "voltageLevel"]
        updated_fields_mv = ["losses", "salesWithoutLosses", "marketClearingPrice", "profileCost",
                             "imbalanceSettlement", "upliftAccount1Cost", "upliftAccount2Cost", "upliftAccount3Cost",
                             "upliftAccountCost", "capacityPayments", "resUpliftCost",
                             "nominalLosses", "otherCharges", "totalCost"]
        try:
            mergeTable(dataframe=mv, connection=conn.connection, table="[sales].[costing_mv]", onFields=on_fields_mv, updFields=updated_fields_mv)
        except:
            print("Could not load  MV costing data to database")

# Indicative fixed prices for power (POST)
class indicativeFixedPricesPower(Resource):
    def post(self):
        # Read json file
        json_file = request.json

        # Create dataframe
        data = pd.DataFrame(data=json.loads(json_file))

        # Connect to database
        conn = connectToDB(username="heron_analyst", password="Dipbsia_01", database="heron_epm",
                           servername="10.124.21.72")

        # Pass data to database
        on_fields = ["updateDate", "dateFrom", "dateTo", "productName"]
        updated_fields = ["productFixedPrice"]
        try:
            mergeTable(dataframe=data, connection=conn.connection, table="[sales].[indicative_price_power]", onFields=on_fields, updFields=updated_fields)
            return 200
        except:
            return "Could not load indicative power prices data to database"

"""
 EXTERNAL PROCEDURES
"""
# Send RTBM data
class sendRTBM(Resource):
    def post(self):
        # Initialize class
        mail = emailRTBM(history=1)

        # Get data
        mail.getData()

        # Send e-mail
        mail.sendEmail()

        return "Operation completed", 200


"""
 midTemps DATA
"""
# RTBM Prices (POST, GET)
class midTempsData(Resource):
    def post(self):
        json_file = request.json
        #
        data = pd.DataFrame(data=json.loads(json_file))

        print(data)


"""
 GENERAL PROCEDURES
"""
# Update Database (POST)
class updateDatabase(Resource):
    def post(self):
        json_request = request.json
        print(json_request)
        json_file = json.loads(json_request)

        # Get data from extended json file
        username = json_file["username"]
        password = json_file["password"]
        database = json_file["database"]
        schema = json_file["schema"]
        servername = json_file["servername"]
        tablename = json_file["tablename"]
        onFields = json_file["onField"]
        updFields = json_file["updateField"]
        json_data = json_file["json"]
        data = pd.DataFrame(data=json_data)

        # Connect to database
        conn = connectToDB(database=database, password=password, username=username, servername=servername)
        fullTableName = "[" + database + "].[" + schema + "].[" + tablename + "]"
        #
        # Update table
        mergeTable(dataframe=data, connection=conn.connection, table=fullTableName, onFields=onFields, updFields=updFields)

# Log Files (GET)
class logFiles(Resource):
    def get(self):
        # Get parameters
        args = addParameters(["examinedDate", "logCategory"])
        examinedDate = args["examinedDate"]
        logCategory = args["logCategory"].replace("_", " ")
        #
        #
        """
         CONNECT TO DATABASE AND GET DATA
        """
        # Connect to engine
        conn = connectToDB().connection
        #
        # Get data
        sql_query = "SELECT * FROM [heron_epm].[dbo].[logs] WHERE LEFT(examinedDate,10)='" + examinedDate + "' AND logCategory='" + logCategory + "'"

        data = pd.read_sql(sql_query, con=conn)
        #
        #
        """
         PREPARE AND SEND JSON
        """
        # Prepare JSON data
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(data)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("examinedDate", data["examinedDate"].iloc[r], True)
            Json.addValues("logCategory", data["logCategory"].iloc[r], True)
            Json.addValues("logStatus", data["logStatus"].iloc[r], True)
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))

        # Return JSON array
        return jsonData

    def post(self):
        # Get parameters
        examinedDate = request.args.get("examinedDate")

        # Get json file
        json_file = request.json

        # Create dataframe
        status = pd.DataFrame(data=[[examinedDate, json_file["logCategory"], json_file["logStatus"]]], columns=["examinedDate", "logCategory", "logSstatus"])

        # Connect to database
        conn = connectToDB(username="heron_analyst", password="Dipbsia_01", database="heron_epm", servername="10.124.21.72")

        # Update database
        mergeTable(dataframe=status, connection=conn.connection, table="dbo.logs",
                   onFields=["examinedDate", "logCategory"], updFields=["logStatus"])

        return "Database succesfully updated"


"""
 TESTING
"""
# Test Procedures (POST, GET)
class testRequest(Resource):
    def get(self):
        """
        GET Request Example
        --------------------
        url:    http://10.124.21.72:5000/api/testRequest?dispatchDate=2021-07-21&units=HERON1,HERON2,HERON3
        """
        # Get parameters
        args = addParameters(["dispatchDate", "units"])
        dispatchDate = args["dispatchDate"]
        units = args["units"]

        # Create ancillary data
        data = [[1, "HERON1_O", 4.9, 49], [2, "HERON2_O", 4.9, 47], [3, "HERON3_G", 4.9, 49]]
        unitData = pd.DataFrame(data=data, columns=["ID", "unitFullName", "pMin", "pMax"])

        # Create json file
        allUnits = units.split(",")
        jsonData = []
        #
        # Insert fields and values in json object
        for r in range(len(unitData)):
            # Initialize json object
            Json = JsonObj()
            #
            # Pass data to json object
            Json.addValues("dispatchDate", dispatchDate, True)
            Json.addValues("unitName", allUnits[r], True)
            Json.addValues("unitFullName", unitData["unitFullName"].iloc[r], True)
            Json.addValues("pMin", unitData["pMin"].iloc[r])
            Json.addValues("pMax", unitData["pMax"].iloc[r])
            #
            # Pass to JSON array
            jsonData.append(json.loads(Json.end()))

        # Alternative dataframe based JSON-creation procedure
        unitData["unitName"] = allUnits
        jsonDataAlternative = unitData.to_json(orient='records')

        return jsonData

    def post(self):
        """
        POST Request Example
        --------------------
        url:    http://10.124.21.72:5000/api/testRequest?dispatchDate=2021-07-21&units=HERON1,HERON2,HERON3
        json:   [{'dispatchDate': '2021-07-01', 'dispatchPeriod': 5, 'unit': 'HERON1', 'output': 40}]
        """
        # Get json object
        json_request = request.json
        json_file = json.loads(json_request)
        print(json_file)

        # Get parameters
        dispatchDate = request.args.get("dispatchDate")
        units = request.args.get("units")

        print(dispatchDate)
        print(units)

        return 200



""" ===============================================================================================
 ENDPOINTS AND RESOURCES ==========================================================================
"""

api.add_resource(ExecutePythonScripts, '/execute/<string:name>')
api.add_resource(RunPython, '/')
api.add_resource(Multi, '/multi/<int:num>')
api.add_resource(imbalStatement, '/api/admie/imbalStatement')
api.add_resource(henexTrades, '/henex/trades/<string:date>')
api.add_resource(damResultsSMP, '/api/Market/HEnEx/damResultsSMP')
api.add_resource(entsoeLoadForecast, '/api/Market/ENTSOe/loadForecast')
api.add_resource(entsoeRESForecast, '/api/Market/ENTSOe/resForecast')
api.add_resource(entsoeNTCForecast, '/api/Market/ENTSOe/ntcdForecast')
api.add_resource(updatedSchedule, '/api/admie/updatedSchedule')

api.add_resource(ispTED, '/api/Market/ISP/Orders/TED')

# General Data
api.add_resource(powerPlantAvailabilityHeronI, '/api/GeneralData/powerPlantAvailabilityHeronI')
api.add_resource(powerPlantAvailabilityHeronII, '/api/GeneralData/powerPlantAvailabilityHeronII')
api.add_resource(ispBalancingEnergyOrders, '/api/Market/ISP/Orders/Balancing')
api.add_resource(ispReserveOrders, '/api/Market/ISP/Orders/Reserves')
api.add_resource(icisPrices, '/api/GasData/icisPrices')
api.add_resource(customerGasConsumptionForecast, '/api/GasData/customerGasConsumptionForecast')
api.add_resource(icePrices, '/api/GeneralData/ICE/icePrices')
api.add_resource(eexPowerForwards, '/api/GeneralData/EEX/powerForwards')

# Market Data
api.add_resource(dapeepQuantities, '/api/Market/DAPEEP/dapeepQuantities')
api.add_resource(henexAssetCapacities, '/api/Market/HENEX/assetCapacities')
api.add_resource(volueForecasts, '/api/Market/HENEX/volueForecasts')


# Market Results
api.add_resource(henexResultsClearingPrices, '/api/Market/HENEX/resultsClearingPrices')
api.add_resource(rtbmPrices, '/api/admie/aperiodicSchedules/rtbmPrices')
api.add_resource(rtbmHeronResults, '/api/admie/aperiodicSchedules/rtbmHeronResults')
api.add_resource(gasBalancingPrices, '/api/desfa/gasBalancingPrices')
api.add_resource(volueMarketClearingPrices, '/api/volue/marketClearingPrices')
api.add_resource(marketClearingPrices, '/api/MarketResults/marketClearingPrices')
api.add_resource(marketClearingPricesTR, '/api/MarketResults/marketClearingPricesTR')

# Sales
api.add_resource(lvCosting, '/api/Sales/lvCosting')
api.add_resource(mvCosting, '/api/Sales/mvCosting')
api.add_resource(indicativeFixedPricesPower, "/api/Sales/indicativeFixedPricesPower")

# External Procedures
api.add_resource(sendRTBM, '/api/sendRTBM')

# midTemps Data
api.add_resource(midTempsData, '/api/midTemps')

# General Procedures
api.add_resource(updateDatabase, '/api/updateDatabase')
api.add_resource(logFiles, '/api/logs/logFiles')

# Global variables
pexec = "C://Python39//pythonw.exe"

# Testing
api.add_resource(testRequest, '/api/testRequest')


if __name__ == '__main__':
    # Connect to database
    engine = ConnectToDatabase(username="heron_analyst", password="Dipbsia_01", servername="10.124.21.72", database="heron_epm").engine
    #
    # Initialize application
    app.run(host="0.0.0.0", debug=True)

# app.run(host="0.0.0.0", debug=True, port=2345)
