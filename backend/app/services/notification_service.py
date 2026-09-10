from firebase_admin import messaging

from app.repositories.user_repository import UserRepository


class NotificationService:

    def __init__(self, db):
        self.repository = UserRepository(db)

    def save_fcm_token(
        self,
        user,
        token: str,
    ):
        return self.repository.update_fcm_token(
            user=user,
            token=token,
        )

    @staticmethod
    def send_notification(
        token: str,
        title: str,
        body: str,
    ):
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            token=token,
        )

        return messaging.send(message)

    @staticmethod
    def send_to_user(
        user,
        title: str,
        body: str,
        data: dict | None = None,
    ):
        if not user.fcm_token:
            return None

        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data={
                key: str(value)
                for key, value in (data or {}).items()
            },
            token=user.fcm_token,
        )

        return messaging.send(message)