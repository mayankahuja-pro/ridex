# RideX — Real-Time Ride Hailing Platform

RideX is a full-stack ride-hailing platform inspired by modern services such as Rapido and Uber, built with **Flutter** and **FastAPI**.

The project focuses on real-world backend engineering concepts including JWT authentication, PostgreSQL, Redis GEO-based driver discovery, real-time WebSockets, Firebase Cloud Messaging, ride state management, concurrency control, payments, ratings, and live driver tracking.

---
<img width="819" height="805" alt="image" src="https://github.com/user-attachments/assets/22da3aae-d668-427c-804c-8aa35f706f79" />

## Overview

RideX provides separate experiences for customers and drivers.

### Customer

* Register and login
* Secure JWT authentication
* Automatic session handling
* Detect current location
* Select pickup and destination on Google Maps
* Get fare estimates
* Book rides
* Track ride status in real time
* Receive driver notifications
* Track driver location
* Complete rides
* Rate drivers

### Driver

* Driver profile management
* Vehicle information
* Go online/offline
* Share live location
* Receive ride requests
* Accept rides
* Update ride status
* Complete rides

---

## Tech Stack

### Frontend

* Flutter
* Dart
* Material 3
* Google Maps
* Geolocator
* Firebase Cloud Messaging
* WebSocket

### Backend

* Python
* FastAPI
* SQLAlchemy 2.0
* Pydantic v2
* PostgreSQL
* Redis
* JWT
* WebSockets
* Firebase Admin SDK
* Alembic

### DevOps / Infrastructure

* Docker
* Docker Compose
* Git
* GitHub
* AWS-ready architecture

---

## Architecture

```text
                    ┌─────────────────────┐
                    │     Customer App    │
                    │       Flutter       │
                    └──────────┬──────────┘
                               │
                        REST / WebSocket
                               │
                               ▼
                    ┌─────────────────────┐
                    │      FastAPI        │
                    │      Backend        │
                    └──────────┬──────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
              ▼                ▼                ▼
        PostgreSQL          Redis           Firebase
        SQLAlchemy        GEO + Cache          FCM
              │                │                │
              │                │                │
              ▼                ▼                ▼
          Ride Data      Driver Location     Push
          Users          Nearby Drivers      Notifications

                    ┌─────────────────────┐
                    │      Driver App      │
                    │       Flutter        │
                    └─────────────────────┘
```

---

## Core Features

### Authentication

RideX uses JWT-based authentication.

```text
Register
   ↓
Login
   ↓
JWT Access Token
   ↓
Secure Token Storage
   ↓
Authenticated APIs
```

Role-based access is implemented for customer and driver operations.

---

## Ride Booking

A customer can select a pickup location and destination using Google Maps.

The backend calculates the estimated fare using distance-based pricing.

```text
Pickup
   +
Destination
   ↓
Distance Calculation
   ↓
Fare Calculation
   ↓
Nearby Driver Search
   ↓
Ride Creation
```

---

## Nearby Driver Matching

Redis GEO is used to efficiently locate nearby drivers.

```text
Driver Online
      ↓
Redis GEO
      ↓
Driver Latitude / Longitude
      ↓
Customer Requests Ride
      ↓
Search Nearby Drivers
      ↓
Nearest Available Drivers
```

The system filters drivers based on online availability and geographic proximity.

---

## Sequential Ride Matching

Ride requests are distributed to nearby drivers sequentially.

```text
Customer Books Ride
        ↓
Driver A
   ↓ 10 sec
No Response
        ↓
Driver B
   ↓ 10 sec
No Response
        ↓
Driver C
        ↓
Accepted
        ↓
Matching Stops
```

This prevents multiple drivers from simultaneously accepting the same ride.

---

## Concurrency Control

Ride acceptance uses database row-level locking.

```python
SELECT ... FOR UPDATE
```

This prevents two drivers from successfully accepting the same ride when requests arrive concurrently.

The ride status is checked while the database row is locked before assigning the driver.

---

## Ride State Machine

Ride lifecycle is controlled through predefined states.

```text
SEARCHING
    ↓
ACCEPTED
    ↓
ARRIVING
    ↓
ARRIVED
    ↓
STARTED
    ↓
COMPLETED
```

Cancellation is allowed only during valid stages.

This prevents invalid transitions such as:

```text
COMPLETED → STARTED
STARTED → ACCEPTED
```

---

## Real-Time Communication

RideX uses WebSockets for real-time communication.

WebSockets are used for:

* Driver location updates
* Ride status updates
* Driver acceptance events
* Customer tracking
* Real-time ride events

Example:

```json
{
  "type": "ride_status",
  "ride_id": 12,
  "status": "accepted"
}
```

---

## Live Driver Tracking

The driver periodically sends location updates.

```text
Driver Flutter
      ↓
WebSocket
      ↓
FastAPI
      ↓
Redis GEO
      ↓
Active Ride
      ↓
Customer WebSocket
      ↓
Customer Map
```

This allows the customer to see the driver's live location during an active ride.

---

## Push Notifications

Firebase Cloud Messaging is integrated for push notifications.

Examples:

* Ride accepted
* Driver arriving
* Ride completed
* Other ride-related events

