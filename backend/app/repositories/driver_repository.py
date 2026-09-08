from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.driver import Driver


class DriverRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_user_id(self, user_id: int):
        statement = select(Driver).where(
            Driver.user_id == user_id
        )
        return self.db.scalar(statement)

    def create(self, driver: Driver):
        self.db.add(driver)
        self.db.commit()
        self.db.refresh(driver)

        return driver