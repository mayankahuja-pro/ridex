from fastapi import HTTPException, status

from app.models.ride import Ride
from app.repositories.ride_repository import RideRepository
from app.schemas.ride import RideCreate
from app.services.fare_service import FareService
from app.services.location_service import LocationService


class RideService:

    def __init__(self, db):
        self.repository = RideRepository(db)

    def create_ride(
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