# Fitness Dashboard – Flutter App

A production-ready Flutter mobile app with clean architecture, inspired by a modern fitness tracker UI.

## Tech Stack
- **Flutter** (latest stable) + Dart
- **Riverpod** for state management
- **Dio** for HTTP / API calls
- **fl_chart** for bar chart visualization
- **flutter_secure_storage** for token storage
- **Material 3** design system

## Backend
The app is designed to consume a **.NET 8 Web API** with SQL Server. API endpoint placeholders are configured in `lib/core/constants/api_constants.dart`.

## Getting Started

```bash
# 1. Clone / copy the flutter_project folder
cd flutter_project

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

> **Note:** The app includes demo/fallback data so it runs without a backend. When your .NET API is ready, update `baseUrl` in `lib/core/constants/api_constants.dart`.

## Project Structure

```
lib/
├── core/
│   ├── constants/api_constants.dart
│   ├── theme/app_theme.dart, app_colors.dart
│   └── utils/validators.dart
├── data/models/
│   ├── task_model.dart
│   └── user_model.dart
├── domain/entities/task.dart
├── presentation/
│   ├── auth/login/, register/
│   ├── dashboard/main_shell.dart, home_tab.dart
│   ├── tasks/statistics_tab.dart, schedule_tab.dart
│   └── widgets/calorie_card, macro_row, meal_list
├── services/api_service.dart, providers.dart
└── main.dart
```

## Features
- Login & Register with form validation
- Token-based auth (JWT stored in secure storage)
- Dashboard with calorie card, macros, planned meals
- Statistics tab with bar chart
- Schedule tab with task list (from API or demo data)
- Bottom navigation with 5 tabs
- CRUD-ready task module for backend testing

## API Endpoints (Placeholders)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/login | Login |
| POST | /api/auth/register | Register |
| GET | /api/tasks | List tasks |
| POST | /api/tasks | Create task |
| PUT | /api/tasks/{id} | Update task |
| DELETE | /api/tasks/{id} | Delete task |
