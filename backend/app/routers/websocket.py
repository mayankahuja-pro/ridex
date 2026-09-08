from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from app.services.location_service import LocationService
from app.websocket.manager import manager


router = APIRouter(
    tags=["WebSocket"],
)


@router.websocket("/ws/{user_id}")
async def websocket_endpoint(
    websocket: WebSocket,
    user_id: int,
):
    await manager.connect(user_id, websocket)

    try:
        while True:
            data = await websocket.receive_json()

            message_type = data.get("type")

            if message_type == "driver_location":
                latitude = data["latitude"]
                longitude = data["longitude"]
                driver_id = data["driver_id"]

                # Store latest location in Redis
                LocationService.update_location(
                    driver_id=driver_id,
                    latitude=latitude,
                    longitude=longitude,
                )

                print(
                    f"Driver {driver_id}: "
                    f"{latitude}, {longitude}"
                )

    except WebSocketDisconnect:
        manager.disconnect(user_id)