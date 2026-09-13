from fastapi import FastAPI
from app.core import firebase
from app.routers.driver import router as driver_router
from app.routers.auth import router as auth_router
from app.routers.ride import router as ride_router
from app.routers.websocket import router as websocket_router

from app.routers.payment import router as payment_router
from app.routers.rating import router as rating_router
from app.routers.notifications import router as notification_router
from app.core.database import Base, engine
from app.models import (
    User,
    Driver,
    Ride,
    Payment,
    Rating,
)
from fastapi.middleware.cors import CORSMiddleware


app = FastAPI(
    title="RideX API",
    version="1.0.0",
)

# Add CORS middleware to handle OPTIONS preflight requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],            # Allows all origins (or specify your Flutter web port)
    allow_credentials=True,
    allow_methods=["*"],            # Allows OPTIONS, POST, GET, etc.
    allow_headers=["*"],
)




Base.metadata.create_all(bind=engine)
app.include_router(auth_router)
app.include_router(ride_router)
app.include_router(driver_router)
app.include_router(websocket_router)
app.include_router(payment_router)
app.include_router(rating_router)
app.include_router(notification_router)
Base.metadata.create_all(bind=engine)

 

@app.get("/")
async def root():
    return {
        "message": "RideX API is running"
    }