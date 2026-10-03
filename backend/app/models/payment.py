from datetime import datetime
from decimal import Decimal

from sqlalchemy import ForeignKey, String, DateTime, Integer, Numeric
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Payment(Base):
    __tablename__ = "payments"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
    )

    ride_id: Mapped[int] = mapped_column(
        ForeignKey("rides.id"),
        unique=True,
        nullable=False,
    )

    amount: Mapped[Decimal] = mapped_column(
        Numeric(10, 2),
        nullable=False,
    )

    method: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        default="cash",
    )

    status: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        default="pending",
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
    )
