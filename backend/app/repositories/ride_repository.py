from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.ride import Ride


class RideRepository:

    def __init__(self, db: Session):
        self.db = db

    def create(self, ride: Ride):
        self.db.add(ride)
        self.db.commit()
        self.db.refresh(ride)
        return ride

    def get_by_id(self, ride_id: int):
        return self.db.get(Ride, ride_id)

    def assign_driver(
        self,
        ride: Ride,
        driver_id: int,
    ):
        ride.driver_id = driver_id
        ride.status = "accepted"

        self.db.commit()
        self.db.refresh(ride)

        return ride