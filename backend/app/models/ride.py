from sqlalchemy import Float, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class Ride(Base):
    __tablename__ = "rides"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        index=True,
    )

    customer_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        nullable=False,
    )

    driver_id: Mapped[int | None] = mapped_column(
        ForeignKey("drivers.id"),
        nullable=True,
    )

    pickup_lat: Mapped[float] = mapped_column(
        Float,
        nullable=False,
    )

    pickup_lng: Mapped[float] = mapped_column(
        Float,
        nullable=False,
    )

    destination_lat: Mapped[float] = mapped_column(
        Float,
        nullable=False,
    )

    destination_lng: Mapped[float] = mapped_column(
        Float,
        nullable=False,
    )

    fare: Mapped[float] = mapped_column(
        Float,
        nullable=False,
    )

    status: Mapped[str] = mapped_column(
        String(30),
        default="searching",
        nullable=False,
    )

    customer = relationship(
        "User",
        back_populates="rides",
    )

    driver = relationship(
        "Driver",
        back_populates="rides",
    )

    payment = relationship(
        "Payment",
        back_populates="ride",
        uselist=False,
    )

    rating = relationship(
        "Rating",
        back_populates="ride",
        uselist=False,
    )