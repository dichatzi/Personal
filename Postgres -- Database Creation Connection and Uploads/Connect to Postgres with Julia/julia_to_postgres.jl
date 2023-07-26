using DataFrames
using LibPQ


function connect_to_postgres(database::String, password::String)::LibPQ.Connection
    # Create connection with postgres database
    database_connection = LibPQ.Connection("dbname=$(database) user=postgres password=$(password) host=localhost port=5432");

    # Return connection
    return database_connection
end


"""
UPSERT TABLE
--------------------------------
connection: a LibPQ.Connection object that is initialized in the current connection
input_data: a dataframe that has the (trading_period, clearing_price, agent_action, reward, times_per_pair) columns
"""
function upsert_table(;connection::LibPQ.Connection, input_data::DataFrame)

    # Create the query that creates the temporary table based on the original input dataframe
    temp_table_query = """
    CREATE TEMPORARY TABLE temp_table AS
    SELECT * FROM (VALUES $(join(["(" * join(row, ',') * ")" for row in eachrow(input_data)], ',')))
    AS temp_table (trading_period, clearing_price, agent_action, reward, times_per_pair);
    """

    # Execute the sql query that creates the temporary table
    temp_table_result = execute(connection, temp_table_query)

    # Initialize data used for updating the examined table
    updates = "reward = EXCLUDED.reward, times_per_pair = EXCLUDED.times_per_pair"
    on_fields = "trading_period, clearing_price, agent_action"
    upd_fields = "reward, times_per_pair"
    fields = "$(on_fields), $(upd_fields)"

    # Create the query that updates the data on the examined table
    update_query = """
    INSERT INTO creg.reinforcement_learning.tabular_rewards ($(fields))
    SELECT $(fields) FROM temp_table
    ON CONFLICT ($(on_fields)) DO
    UPDATE SET 
    $(updates)
    """

    # Execute the query that updates the data on the examined table
    update_result = execute(connection, update_query)

    # Drop the temporary table
    drop_result = execute(connection, "DROP TABLE temp_table")
    
end



"""
CODE
"""
# Connect to postgres database
conn = connect_to_postgres("creg", "Dipbsia_01");

# Create dataframe that will contain the data to be uploaded to database
new_data = DataFrame(trading_period = Int64[], clearing_price = Float64[], agent_action = Float64[], reward = Float64[], times_per_pair = Int64[])

for p = 1 : 15
    for afrr in [0, 100]
        for pout in [10, 20, 30]
            push!(new_data, [p, afrr, pout, round(10*rand(), digits=2), trunc(Int64, 10*rand())])
        end
    end
end

# Upsert data to database
upsert_table(connection=conn, input_data=new_data)

# Drop table
drop_result = execute(conn, "DROP TABLE reinforcement_learning.tabular_rewards");

close(conn)