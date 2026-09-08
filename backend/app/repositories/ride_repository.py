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