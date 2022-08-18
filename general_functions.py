
"""
FIND THE INDEX OF ELEMENT IN A LIST
"""
def idx(array, value):
    # Transform input array or series to list
    list_array = list(array)

    # Find index of value in list
    list_index = list_array.index(value)

    # Return index
    return list_index
