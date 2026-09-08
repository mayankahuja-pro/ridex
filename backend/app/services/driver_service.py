from fastapi import HTTPException, status

from app.models.driver import Driver
from app.repositories.driver_repository import DriverRepository
from app.schemas.driver import DriverCreate


class DriverService:

    def __init__(self, db):
        self.repository = DriverRepository(db)

    def create_driver(
        self,
        user_id: int,
        data: DriverCreate,
    ):
        existing_driver = self.repository.get_by_user_id(user_id)

        if existing_driver:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Driver profile already exists",
            )

        driver = Driver(
            user_id=user_id,
            vehicle_number=data.vehicle_number,
            vehicle_type=data.vehicle_type,
        )

        return self.repository.create(driver)

    def get_driver(self, user_id: int):
        driver = self.repository.get_by_user_id(user_id)

        if not driver:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Driver profile not found",
            )

        return driver
    

    def set_online_status(
        self,
        user_id: int,
        is_online: bool,
    ):
        driver = self.repository.get_by_user_id(user_id)

        if not driver:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Driver profile not found",
            )

        driver.is_online = is_online

        self.repository.db.commit()
        self.repository.db.refresh(driver)

        return driver