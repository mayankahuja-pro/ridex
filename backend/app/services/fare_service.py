from math import radians, sin, cos, sqrt, atan2


class FareService:

    BASE_FARE = 30
    PER_KM = 10

    @staticmethod
    def calculate_distance(
        lat1: float,
        lng1: float,
        lat2: float,
        lng2: float,
    ) -> float:

        earth_radius = 6371

        dlat = radians(lat2 - lat1)
        dlng = radians(lng2 - lng1)

        a = (
            sin(dlat / 2) ** 2
            + cos(radians(lat1))
            * cos(radians(lat2))
            * sin(dlng / 2) ** 2
        )

        c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earth_radius * c

    @classmethod
    def calculate_fare(
        cls,
        pickup_lat,
        pickup_lng,
        destination_lat,
        destination_lng,
    ):

        distance = cls.calculate_distance(
            pickup_lat,
            pickup_lng,
            destination_lat,
            destination_lng,
        )

        fare = cls.BASE_FARE + (
            distance * cls.PER_KM
        )

        return round(fare, 2)