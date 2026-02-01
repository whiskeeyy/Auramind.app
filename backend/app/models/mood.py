from pydantic import BaseModel, Field, UUID4, ConfigDict
from typing import List, Optional
from datetime import datetime

class MoodLogCreate(BaseModel):
    mood_score: int = Field(..., ge=1, le=10, description="Mood score from 1 to 10")
    stress_level: int = Field(..., ge=1, le=10, description="Stress level from 1 to 10")
    energy_level: int = Field(..., ge=1, le=10, description="Energy level from 1 to 10")
    note: Optional[str] = None
    activities: List[str] = []
    voice_transcript: Optional[str] = None
    primary_emotion: Optional[str] = Field(None, description="Primary emotion (vui, buồn, giận, lo lắng, bình yên, mệt mỏi)")
    summary: Optional[str] = Field(None, description="One-sentence summary of emotional state")
    health_metrics: Optional[dict] = Field(None, description="Health metrics: {steps, sleep_hours, meditation_min, water_glasses, exercise_min}")

class MoodLogResponse(MoodLogCreate):
    id: UUID4
    user_id: UUID4
    ai_feedback: Optional[str] = None
    avatar_state: Optional[str] = Field(None, description="Avatar state (STATE_JOYFUL, STATE_NEUTRAL, STATE_SAD, STATE_EXHAUSTED, STATE_ANXIOUS)")
    created_at: datetime
    new_achievements: Optional[List[dict]] = Field(None, description="List of newly earned badges")
    
    model_config = ConfigDict(from_attributes=True)

