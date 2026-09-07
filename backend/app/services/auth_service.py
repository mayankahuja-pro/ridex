from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import (
    create_access_token,
    hash_password,
    verify_password,
)
from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.schemas.auth import (
    LoginRequest,
    RegisterRequest,
)


class AuthService:

    def __init__(self, db: Session):
        self.user_repository = UserRepository(db)

    def register(self, data: RegisterRequest):

        existing_user = self.user_repository.get_by_phone(
            data.phone
        )

        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Phone number already registered",
            )

        user = User(
            name=data.name,
            phone=data.phone,
            email=data.email,
            password_hash=hash_password(data.password),
            role=data.role,
        )

        return self.user_repository.create(user)

    def login(self, data: LoginRequest):

        user = self.user_repository.get_by_phone(
            data.phone
        )

        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid phone or password",
            )

        if not verify_password(
            data.password,
            user.password_hash,
        ):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid phone or password",
            )

        token = create_access_token(
            user_id=user.id,
            role=user.role,
        )

        return token