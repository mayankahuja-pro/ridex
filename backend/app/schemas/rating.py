from pydantic import BaseModel, Field


class RatingCreate(BaseModel):
    ride_id: int
    rating: int = Field(
        ge=1,
        le=5,
    )
    comment: str | None = None


class RatingResponse(BaseModel):
    id: int
    ride_id: int
    customer_id: int
    driver_id: int
    rating: int

    model_config = {
        "from_attributes": True
    }