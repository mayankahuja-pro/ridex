from fastapi import FastAPI

from app.core.database import Base, engine
from app.models.user import User


Base.metadata.create_all(bind=engine)


app = FastAPI(
    title="RideX API",
    version="1.0.0",
)


@app.get("/")
async def root():
    return {
        "message": "RideX API is running"
    }