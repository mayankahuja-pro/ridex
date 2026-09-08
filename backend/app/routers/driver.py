from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user, require_role
from app.models.user import User
from app.schemas.driver import DriverCreate, DriverResponse
from app.services.driver_service import DriverService


router = APIRouter(
    prefix="/drivers",
    tags=["Drivers"],
)


@router.post(
    "/profile",
    response_model=DriverResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_driver_profile(
    data: DriverCreate,
    current_user: User = Depends(require_role("driver")),
    db: Session = Depends(get_db),
):
    service = DriverService(db)

    return service.create_driver(
        user_id=current_user.id,
        data=data,
    )


@router.get(
    "/me",
    response_model=DriverResponse,
)
def get_my_driver_profile(
    current_user: User = Depends(require_role("driver")),
    db: Session = Depends(get_db),
):
    service = DriverService(db)

    return service.get_driver(
        user_id=current_user.id
    )


@router.patch(
    "/status",
    response_model=DriverResponse,
)
def update_driver_status(
    is_online: bool,
    current_user: User = Depends(
        require_role("driver")
    ),
    db: Session = Depends(get_db),
):
    service = DriverService(db)

    return service.set_online_status(
        user_id=current_user.id,
        is_online=is_online,
    )