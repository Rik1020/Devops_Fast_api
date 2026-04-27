from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def home():
    return {"message": "Docker is working congrats  🚀"}
