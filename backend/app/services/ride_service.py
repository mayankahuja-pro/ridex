from app.models import ride
from fastapi import HTTPException, status

from app.models.ride import Ride
from app.repositories.ride_repository import RideRepository
from app.schemas.ride import RideCreate
from app.services.fare_service import FareService
from app.services.location_service import LocationService
from app.core.constants import RideStatus

class RideService:

    def __init__(self, db):
        self.repository = RideRepository(db)

    async def create_ride(
        self,
        customer_id: int,
        data: RideCreate,
    ):

        fare = FareService.calculate_fare(
            data.pickup_lat,
            data.pickup_lng,
            data.destination_lat,
            data.destination_lng,
        )

        nearby_drivers = LocationService.get_nearby_drivers(
            latitude=data.pickup_lat,
            longitude=data.pickup_lng,
            radius_km=5,
            limit=5
        )

        if not nearby_drivers:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No nearby drivers available",
            )

        ride = Ride(
            customer_id=customer_id,
            pickup_lat=data.pickup_lat,
            pickup_lng=data.pickup_lng,
            destination_lat=data.destination_lat,
            destination_lng=data.destination_lng,
            fare=fare,
            status="searching",
        )

        return self.repository.create(ride)

    def accept_ride(
        self,
        ride_id: int,
        driver_id: int,
    ):

        ride = self.repository.get_for_update(
            ride_id
        )

        if not ride:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Ride not found",
            )

        if ride.status != RideStatus.SEARCHING:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Ride is no longer available",
            )

        ride.driver_id = driver_id
        ride.status = RideStatus.ACCEPTED

        self.repository.db.commit()
        self.repository.db.refresh(ride)

        return ride

    async def update_status(
    self,
    ride_id: int,
    new_status: str,
):

        ride = self.repository.get_by_id(ride_id)

        if not ride:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Ride not found",
            )

        allowed_transitions = {
            RideStatus.SEARCHING: [
                RideStatus.ACCEPTED,
                RideStatus.CANCELLED,
            ],
            RideStatus.ACCEPTED: [
                RideStatus.ARRIVING,
                RideStatus.CANCELLED,
            ],
            RideStatus.ARRIVING: [
                RideStatus.ARRIVED,
                RideStatus.CANCELLED,
            ],
            RideStatus.ARRIVED: [
                RideStatus.STARTED,
            ],
            RideStatus.STARTED: [
                RideStatus.COMPLETED,
            ],
        }

        if new_status not in allowed_transitions.get(
            ride.status,
            [],
        ):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Cannot change ride from "
                    f"{ride.status} to {new_status}",
            )

        ride.status = new_status

        self.repository.db.commit()
        self.repository.db.refresh(ride)

        return ride