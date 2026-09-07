from fastapi import FastAPI

from app.core.database import Base, engine
from app.models import (
    User,
    Driver,
    Ride,
    Payment,
    Rating,
)
 
from app.routers.auth import router as auth_router


app = FastAPI(
    title="RideX API",
    version="1.0.0",
)

app.include_router(auth_router)
Base.metadata.create_all(bind=engine)

 

@app.get("/")
async def root():
    return {
        "message": "RideX API is running"
    }