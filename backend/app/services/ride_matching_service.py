from app.services.location_service import LocationService


class RideMatchingService:

    @staticmethod
    def find_nearby_drivers(
        latitude: float,
        longitude: float,
    ):
        return LocationService.get_nearby_drivers(
            latitude=latitude,
            longitude=longitude,
            radius_km=5,
            limit=5,
        )