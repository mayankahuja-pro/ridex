from app.models import ride
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import require_role
from app.models.user import User
from app.schemas.ride import RideCreate, RideResponse
from app.services.ride_service import RideService
from app.services.driver_service import DriverService
from app.websocket.manager import manager
from app.core.constants import RideStatus

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

@router.post(
    "/{ride_id}/accept",
    response_model=RideResponse,
)
async def accept_ride(
    ride_id: int,
    current_user: User = Depends(
        require_role("driver")
    ),
    db: Session = Depends(get_db),
):

    driver_service = DriverService(db)

    driver = driver_service.get_driver(
        current_user.id
    )

    service = RideService(db)

    return service.accept_ride(
        ride_id=ride_id,
        driver_id=driver.id,
    )
    ride = service.accept_ride(
    ride_id=ride_id,
    driver_id=driver.id,
)

    await manager.send_to_user(
        ride.customer_id,
        {
            "type": "ride_accepted",
            "ride_id": ride.id,
            "driver_id": ride.driver_id,
            "status": ride.status,
        },
    )

    return ride
        

# api to update the status of a ride 

@router.patch(
    "/{ride_id}/status",
    response_model=RideResponse,
)
def update_ride_status(
    ride_id: int,
    new_status: str,
    current_user: User = Depends(
        require_role("driver")
    ),
    db: Session = Depends(get_db),
):
    service = RideService(db)

    return service.update_status(
        ride_id=ride_id,
        new_status=new_status,
    )