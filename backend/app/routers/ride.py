from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import require_role
from app.models.user import User
from app.schemas.ride import RideCreate, RideResponse
from app.services.ride_service import RideService


router = APIRouter(
    prefix="/rides",
    tags=["Rides"],
)


@router.post(
    "",
    response_model=RideResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_ride(
    data: RideCreate,
    current_user: User = Depends(
        require_role("customer")
    ),
    db: Session = Depends(get_db),
):

    service = RideService(db)

    return service.create_ride(
        customer_id=current_user.id,
        data=data,
    )