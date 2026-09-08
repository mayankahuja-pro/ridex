from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from app.websocket.manager import manager


router = APIRouter(
    tags=["WebSocket"],
)


@router.websocket("/ws/{user_id}")
async def websocket_endpoint(
    websocket: WebSocket,
    user_id: int,
):
    await manager.connect(
        user_id,
        websocket,
    )

    try:
        while True:
            data = await websocket.receive_json()

            print(
                f"Message from {user_id}: {data}"
            )

    except WebSocketDisconnect:
        manager.disconnect(user_id)