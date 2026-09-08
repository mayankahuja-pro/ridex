from app.core.redis import redis_client


class LocationService:

    GEO_KEY = "drivers:locations"

    @staticmethod
    def update_location(
        driver_id: int,
        latitude: float,
        longitude: float,
    ):
        redis_client.geoadd(
            LocationService.GEO_KEY,
            (longitude, latitude, str(driver_id)),
        )

    @staticmethod
    def get_nearby_drivers(
        latitude: float,
        longitude: float,
        radius_km: float = 5,
    ):
        return redis_client.geosearch(
            LocationService.GEO_KEY,
            longitude=longitude,
            latitude=latitude,
            radius=radius_km,
            unit="km",
            withcoord=True,
            withdist=True,
        )