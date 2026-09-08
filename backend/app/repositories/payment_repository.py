from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.payment import Payment


class PaymentRepository:

    def __init__(self, db: Session):
        self.db = db

    def get_by_ride_id(self, ride_id: int):
        statement = select(Payment).where(
            Payment.ride_id == ride_id
        )

        return self.db.scalar(statement)

    def create(self, payment: Payment):
        self.db.add(payment)
        self.db.commit()
        self.db.refresh(payment)

        return payment