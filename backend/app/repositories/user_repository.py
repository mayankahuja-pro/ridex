from app.models import user
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.user import User


class UserRepository:

    def __init__(self, db: Session):
        self.db = db

    def get_by_phone(self, phone: str):
        statement = select(User).where(
            User.phone == phone
        )

        return self.db.scalar(statement)

    def create(self, user: User):
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)

        return user

    def update_fcm_token(
    self,
    user: User,
    token: str,):
        user.fcm_token = token

        self.db.commit()
        self.db.refresh(user)

        return user