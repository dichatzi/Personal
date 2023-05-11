import uvicorn
from fastapi import FastAPI

# Create app
app = FastAPI()

@app.get("/name")
def get_name(first: str = "", last: str = ""):
    return f"{first} {last} is the best"


# Initialize API
if __name__ == "__main__":

    # Run app
    uvicorn.run(app, port=8001, host="0.0.0.0")
