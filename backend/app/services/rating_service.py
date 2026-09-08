from fastapi import HTTPException, status

from app.models.rating import Rating
from app.repositories.rating_repository import RatingRepository


class RatingService:

    def __init__(self, db):
        self.repository = RatingRepository(db)

    def create_rating(
        self,
        customer_id: int,
        ride,
        rating_value: int,
    ):

        if ride.status != "completed":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Ride is not completed",
            )

        if ride.customer_id != customer_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You cannot rate this ride",
            )

        if not ride.driver_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Ride has no driver",
            )

        existing_rating = (
            self.repository.get_by_ride_id(ride.id)
        )

        if existing_rating:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Ride already rated",
            )

        rating = Rating(
            ride_id=ride.id,
            customer_id=customer_id,
            driver_id=ride.driver_id,
            rating=rating_value,
        )

        return self.repository.create(rating)