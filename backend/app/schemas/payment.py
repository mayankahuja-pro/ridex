from pydantic import BaseModel


class PaymentResponse(BaseModel):
    id: int
    ride_id: int
    amount: float
    status: str

    model_config = {
        "from_attributes": True
    }