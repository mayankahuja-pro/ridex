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