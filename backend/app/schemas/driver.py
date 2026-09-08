from pydantic import BaseModel


class DriverCreate(BaseModel):
    vehicle_number: str
    vehicle_type: str = "bike"


class DriverResponse(BaseModel):
    id: int
    user_id: int
    vehicle_number: str
    vehicle_type: str
    is_online: bool

    model_config = {
        "from_attributes": True
    }
class LocationUpdate(BaseModel):
    latitude: float
    longitude: float