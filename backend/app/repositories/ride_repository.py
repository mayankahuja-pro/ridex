from app.core.constants import RideStatus
from sqlalchemy import select
from app.core.constants import RideStatus
from app.models.ride import Ride

 


class RideRepository:

    def __init__(self, db: Session):
        self.db = db

    # api to create a new ride
    def create(self, ride: Ride):
        self.db.add(ride)
        self.db.commit()
        self.db.refresh(ride)
        return ride
    
    # api to get the ride by ID
    def get_by_id(self, ride_id: int):
        return self.db.get(Ride, ride_id)
    
    # api to get the ride for update
    def get_for_update(self, ride_id: int):
        statement = (
            select(Ride)
            .where(Ride.id == ride_id)
            .with_for_update()
        )

        return self.db.scalar(statement)

    # api to assign a driver to a ride  
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

    # api to get the ride by ID and customer
    def get_by_id_and_customer(
        self,
        ride_id: int,
        customer_id: int,
    ):

        statement = (
            select(Ride)
            .where(
                Ride.id == ride_id,
                Ride.customer_id == customer_id,
            )
        )

        return self.db.scalar(statement)
    
    # api to get the active ride by driver
    def get_active_ride_by_driver(self, driver_id: int):
        statement = (
            select(Ride)
            .where(
                Ride.driver_id == driver_id,
                Ride.status.in_([
                    RideStatus.ACCEPTED,
                    RideStatus.ARRIVING,
                    RideStatus.ARRIVED,
                    RideStatus.STARTED,
                ]),
            )
        )

        return self.db.scalar(statement)