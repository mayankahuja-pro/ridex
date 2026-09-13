from app.models import ride
from fastapi import APIRouter, Depends, status,BackgroundTasks
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import require_role
from app.models.user import User
from app.schemas.ride import RideCreate, RideResponse
from app.services.ride_service import RideService
from app.services.driver_service import DriverService
from app.services.ride_matching_service import RideMatchingService
from app.services.notification_service import NotificationService
from app.websocket.manager import manager 
from app.core.constants import RideStatus
from app.models.user import User

from app.services.fare_service import FareService

from app.schemas.ride import FareEstimateRequest, FareEstimateResponse





router = APIRouter(
    prefix="/rides",
    tags=["Rides"],
)


@router.get(
    "/{ride_id}",
    response_model=RideResponse,
)
def get_customer_ride(
    ride_id: int,
    current_user: User = Depends(require_role("customer")),
    db: Session = Depends(get_db),
):
    return RideService(db).get_customer_ride(
        ride_id=ride_id,
        customer_id=current_user.id,
    )

# api to create a ride 
@router.post(
    "",
    response_model=RideResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_ride(
    data: RideCreate,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(require_role("customer")),
    db: Session = Depends(get_db),
):
    service = RideService(db)

    ride = await service.create_ride(
        customer_id=current_user.id,
        data=data,
    )

    background_tasks.add_task(
        RideMatchingService(db).start_matching,
        ride.id,
    )
    return ride

# api to accept a ride 
@router.post(
    "/{ride_id}/accept",
    response_model=RideResponse,
)
async def accept_ride(
    ride_id: int,
    current_user: User = Depends(require_role("driver")),
    db: Session = Depends(get_db),
):
    service = RideService(db)
  
    driver_service = DriverService(db)

    driver = driver_service.get_driver(current_user.id)
    

    ride = service.accept_ride(
        ride_id=ride_id,
        driver_id=driver.id,
    )

    customer = db.get(User, ride.customer_id)

    if customer:
        NotificationService.send_to_user(
            user=customer,
            title="Ride Accepted",
            body="Your driver has accepted the ride.",
            data={
                "type": "ride_accepted",
                "ride_id": ride_id,
            },
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
async def update_ride_status(
    ride_id: int,
    new_status: str,
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

    ride = await service.update_status(
        ride_id=ride_id,
        driver_id=driver.id,
        new_status=new_status,
    )

    if new_status == RideStatus.ARRIVING:
        customer = db.get(User, ride.customer_id)

        if customer:
            NotificationService.send_to_user(
                user=customer,
                title="Driver Arriving",
                body="Your driver is on the way.",
                data={
                    "type": "driver_arriving",
                    "ride_id": ride.id,
                },
            )

    if new_status == RideStatus.COMPLETED:
        customer = db.get(User, ride.customer_id)

        if customer:
            NotificationService.send_to_user(
                user=customer,
                title="Ride Completed",
                body="Your ride has been completed.",
                data={
                    "type": "ride_completed",
                    "ride_id": ride.id,
                },
            )

    await manager.send_to_user(
        ride.customer_id,
        {
            "type": "ride_status",
            "ride_id": ride.id,
            "status": ride.status,
        },
    )

    return ride


# api to cancel a ride 
@router.post(
    "/{ride_id}/cancel",
    response_model=RideResponse,
)
async def cancel_ride(
    ride_id: int,
    current_user: User = Depends(
        require_role("customer")
    ),
    db: Session = Depends(get_db),
):
    service = RideService(db)

    ride = service.cancel_ride(
        ride_id=ride_id,
        customer_id=current_user.id,
    )
# api to estimate fare
@router.post(
    "/estimate",
    response_model=FareEstimateResponse,
)
def estimate_fare(
    data: FareEstimateRequest,
    current_user: User = Depends(
        require_role("customer")
    ),
):
    distance = FareService.calculate_distance(
        data.pickup_lat,
        data.pickup_lng,
        data.destination_lat,
        data.destination_lng,
    )

    fare = FareService.calculate_fare(
        data.pickup_lat,
        data.pickup_lng,
        data.destination_lat,
        data.destination_lng,
    )

    return {
        "distance_km": round(distance, 2),
        "fare": round(fare, 2),
    }