import json

from app.core.redis import redis_client
from app.websocket.manager import manager

class RideMatchingService:

    REQUEST_TTL = 10

    @staticmethod
    def create_driver_request(
        ride_id: int,
        driver_id: int,
    ):
        key = f"ride:{ride_id}:driver:{driver_id}"

        redis_client.setex(
            key,
            RideMatchingService.REQUEST_TTL,
            json.dumps({
                "ride_id": ride_id,
                "driver_id": driver_id,
                "status": "pending",
            }),
        )

    @staticmethod
    def get_driver_request(
        ride_id: int,
        driver_id: int,
    ):
        key = f"ride:{ride_id}:driver:{driver_id}"

        data = redis_client.get(key)

        if not data:
            return None

        return json.loads(data)

    @staticmethod
    def delete_driver_request(
        ride_id: int,
        driver_id: int,
    ):
        key = f"ride:{ride_id}:driver:{driver_id}"

        redis_client.delete(key)

    @staticmethod
    async def send_ride_request(
        ride,
        driver_id: int,
    ):
        RideMatchingService.create_driver_request(
            ride_id=ride.id,
            driver_id=driver_id,
        )

        await manager.send_to_user(
            driver_id,
            {
                "type": "ride_request",
                "ride_id": ride.id,
                "pickup": {
                    "lat": ride.pickup_lat,
                    "lng": ride.pickup_lng,
                },
                "destination": {
                    "lat": ride.destination_lat,
                    "lng": ride.destination_lng,
                },
                "fare": ride.fare,
                "expires_in": 10,
            },
        )