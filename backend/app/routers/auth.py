from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
 
from app.core.dependencies import get_current_user
from app.models.user import User
from app.core.database import get_db

from app.schemas.auth import (
    LoginRequest,
    RegisterRequest,
    TokenResponse,
)
from app.services.auth_service import AuthService


router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)

@router.get("/me")
def get_me(
    current_user: User = Depends(get_current_user),
):
    return {
        "id": current_user.id,
        "name": current_user.name,
        "phone": current_user.phone,
        "email": current_user.email,
        "role": current_user.role,
    }

@router.post(
    "/register",
    status_code=status.HTTP_201_CREATED,
)
def register(
    data: RegisterRequest,
    db: Session = Depends(get_db),
):
    service = AuthService(db)

    user = service.register(data)

    return {
        "id": user.id,
        "name": user.name,
        "phone": user.phone,
        "role": user.role,
    }


@router.post(
    "/login",
    response_model=TokenResponse,
)
def login(
    data: LoginRequest,
    db: Session = Depends(get_db),
):
    service = AuthService(db)

    token = service.login(data)

    return {
        "access_token": token,
        "token_type": "bearer",
    }