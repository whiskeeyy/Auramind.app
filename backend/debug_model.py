from app.models.mood import MoodLogResponse
from uuid import UUID

data = {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "user_id": "00000000-0000-0000-0000-000000000000",
    "mood_score": 7,
    "stress_level": 3,
    "energy_level": 5,
    "note": "Feeling good",
    "activities": ["coding"],
    "voice_transcript": None,
    "ai_feedback": None,
    "created_at": "2026-01-26T12:00:00Z"
}

try:
    m = MoodLogResponse(**data)
    print("Success")
except Exception as e:
    print(f"Error: {e}")
