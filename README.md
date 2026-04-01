# AuraMind — Your Digital Soul Mirror

> **Transform invisible emotions into actionable data.** AuraMind is an AI-powered mental wellness companion that combines empathetic conversation, mood analytics, and personalized avatars to help users build lasting self-awareness.

[![Flutter](https://img.shields.io/badge/Mobile-Flutter-02569B?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![Supabase](https://img.shields.io/badge/Database-Supabase-3ECF8E?logo=supabase)](https://supabase.com)
[![Status](https://img.shields.io/badge/Status-Active%20Development-orange)]()

---

## What Is AuraMind?

AuraMind is a cross-platform mobile application designed around a single core loop:

**Check-in → AI Analysis → Empathetic Response → Visual Reflection**

Users log their mood in under 10 seconds, receive a non-judgmental AI response, and watch a personalized avatar mirror their emotional state — all while the app builds a rich dataset of their mental health journey over time.

---

## Key Features

### 🧠 Multi-Agent AI System
- **Analyzer Agent** — Performs sentiment analysis and extracts stress indicators from journal text.
- **Empathy Agent** — Responds with reflective listening techniques, never generic platitudes.
- **Insight Agent** — Surfaces weekly patterns, correlations, and proactive mental health insights.
- **Rate Limiting & Safety Net** — Automatically displays crisis support resources (hotline: `1900555618`) when distress signals persist across three or more consecutive sessions.

### 😊 Mood Tracking
- Fast mood logging: score slider (1–10), smart emoji suggestions, and activity tags.
- Session history with searchable journal entries.
- Health metrics integration: steps, sleep hours, and meditation time.

### 📊 Visual Dashboard
- Real-time mood trend charts (line), emotion distribution (pie), and energy level tracking.
- **Aura Calendar** — Heatmap view showing mood density and avatar states per day; tap any day for a detailed breakdown with AI-generated advice.

### 🏆 Streak & Badge System
- Daily logging streaks with a visual flame indicator on the home screen.
- Unlockable achievements (e.g., *Early Bird*, *Balance Master*) driven by a backend rules engine that rewards positive mental health habits.

### 🪞 Mood Avatar
- Expressive 2D avatar that dynamically reflects the user's current emotional state.
- *(Roadmap)* **Face-to-Toon** — MediaPipe face landmark mapping to generate a personalized 3D avatar from the user's real face.

### 🔒 Safety & Privacy
- **Row Level Security (RLS)** enforced at the database layer — users can only ever access their own data.
- Journal content is privacy-first by design; no data is used for training.
- GDPR-compliant: full data export and deletion on request.
- AI is explicitly constrained from providing medical diagnoses.

---

## Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Mobile** | Flutter (Riverpod / Provider) | Cross-platform iOS & Android with smooth camera integration |
| **Backend** | FastAPI (Python) | High-throughput API layer for AI services |
| **AI Orchestration** | Gemini-powered Agent Manager | Structured multi-agent pipeline (Analyzer → Empathy → Insight) |
| **Database & Auth** | Supabase (PostgreSQL) | Realtime sync, RLS-enforced access control, and JWT authentication |
| **Face Tracking** | MediaPipe | 478-point facial landmark detection for avatar generation *(planned)* |

---

## Repository Structure

```text
Auramind.app/
├── backend/                  # FastAPI application
│   └── app/
│       ├── routers/          # API endpoints: mood.py, chat.py
│       ├── services/         # Business logic: ai_manager.py, badges.py, rate_limiter.py
│       ├── models/           # Pydantic models and DB schemas
│       ├── auth.py           # JWT authentication & Supabase integration
│       └── core.py           # App configuration and dependency injection
├── mobile/                   # Flutter mobile client
│   └── auramind_app/
├── database/                 # SQL schema & ordered migrations
├── docs/                     # PRD, API reference, setup guides, and integration docs
│   ├── PRD.md
│   ├── SETUP.md
│   ├── TASKS.md
│   └── mobile_integration_guide.md
├── shared/                   # Shared models and type definitions
└── .github/                  # GitHub Actions CI/CD workflows
```

---

## Getting Started

### Prerequisites

| Tool | Minimum Version |
|---|---|
| Python | 3.11+ |
| Flutter SDK | 3.x |
| Supabase Account | — |

---

### 1. Database Setup

1. Create a project on [Supabase](https://supabase.com/).
2. Follow `database/MIGRATION_README.md` to apply migrations **in order**.
3. Copy the Project URL and anon/service keys for the next step.

---

### 2. Backend Setup

```bash
cd backend

# Create and activate a virtual environment
python -m venv venv
.\venv\Scripts\activate        # Windows
# source venv/bin/activate     # macOS / Linux

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Fill in SUPABASE_URL, SUPABASE_SERVICE_KEY, GEMINI_API_KEY, etc.

# Run the development server
uvicorn app.main:app --reload

# Run tests
python -m pytest
```

The API will be available at `http://localhost:8000`. Interactive docs (Swagger UI) at `http://localhost:8000/docs`.

---

### 3. Mobile Setup

```bash
cd mobile/auramind_app

# Fetch dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

Refer to `docs/mobile_integration_guide.md` for connecting the mobile client to a local or production backend.

---

## Environment Variables

All required environment variables are documented in `backend/.env.example`. Key variables:

| Variable | Description |
|---|---|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_SERVICE_KEY` | Service role key (never expose publicly) |
| `SUPABASE_JWT_SECRET` | JWT secret for server-side token verification |
| `GEMINI_API_KEY` | Google Gemini API key for AI agents |

See `SECURITY_SETUP.md` for hardening guidelines before deploying to production.

---

## Roadmap

| Status | Feature |
|---|---|
| ✅ Done | Mood logging, AI companion (Analyzer + Empathy), Dashboard, Avatars |
| ✅ Done | Aura Calendar, Streak & Badge system |
| ✅ Done | Supabase auth & RLS, emergency protocol |
| 🔜 Planned | Face-to-Toon (MediaPipe 3D avatar) |
| 🔜 Planned | Voice Chat (Whisper + TTS) |
| 🔜 Planned | Google Fit / Apple Health habit integration |
| 🔜 Planned | App Store & Play Store submission |

---

## Contributing

1. Fork the repository and create a feature branch from `main`.
2. Follow the coding standards defined in `docs/rules/`.
3. Ensure all tests pass (`python -m pytest`) before opening a pull request.
4. Reference the relevant task from `docs/TASKS.md` in your PR description.

---

## License

This project is proprietary software. All rights reserved by the AuraMind Team.

---

*Last updated: March 2026 — v1.2 (Active MVP Development)*