Architecture:

```text
FastAPI
   ↓
Firebase Admin SDK
   ↓
FCM
   ↓
Customer / Driver Device
```

FCM tokens are stored against authenticated users and refreshed when Firebase provides a new token.

---

## Payments

RideX includes a payment workflow with payment status management.

```text
Ride Completed
      ↓
Payment Created
      ↓
Pending
      ↓
Payment Success
```

The architecture is designed so a production payment gateway such as Razorpay or Stripe can be integrated.

---

## Ratings

Customers can rate a driver after a completed ride.

Rules include:

* Ride must be completed
* Customer must own the ride
* Ride must have an assigned driver
* Duplicate ratings are prevented
* Rating must be between 1 and 5

---

## Database Design

Main entities:

```text
User
 │
 └── Driver

User
 │
 └── Rides
        │
        ├── Payment
        │
        └── Rating
```

### Main Tables

| Table    | Purpose                        |
| -------- | ------------------------------ |
| users    | Customer and driver accounts   |
| drivers  | Driver and vehicle information |
| rides    | Ride booking and lifecycle     |
| payments | Ride payment information       |
| ratings  | Customer ratings               |

---

## Backend Structure

```text
backend/
│
├── app/
│   ├── core/
│   │   ├── config.py
│   │   ├── database.py
│   │   ├── security.py
│   │   ├── dependencies.py
│   │   ├── redis.py
│   │   └── constants.py
│   │
│   ├── models/
│   │
│   ├── schemas/
│   │
│   ├── routers/
│   │
│   ├── services/
│   │
│   ├── repositories/
│   │
│   └── websocket/
│
├── migrations/
├── tests/
├── Dockerfile
├── requirements.txt
└── .env
```

The backend follows a layered architecture:

```text
Router
   ↓
Service
   ↓
Repository
   ↓
SQLAlchemy
   ↓
PostgreSQL
```

This keeps API handling, business logic, and database operations separated.

---

## Flutter Structure

```text
lib/
│
├── core/
│   ├── constants/
│   ├── theme/
│   └── network/
│
├── models/
│
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── websocket_service.dart
│   ├── location_service.dart
│   └── notification_service.dart
│
├── screens/
│   ├── auth/
│   ├── home/
│   └── ride/
│
└── widgets/
```

---

## API Examples

### Authentication

```http
POST /auth/register
POST /auth/login
GET  /auth/me
```

### Drivers

```http
POST /drivers/profile
GET  /drivers/me
POST /drivers/status
POST /drivers/location
```

### Rides

```http
POST /rides/estimate
POST /rides
POST /rides/{ride_id}/accept
POST /rides/{ride_id}/status
POST /rides/{ride_id}/cancel
GET  /rides/{ride_id}
```

### Notifications

```http
POST /notifications/token
```

---

## Local Development

### Clone

```bash
git clone <your-repository-url>
cd ridex
```

### Start infrastructure

```bash
docker compose up -d
```

This starts:

* PostgreSQL
* Redis

### Backend setup

```bash
cd backend

python -m venv venv
```

Windows:

```bash
venv\Scripts\activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Run migrations:

```bash
alembic upgrade head
```

Start API:

```bash
uvicorn app.main:app --reload
```

API:

```text
http://localhost:8000
```

Swagger:

```text
http://localhost:8000/docs
```

---

## Environment Variables

Example:

```env
DATABASE_URL=postgresql+psycopg2://ridex:ridex_password@localhost:5432/ridex_db

REDIS_HOST=localhost
REDIS_PORT=6379

SECRET_KEY=your-secret-key

FIREBASE_CREDENTIALS_PATH=firebase-service-account.json
```

Never commit secrets, Firebase service-account credentials, or production environment files.

---

## Security

The project implements:

* JWT authentication
* Password hashing
* Role-based authorization
* Protected ride ownership
* Driver ride ownership validation
* Database row-level locking
* Ride state validation
* Secure token storage on Flutter
* Firebase credential protection

---

## Future Improvements

The current architecture can be extended with:

* Razorpay / Stripe production payments
* Redis Pub/Sub for multi-worker WebSocket scaling
* Background workers for ride matching
* Google Directions API
* ETA calculation
* Place autocomplete
* Driver earnings dashboard
* Admin dashboard
* Ride history
* Coupons and promotions
* Surge pricing
* Driver ratings aggregation
* Analytics
* AWS deployment
* CI/CD pipeline
* Automated tests

---

## What I Learned

Through RideX, I worked on practical backend and full-stack concepts including:

* REST API design
* FastAPI architecture
* SQLAlchemy 2.0
* PostgreSQL relational modeling
* Alembic migrations
* JWT authentication
* Role-based authorization
* Redis GEO
* Real-time WebSockets
* Firebase Cloud Messaging
* Concurrency control
* Database row locking
* Ride state machines
* Flutter API integration
* Google Maps integration
* Secure local token storage
* Docker-based development

---

## Author

**Mayank Ahuja**

Backend / Full Stack Developer

* Python
* FastAPI
* Flutter
* PostgreSQL
* Redis
* Docker

---

## License

This project is intended for learning, portfolio, and demonstration purposes.
