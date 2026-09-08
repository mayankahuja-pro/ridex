from fastapi import WebSocket


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

    def disconnect(self, user_id: int):
        self.connections.pop(user_id, None)

    async def send_to_user(
        self,
        user_id: int,
        message: dict,
    ):
        websocket = self.connections.get(user_id)

        if websocket:
            await websocket.send_json(message)


manager = ConnectionManager()