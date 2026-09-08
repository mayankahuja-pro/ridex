from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.rating import Rating


class RatingRepository:

    def __init__(self, db: Session):
        self.db = db

    def get_by_ride_id(self, ride_id: int):
        statement = select(Rating).where(
            Rating.ride_id == ride_id
        )

        return self.db.scalar(statement)

    def create(self, rating: Rating):
        self.db.add(rating)
        self.db.commit()
        self.db.refresh(rating)

        return rating