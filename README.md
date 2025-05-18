# 📱 SnapNBook

**SnapNBook** is a cross-platform Flutter application for booking appliance repair or service appointments via smart image detection. It supports two roles:

* **User** – capture an appliance photo, detect its type, choose a time slot, and book a service.
* **Technician** – view assigned jobs, manage job status, and receive service requests.

---

## 📦 Features

### 👤 Authentication

* Secure signup and login using **AWS Cognito**
* Role-based access (`user` or `technician`)
* Token-based session management (in progress)
* `flutter_secure_storage` integration for persistent login (planned)

### 🧠 AI-Powered Appliance Detection

* Uses a YOLO backend to detect appliances from a photo

### 🛠 Booking (User)

* Select available date and time slots
* Address input and booking confirmation
* Submits booking via API with user, appliance, and time info

### 📋 Technician Dashboard

* View assigned jobs
* Filter jobs by status (Upcoming, In Progress, Completed) (in progress)
* Accept or reject incoming requests (planned)

---

## 🧰 Tech Stack

| Layer            | Technology                                |
| ---------------- | ----------------------------------------- |
| 🖥 Frontend      | Flutter (Riverpod + GoRouter)             |
| ☁️ Backend       | AWS Lambda + API Gateway + DynamoDB       |
| 🔐 Auth          | AWS Cognito                               |
| 🧠 Detection API | YOLO Object Detection                     |
| 📦 State Mgmt    | Riverpod + FlutterSecureStorage (planned) |

---

## 📁 Folder Structure (Simplified)

```
lib/
├── features/
│   ├── auth/                 # Login, Signup UI
│   ├── user/                 # User-specific screens
│   │   ├── home/
│   │   ├── booking/
│   │   └── profile/
│   └── technician/           # Technician dashboard & views
├── shared/
│   ├── widgets/
│   └── layout/
├── services/                 # API and helper services
├── state/                    # Riverpod providers
├── routes/                   # GoRouter configuration
├── core/                     # Constants, themes
└── main.dart
```

---

## 🚀 Getting Started

### ✅ Prerequisites

* Flutter SDK (≥ 3.10.0)
* Dart ≥ 3.x
* Android Studio or VScode for emulator/device testing

### 🔧 Setup

```bash
git clone https://github.com/prarthana-majalikar/SnapNBook.git
cd SnapNBook
flutter pub get
```

---

### 📱 Run the App

```bash
flutter run
```

Or use emulator/device from Android Studio.

---

## 🔐 Auth Flow

1. **Signup**: Role-based account creation via AWS Cognito.
2. **Login**: Returns `id_token` and `access_token`.
3. **Token Decoding**: `custom:role` and `sub` extracted using `jwt_decoder`.
4. **Role-Based Routing**:

   * Users → `/`
   * Technicians → `/technician-home`

---

## 📷 Object Detection Flow

* User taps "Scan Appliance"
* Image is uploaded
* First detected object is extracted and sent to `ApplianceSelectionScreen`

---

## 📆 Booking Logic

* User selects date via a scrollable `DateSlider`
* Time slots are dynamically filtered:

  * Past slots are hidden for the current day
* Confirmation sheet shows summary
* Booking is POSTed
  
---

## 👨‍🔧 Technician Role (Planned)

* Receive jobs with location and user info
* Job status updates (accept, reject, complete)
* Push notifications integration

---

## 🔐 Environment Configuration

To avoid hardcoding secrets or URLs, use environment variables via:

* `.env` file + `flutter_dotenv` (planned)
* Or a `config.dart` file with constants (currently used)


---

## 🔒 Security Best Practices

* Use `flutter_secure_storage` to store tokens locally
* Never commit `.env` or API keys to version control
* Always validate tokens before sending API calls

---

## ✅ TODO

* [x] Role-based navigation
* [x] Booking flow with detection
* [x] Technician dashboard shell
* [ ] Job status updates (technician)
* [ ] Push notifications for job alerts
* [ ] Persistent sessions (auto login on app launch)
* [ ] API error handling with retry/snackbar

---

## 🧑‍💻 Contributing

1. Fork the repo
2. Create a feature branch
3. Commit your changes
4. Create a PR
