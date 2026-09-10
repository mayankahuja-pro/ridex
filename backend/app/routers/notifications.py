from fastapi import APIRouter, Depends,HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.notification import FCMTokenRequest
from app.services.notification_service import NotificationService


router = APIRouter(
    prefix="/notifications",
    tags=["Notifications"],
)


@router.post("/token")
def save_fcm_token(
    data: FCMTokenRequest,
    current_user: User = Depends(
        get_current_user
    ),
    db: Session = Depends(get_db),
):
    service = NotificationService(db)

    service.save_fcm_token(
        user=current_user,
        token=data.token,
    )

    return {
        "message": "FCM token saved successfully"
    }

@router.post("/test")
def test_notification(
    current_user: User = Depends(get_current_user),
):
    if not current_user.fcm_token:
        raise HTTPException(
            status_code=400,
            detail="FCM token not found",
        )

    response = NotificationService.send_notification(
        token=current_user.fcm_token,
        title="RideX Test",
        body="FCM notification is working!",
    )

    return {
        "message": "Notification sent",
        "firebase_response": response,
    }