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

    async def send_to_user(self, user_id: int, message: dict):

        print("====================================")
        print("WEBSOCKET SEND")
        print("user_id:", user_id)
        print("message:", message)
        print(
            "connected:",
            user_id in self.connections
        )
        print(
            "active connections:",
            list(self.connections.keys())
        )
        print("====================================")

        websocket = self.connections.get(user_id)

        if not websocket:
            print(
                f"❌ NO WEBSOCKET CONNECTION FOR user_id={user_id}"
            )
            return False

        try:
            await websocket.send_json(message)

            print(
                f"✅ WEBSOCKET MESSAGE SENT TO user_id={user_id}"
            )

            return True

        except Exception as e:
            print(
                f"❌ WEBSOCKET SEND ERROR user_id={user_id}: {e}"
            )
            return False

    def is_connected(self, user_id: int) -> bool:
        return user_id in self.connections

manager = ConnectionManager()