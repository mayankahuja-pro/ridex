from fastapi import FastAPI
from app.routers.driver import router as driver_router
from app.routers.auth import router as auth_router
from app.routers.ride import router as ride_router
from app.routers.websocket import router as websocket_router

from app.routers.payment import router as payment_router
from app.routers.rating import router as rating_router

from app.core.database import Base, engine
from app.models import (
    User,
    Driver,
    Ride,
    Payment,
    Rating,
)
 


app = FastAPI(
    title="RideX API",
    version="1.0.0",
)

app.include_router(auth_router)
app.include_router(ride_router)
app.include_router(driver_router)
app.include_router(websocket_router)
app.include_router(payment_router)
app.include_router(rating_router)
Base.metadata.create_all(bind=engine)

 

@app.get("/")
async def root():
    return {
        "message": "RideX API is running"
    }