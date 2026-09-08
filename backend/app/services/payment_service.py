from fastapi import HTTPException

from app.models.payment import Payment
from app.repositories.payment_repository import PaymentRepository


class PaymentService:

    def __init__(self, db):
        self.repository = PaymentRepository(db)

    def create_payment(
        self,
        ride_id: int,
        amount: float,
    ):

        existing_payment = (
            self.repository.get_by_ride_id(ride_id)
        )

        if existing_payment:
            return existing_payment

        payment = Payment(
            ride_id=ride_id,
            amount=amount,
            status="pending",
        )

        return self.repository.create(payment)

    def mark_success(
        self,
        ride_id: int,
    ):

        payment = (
            self.repository.get_by_ride_id(ride_id)
        )

        if not payment:
            raise HTTPException(
                status_code=404,
                detail="Payment not found",
            )

        payment.status = "completed"

        self.repository.db.commit()
        self.repository.db.refresh(payment)

        return payment