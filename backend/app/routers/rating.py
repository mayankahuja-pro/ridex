from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user, require_role
from app.models.rating import Rating
from app.models.ride import Ride
from app.models.user import User
from app.schemas.rating import (
    RatingCreate,
    RatingResponse,
)
from app.services.rating_service import RatingService


router = APIRouter(
    prefix="/ratings",
    tags=["Ratings"],
)


@router.post("")
def create_rating(
    data: RatingCreate,
    current_user: User = Depends(
        get_current_user
    ),
    db: Session = Depends(get_db),
):
    if data.rating < 1 or data.rating > 5:
        raise HTTPException(
            status_code=400,
            detail="Rating must be between 1 and 5",
        )

    ride = db.get(Ride, data.ride_id)

    if not ride:
        raise HTTPException(
            status_code=404,
            detail="Ride not found",
        )

    if ride.customer_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="Not your ride",
        )

    if ride.status != "completed":
        raise HTTPException(
            status_code=400,
            detail="Ride not completed",
        )

    rating = Rating(
        ride_id=ride.id,
        customer_id=current_user.id,
        driver_id=ride.driver_id,
        rating=data.rating,
        comment=data.comment,
    )

    db.add(rating)
    db.commit()
    db.refresh(rating)

    return rating