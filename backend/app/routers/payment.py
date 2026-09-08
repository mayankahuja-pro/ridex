from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import require_role
from app.models.user import User
from app.schemas.payment import PaymentResponse
from app.services.payment_service import PaymentService


router = APIRouter(
    prefix="/payments",
    tags=["Payments"],
)


@router.post(
    "/{ride_id}",
    response_model=PaymentResponse,
)
def create_payment(
    ride_id: int,
    current_user: User = Depends(
        require_role("customer")
    ),
    db: Session = Depends(get_db),
):

    # Temporary/mock amount.
    # Later we'll fetch it from the ride.
    amount = 280.45

    service = PaymentService(db)

    return service.create_payment(
        ride_id=ride_id,
        amount=amount,
    )


@router.post(
    "/{ride_id}/success",
    response_model=PaymentResponse,
)
def payment_success(
    ride_id: int,
    current_user: User = Depends(
        require_role("customer")
    ),
    db: Session = Depends(get_db),
):

    service = PaymentService(db)

    return service.mark_success(
        ride_id=ride_id,
    )