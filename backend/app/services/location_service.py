from app.core.redis import redis_client


class LocationService:
    GEO_KEY = "drivers:locations"
    ONLINE_KEY = "drivers:online"

    @staticmethod
    def set_driver_online(driver_id: int):
        redis_client.sadd(
            LocationService.ONLINE_KEY,
            driver_id,
        )

    @staticmethod
    def set_driver_offline(driver_id: int):
        redis_client.srem(
            LocationService.ONLINE_KEY,
            driver_id,
        )

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
        limit: int = 5,
    ):
        nearby = redis_client.geosearch(
            LocationService.GEO_KEY,
            longitude=longitude,
            latitude=latitude,
            radius=radius_km,
            unit="km",
            withcoord=True,
            withdist=True,
            count=limit,
            sort="ASC",
        )

        online_drivers = redis_client.smembers(
            LocationService.ONLINE_KEY
        )

        return [
            driver
            for driver in nearby
            if str(driver[0]) in online_drivers
        ]