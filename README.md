<p align="center">
  <img src="assets/logo.png" alt="MHPSS BDRCS Logo" width="120" />
</p>

<h1 align="center">MHPSS — Bangladesh Red Crescent Society</h1>

<p align="center">
  Mental Health and Psychosocial Support Management Platform
  <br />
  <i>A comprehensive Flutter-based solution for managing client counseling, assessments, and case workflows.</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-web%20%7C%20mobile-blue" alt="Platform" />
  <img src="https://img.shields.io/badge/flutter-3.12%2B-blue" alt="Flutter" />
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License" />
</p>

---

## Overview

MHPSS BDRCS is a digital case management platform built for the **Bangladesh Red Crescent Society** to streamline mental health and psychosocial support services. It enables counselors and administrators to manage clients, schedule sessions, administer assessments, track documents, and generate insights — all in one secure application.

---

## Features

### Client Management
- **Register & Manage Clients** — Add clients with case IDs, demographics, contact info, and categorization (A/B/C/D).
- **Card & Table Views** — Toggle between visual card layout and a detailed data table.
- **Client Dashboard** — Per-client tabs for About, Sessions, Assessments, Docs, and Bill.

### Session Management
- **Schedule & Track Sessions** — Create counseling sessions with date, time, location (GPS), and counselor assignment.
- **Session Status** — Track session progress (Scheduled, Completed, Cancelled, Rescheduled, No-Show).
- **Follow-up Reminders** — Set and monitor follow-up dates.

### Assessment Engine
- **Built-in Assessments** — DASS-21, SRQ-20, and CSPT (Bangla) with automated scoring.
- **Risk Classification** — High / Moderate / Normal risk flags based on scores.
- **Session Linking** — Assessments can be linked to specific sessions or run independently.

### Document Management
- **Upload & Store Documents** — Support for images, PDFs, and DOC files.
- **Cloudinary Integration** — Secure cloud storage with 3 MB limit and compression.
- **Session Linking** — Documents can be linked to sessions or stored standalone.

### Dashboard & Analytics
- **Quick Stats** — Total clients, sessions this week, assessments, high-risk alerts.
- **Today's Schedule** — Upcoming sessions at a glance.
- **Recent Clients** — Quickly access recently active clients.

### Admin Panel
- **Organization Management** — Multi-tenant organization setup.
- **Counselor & Admin Oversight** — Manage users, view all clients, sessions, and assessments.
- **Cross-Organization Filtering** — Filter data by organization.

### Security
- **Firebase Authentication** — Secure login for counselors and admins.
- **Role-Based Access** — Separate portals for counselors and super admins.
- **Environment Variables** — All API keys and secrets managed via `.env` (gitignored).

---

## Tech Stack

| Layer         | Technology                                  |
|---------------|---------------------------------------------|
| **Frontend**  | Flutter 3.12+, Dart                         |
| **State Mgmt**| Riverpod (with code generation)             |
| **Routing**   | GoRouter (shell routes, deep linking)       |
| **Backend**   | Firebase (Auth, Firestore, Cloud Functions) |
| **Storage**   | Cloudinary (documents)                      |
| **Maps**      | FlutterMap + OpenStreetMap (session GPS)    |
| **Charts**    | FL Chart (dashboard analytics)              |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.12+
- Firebase project with Firestore, Auth enabled
- Cloudinary account

### Installation

```bash
# Clone the repository
git clone https://github.com/sofolitltd/mhpss-bdrcs.git
cd mhpss-bdrcs

# Install dependencies
flutter pub get

# Set up environment variables
cp .env.example .env
# Edit .env with your credentials (gitignored)

# Generate Riverpod code
dart run build_runner build

# Run the app
flutter run
```

### Environment Variables

Create a `.env` file in the project root:

```env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
FIREBASE_API_KEY=your_firebase_api_key
```

---

## Project Structure

```
lib/
├── core/
│   ├── design_system/     # App colors, spacing, radius, breakpoints
│   ├── routing/           # GoRouter configuration & shell routes
│   ├── services/          # Cloudinary, etc.
│   └── theme/             # Light/dark theme definitions
├── features/
│   ├── admin/             # Admin panel (super admin)
│   ├── assessment_engine/ # DASS-21, SRQ-20, CSPT scoring
│   ├── auth/              # Login, registration, auth state
│   ├── clients/           # Client, session, document management
│   ├── contacts/          # Counselor and contact management
│   ├── dashboard/         # Counselor dashboard & widgets
│   └── settings/          # Profile, password, app settings
└── main.dart              # App entry point
```

---

## Usage

### Counselors
1. **Login** with organization credentials.
2. **Dashboard** shows today's schedule, quick stats, and recent clients.
3. **Clients** tab to register and manage clients.
4. Open a client to view **About** info, schedule **Sessions**, run **Assessments**, upload **Docs**.
5. Use **Contacts** to manage the counselor roster.

### Super Admins
1. Login at `/admin` with admin credentials.
2. Manage **Organizations**, **Counselors**, and **Admins**.
3. View all clients, sessions, and assessments across the system.
4. Access detailed analytics via the admin dashboard.

---

## Code Generation

This project uses Riverpod code generation. After modifying providers, run:

```bash
dart run build_runner build
```

---

## Screenshots

> *(Screenshots to be added)*

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Contact

**Bangladesh Red Crescent Society**
<br />
Developed by [Sofol IT Ltd](https://github.com/sofolitltd)
# mhpss-bdrcs
