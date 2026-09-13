from pydantic import BaseModel


class RideCreate(BaseModel):
    pickup_lat: float
    pickup_lng: float
    destination_lat: float
    destination_lng: float


class RideResponse(BaseModel):
    id: int
    customer_id: int
    driver_id: int | None
    pickup_lat: float
    pickup_lng: float
    destination_lat: float
    destination_lng: float
    fare: float
    status: str

    model_config = {
        "from_attributes": True
    }


class FareEstimateRequest(BaseModel):
    pickup_lat: float
    pickup_lng: float
    destination_lat: float
    destination_lng: float


class FareEstimateResponse(BaseModel):
    distance_km: float
    fare: float