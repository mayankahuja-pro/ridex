from fastapi import WebSocket, WebSocketDisconnect


class ConnectionManager:

    def __init__(self):
        self.connections: dict[int, WebSocket] = {}

    async def connect(
        self,
        user_id: int,
        websocket: WebSocket,
    ):
        await websocket.accept()

        self.connections[user_id] = websocket

    def disconnect(self, user_id: int, websocket: WebSocket):
        if self.connections.get(user_id) is websocket:
            self.connections.pop(user_id, None)

    async def send_to_user(
        self,
        user_id: int,
        message: dict,
    ):
        websocket = self.connections.get(user_id)

        if websocket:
            try:
                await websocket.send_json(message)
            except (WebSocketDisconnect, RuntimeError, OSError):
                self.disconnect(user_id, websocket)


manager = ConnectionManager()