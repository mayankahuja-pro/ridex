import asyncio

from sqlalchemy.orm import Session

from app.core.constants import RideStatus
from app.core.redis import redis_client
from app.services.location_service import LocationService
from app.websocket.manager import manager


class RideMatchingService:

    REQUEST_TIMEOUT = 10

    def __init__(self, db: Session):
        self.db = db

    async def start_matching(self, ride_id: int):

        from app.models.ride import Ride

        ride = self.db.get(Ride, ride_id)

        if not ride:
            return

        nearby_drivers = LocationService.get_nearby_drivers(
            latitude=ride.pickup_lat,
            longitude=ride.pickup_lng,
            radius_km=5,
            limit=5,
        )

        if not nearby_drivers:
            ride.status = RideStatus.CANCELLED
            self.db.commit()
            return

        for driver_data in nearby_drivers:

            # Ride already accepted/cancelled?
            self.db.refresh(ride)

            if ride.status != RideStatus.SEARCHING:
                return

            driver_id = int(driver_data[0])

            # Store the ride request in Redis so accept_ride can verify it
            redis_client.set(
                f"ride:{ride_id}:driver:{driver_id}",
                "pending",
                ex=self.REQUEST_TIMEOUT,
            )

            # Send request to driver via WebSocket
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
                    "expires_in": self.REQUEST_TIMEOUT,
                },
            )

            # Wait for driver's response
            await asyncio.sleep(self.REQUEST_TIMEOUT)

            # Clean up Redis key if driver didn't accept in time
            redis_client.delete(f"ride:{ride_id}:driver:{driver_id}")

            # Check ride again
            self.db.refresh(ride)

            if ride.status != RideStatus.SEARCHING:
                return

        # No driver accepted
        ride.status = RideStatus.CANCELLED
        self.db.commit()

        await manager.send_to_user(
            ride.customer_id,
            {
                "type": "ride_status",
                "ride_id": ride.id,
                "status": RideStatus.CANCELLED,
                "message": "No driver accepted the ride",
            },
        )