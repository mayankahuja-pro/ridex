from sqlalchemy import Boolean, Float, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class Driver(Base):
    __tablename__ = "drivers"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        index=True,
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        unique=True,
        nullable=False,
    )

    vehicle_number: Mapped[str] = mapped_column(
        String(20),
        unique=True,
        nullable=False,
    )

    vehicle_type: Mapped[str] = mapped_column(
        String(20),
        default="bike",
        nullable=False,
    )

    is_online: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
    )

    user = relationship(
        "User",
        back_populates="driver",
    )

    rides = relationship(
        "Ride",
        back_populates="driver",
    )