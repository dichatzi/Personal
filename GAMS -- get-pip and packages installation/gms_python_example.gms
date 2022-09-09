Set i /i1*i10/
    p(i,i) "permutation";

embeddedCode Python:
import random
import requests
import pandas as pd
import json

i = list(gams.get("i"))
p = list(i)
random.shuffle(p)
for idx in range(len(i)):
    p[idx] = (i[idx], p[idx])
gams.set("p", p)

print("")
print("")
print("****************************************")
print("Dimitris is the best and forget the rest")
print("****************************************")

data = [["Dimitris", "Chatzigiannis"], ["Valia", "Topaloudi"], ["Michalis", "Kazdaglis"], ["Christina", "Bakalmpassi"]]
df = pd.DataFrame(data=data, columns=["name", "surname"])

print(df)



url = "http://10.124.21.72:5000/api/GasData/icisPrices?dateFrom=2022-05-22&dateTo=2022-05-25"
response = requests.get(url)

json_data = json.loads(response.text)

for r in json_data:
    print(r["price"])

endEmbeddedCode p

option p:0:0:1; 
display p;