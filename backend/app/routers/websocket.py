from app.services.location_service import LocationService
from fastapi import (
    APIRouter,
    Depends,
    WebSocket,
    WebSocketDisconnect,
)
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.repositories.ride_repository import RideRepository
from app.websocket.manager import manager

router = APIRouter(
    tags=["WebSocket"],
)


@router.websocket("/ws/{user_id}")
async def websocket_endpoint(
    websocket: WebSocket,
    user_id: int,
    db: Session = Depends(get_db),
):
    await manager.connect(
        user_id,
        websocket,
    )

    try:
        while True:

            data = await websocket.receive_json()

            message_type = data.get("type")

            if message_type == "driver_location":

                driver_id = data["driver_id"]
                latitude = data["latitude"]
                longitude = data["longitude"]

                # Store latest location in Redis
                LocationService.update_location(
                    driver_id=driver_id,
                    latitude=latitude,
                    longitude=longitude,
                )

                # Find driver's active ride
                repository = RideRepository(db)

                ride = repository.get_active_ride_by_driver(
                    driver_id
                )

                if ride:

                    # Send location only to customer
                    await manager.send_to_user(
                        ride.customer_id,
                        {
                            "type": "driver_location",
                            "ride_id": ride.id,
                            "driver_id": driver_id,
                            "latitude": latitude,
                            "longitude": longitude,
                        },
                    )

    except WebSocketDisconnect:
        manager.disconnect(user_id)