"""
CLASSES
"""
class ConnectToDatabase:
    def __init__(self, database, username, password, servername, port):
        # Database data
        self.database = database
        self.username = username
        self.password = urllib.parse.quote_plus(password)
        self.servername = servername
        self.port = port
        #
        # Create engine
        self.engine = sqlalchemy.create_engine(
            f'postgresql://{self.username}:{self.password}@{self.servername}:{self.port}/{self.database}')
        #
        # Connect to engine
        self.connection = self.engine.connect()

class DatabaseData:
    def __init__(self, sql_object, dataframe, database, schema, table, on_fields, upd_fields):
        self.sql_object = sql_object
        self.dataframe = dataframe
        self.database = database
        self.schema = schema
        self.table = table
        self.on_fields = on_fields
        self.upd_fields = upd_fields

        # Check if dataframe containts duplicate values
        check_duplicates = dataframe[dataframe.duplicated(subset=on_fields, keep=False)]
        if len(check_duplicates) > 0:
            self.contains_duplicates = True
        else:
            self.contains_duplicates = False

    def upsert_table(self, input_table=[]):
        # Set the examined table
        if len(input_table) > 0:
            table_data = input_table
        else:
            table_data = self.dataframe

        # Calculate on fields string
        on_field = ""
        for on_id, field in enumerate(self.on_fields):
            prefix = ", " if on_id > 0 else ""
            on_field = f"{on_field}{prefix}{field}"

        # Calculate update fields string
        upd_field = ""
        for upd_id, field in enumerate(self.upd_fields):
            prefix = ", " if upd_id > 0 else ""
            upd_field = f"{upd_field}{prefix}{field}"

        # Calculate fields string
        fields = f"{on_field}, {upd_field}"

        # Calculate updates string
        updates = ""
        for id, field in enumerate(self.upd_fields):
            prefix = ", " if id > 0 else ""
            updates = f"{updates}{prefix}{field} = EXCLUDED.{field}"

        # Insert dataframe data to temporary table
        table_data.to_sql("temp_table", self.sql_object.connection, index=False, if_exists='replace')

        # Merge temporary table to main table
        query = f"""
            INSERT INTO {self.database}.{self.schema}.{self.table} ({fields})
            SELECT {fields} FROM {self.database}.public.temp_table
            ON CONFLICT ({on_field}) DO
            UPDATE SET 
            {updates}
            """
        self.sql_object.engine.execute(query)

        # Drop temporary table
        self.sql_object.engine.execute("DROP TABLE public.temp_table")

        # Return class object
        print(f"Table {self.table} has been updated")
        if len(input_table) == 0:
            return self

    def upsert_table_slices(self, slice_length):
        # Find the number of iterations
        no_iterations = math.ceil(len(self.dataframe) / slice_length)

        # Update table data for each iteration
        for i in range(no_iterations):
            # Calculate start and end rows
            start_row = i * slice_length
            last_row = min(start_row + slice_length, len(self.dataframe))

            # Create sub dataframe
            new_df = self.dataframe[start_row:last_row]

            # Uploading data
            print(f"Slice {i + 1}: updating data")
            self.upsert_table(input_table=new_df)

        # Return class object
        return self


"""
CODE
"""
# Connect to database
db = ConnectToDatabase(database="sales", username="postgres", password="Dipbsia_01", servername="localhost", port=5432)
connection = db.connection

# Pass data to database
on_fields = ['trading_date_from', 'trading_date_to', 'update_date', 'file_name']
upd_fields = ['total_net_system_generation', 'inter_total_balance', 'total_system_load', 'grand_total_system_consumption', 'total_pumping_consumption',
              'total_customer_consumption', 'total_gen_aux_consumption', 'total_net_system_load', 'system_losses', 'sys_tot_net_energy_total', 'network_res_prod', 'total_in_energy_mv', 
              'total_consumption_mv', 'total_energy_cons_lv', 'system_to_crete', 'crete_to_system']
system_data = DatabaseData(sql_object=db, dataframe=df_final, database="sales", schema="market_data", table="system_data", on_fields=on_fields, upd_fields=upd_fields)
system_data.upsert_table()
