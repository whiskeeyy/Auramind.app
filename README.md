# Auramind: Your Digital Soul Mirror

Auramind is a "Digital Companion" that helps users transform invisible emotions into tangible data, improving mental well-being through AI-driven empathy and visual reflection.

## 🌟 Core Values
- **Empathy-first**: AI that doesn't just answer—it understands.
- **Visual Identity**: Personal avatars that mirror your emotional state.
- **Data-Driven Insights**: Calendar views and analytics to track mental health trends.

## 🛠 Tech Stack (2026 Edition)
- **Mobile App**: **Flutter** (Provider State Management) for high-performance cross-platform experience.
- **AI Orchestration**: **Antigravity Manager** (powered by Gemini) with specialized agents (Empathy, Insight, Analyzer).
- **Backend**: **FastAPI** for high-speed Python-based AI services.
- **Data & Auth**: **Supabase** (PostgreSQL) for realtime sync, secure RLS, and authentication.
- **Face Tracking**: **MediaPipe** for AI-driven avatar mapping.

## 📁 Repository Structure
```text
root/
├── backend/          # FastAPI application & AI Agents (Empathy, Insight, Analyzer)
├── mobile/           # Flutter mobile client (MVP)
├── database/         # SQL schema & database migrations (See MIGRATION_README.md)
├── docs/             # PRD, API documentation, and research
├── shared/           # Shared models and type definitions
└── .github/          # GitHub Actions for CI/CD
```

## 🚀 Getting Started

### Backend Setup
1. `cd backend`
2. `python -m venv venv`
3. Activate the environment:
   - Windows: `.\venv\Scripts\activate`
   - Unix/macOS: `source venv/bin/activate`
4. `pip install -r requirements.txt`
5. Run tests: `python -m pytest`

### Database Setup
1. Setup a project on [Supabase](https://supabase.com/).
2. Follow instructions in `database/MIGRATION_README.md` to run migrations in order.

## 🛡 Safety & Privacy
- **AI Safety**: Configured to provide empathetic listening without replacing professional medical advice.
- **Emergency Support**: Automatically displays mental health hotline (1900555618) if mood scores indicate persistent distress.
- **Data Privacy**: All journal entries are processed with privacy-first standards using Row Level Security (RLS).

---
*Status: Active Development (Features Implementing: Aura Calendar, AI Agents, Streak & Badge System)*

## 🏆 Streak & Badge System
- **Gamification**: Visual streaks (flame icon) on Home screen to encourage daily logging.
- **Achievements**: Unlockable badges (e.g., "Early Bird", "Balance Master") based on user behavior.
- **Rules Engine**: Backend service tailored to reward positive mental health habits.
