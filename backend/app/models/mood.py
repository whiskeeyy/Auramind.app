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
    # user_id will be extracted from auth token in real app

class MoodLogResponse(MoodLogCreate):
    id: UUID4
    user_id: UUID4
    ai_feedback: Optional[str] = None
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)
