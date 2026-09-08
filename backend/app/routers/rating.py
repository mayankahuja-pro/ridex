from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import require_role
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


@router.post(
    "",
    response_model=RatingResponse,
)
def create_rating(
    data: RatingCreate,
    current_user: User = Depends(
        require_role("customer")
    ),
    db: Session = Depends(get_db),
):

    ride = db.get(Ride, data.ride_id)

    if not ride:
        from fastapi import HTTPException

        raise HTTPException(
            status_code=404,
            detail="Ride not found",
        )

    service = RatingService(db)

    return service.create_rating(
        customer_id=current_user.id,
        ride=ride,
        rating_value=data.rating,
    )