from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user, require_role
from app.models.payment import Payment
from app.models.ride import Ride
from app.models.user import User
from app.schemas import ride
from app.schemas.payment import PaymentCreate, PaymentResponse
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
    ride = db.get(Ride, ride_id)
    if not ride:
        raise HTTPException(
            status_code=404,
            detail="Ride not found",
        )

   
    amount = ride.fare

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
    ride = db.get(Ride, ride_id)

    if not ride:
        raise HTTPException(
            status_code=404,
            detail="Ride not found",
        )

    if ride.customer_id != current_user.id:
        raise HTTPException(
            status_code=404,
            detail="Ride not found",
        )

    service = PaymentService(db)

    return service.mark_success(
        ride_id=ride_id,
    )

# 
@router.post("/{ride_id}/pay")
def pay_for_ride(
    ride_id: int,
    data: PaymentCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    ride = db.get(Ride, ride_id)

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
            detail="Ride is not completed",
        )

    existing_payment = db.scalar(
        select(Payment).where(
            Payment.ride_id == ride_id
        )
    )

    if existing_payment:
        return existing_payment

    payment = Payment(
        ride_id=ride.id,
        amount=ride.fare,
        method=data.method,
        status="paid",
    )

    db.add(payment)
    db.commit()
    db.refresh(payment)

    return payment