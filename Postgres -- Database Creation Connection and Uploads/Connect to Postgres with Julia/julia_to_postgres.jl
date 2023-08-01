using DataFrames
using LibPQ


"""
CONNECT TO POSTGRES DATABASE
--------------------------------
database: the examined database name
password: the password for accessing the examined database
"""
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
input_data: a dataframe containing the required data
database_name: the examined database name
schema_name: the examined schema name
table_name: the examined table name
upd_fields: the fields to be updated
on_fields: the fields that are checked upon to determine if the upd_fields are to be updated or a new row to be inserted
slice: the size of each examined slice
"""
function upsert_table(;connection::LibPQ.Connection, input_data::DataFrame, database_name::String, schema_name::String, table_name::String, upd_fields::Vector{String}, on_fields::Vector{String}, slice::Int64=0)


    """ -------------------------------------------------------------------------------------------
    FIND SLICES -----------------------------------------------------------------------------------
    """
    # Initialize data
    no_rows = nrow(input_data)
    steps = Array{Tuple{Int64,Int64}}(undef, 0)
    starting_value = 0
    ending_value = 0

    if slice != 0 && slice < no_rows

        # Find quotient and remainder
        quotient = div(no_rows, slice)
        remainder = rem(no_rows, slice)

        # Loop for a number equal to quotient    
        for e = 1 : quotient

            # Get starting and ending value
            starting_value = (e-1) * slice + 1
            ending_value = e * slice
            
            # Push tuple to array
            push!(steps, (starting_value, ending_value))

        end

        # Check if remainder is different than zero and add final step in this case
        if remainder != 0

            # Push special case to the array
            push!(steps, (ending_value + 1, ending_value + remainder))

        end

    else
        push!(steps, (1, no_rows))
    end


    """ -------------------------------------------------------------------------------------------
    INITIALIZE DATA -------------------------------------------------------------------------------
    """
    # Initialize strings
    updates = ""
    on_fields_string = ""
    upd_fields_string = ""
    fields = ""

    # Create the respective variable strings
    for (index, value) in enumerate(upd_fields)

        # Get index
        if index == 1
            prefix = ""
        else
            prefix = ", "
        end

        # Update strings
        updates = updates * prefix * string(value) * " = EXCLUDED." * string(value)
        upd_fields_string = upd_fields_string * prefix * string(value)

    end

    for (index, value) in enumerate(on_fields_list)

        # Get index
        if index == 1
            prefix = ""
        else
            prefix = ", "
        end

        # Update strings
        on_fields_string = on_fields_string * prefix * string(value)

    end

    fields = "$(on_fields_string), $(upd_fields_string)"


    """ -------------------------------------------------------------------------------------------
    CREATE QUERIES AND UPDATE DATABASE ------------------------------------------------------------
    """
    for (index, step) in enumerate(steps)
        println(">> Updating slice $(index)")

        # Create examined dataframe
        examined_data = input_data[step[1]:step[2], :]

        # Create the query that creates the temporary table based on the original input dataframe
        temp_table_query = """
        CREATE TEMPORARY TABLE temp_table AS
        SELECT * FROM (VALUES $(join(["(" * join(row, ',') * ")" for row in eachrow(examined_data)], ',')))
        AS temp_table ($(fields));
        """
 
        # Execute the sql query that creates the temporary table
        temp_table_result = execute(connection, temp_table_query)

        # Create the query that updates the data on the examined table
        update_query = """
        INSERT INTO $(database_name).$(schema_name).$(table_name) ($(fields))
        SELECT $(fields) FROM temp_table
        ON CONFLICT ($(on_fields_string)) DO
        UPDATE SET 
        $(updates)
        """

        # Execute the query that updates the data on the examined table
        update_result = execute(connection, update_query)

        # Drop the temporary table
        drop_result = execute(connection, "DROP TABLE temp_table")


    end
    
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
