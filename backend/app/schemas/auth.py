from pydantic import BaseModel, EmailStr


class RegisterRequest(BaseModel):
    name: str
    phone: str
    email: EmailStr | None = None
    password: str
    role: str = "customer"


class LoginRequest(BaseModel):
    phone: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"