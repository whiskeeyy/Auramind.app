from pydantic import BaseModel, Field
from typing import List, Optional

class HealthSummary(BaseModel):
    """Aggregated health metrics for a day"""
    total_steps: Optional[int] = Field(None, description="Total steps walked")
    avg_sleep_hours: Optional[float] = Field(None, description="Average sleep hours")
    total_meditation_min: Optional[int] = Field(None, description="Total meditation minutes")
    avg_water_glasses: Optional[float] = Field(None, description="Average water intake")
    total_exercise_min: Optional[int] = Field(None, description="Total exercise minutes")

class DaySummary(BaseModel):
    """Summary of mood and health data for a single day"""
    date: str = Field(..., description="Date in YYYY-MM-DD format")
    average_mood_score: float = Field(..., ge=1, le=10, description="Average mood score for the day")
    primary_avatar_state: str = Field(..., description="Most common avatar state")
    top_activities: List[str] = Field(default=[], description="Top activities for the day")
    log_count: int = Field(..., ge=0, description="Number of logs for the day")
    health_summary: Optional[HealthSummary] = Field(None, description="Aggregated health metrics")

class MonthlyCalendarResponse(BaseModel):
    """Calendar data for a full month with holistic insights"""
    year: int
    month: int
    days: List[DaySummary] = Field(default=[], description="List of day summaries with data")
    monthly_insight: Optional[str] = Field(None, description="AI-generated mood/health correlation insight")
    total_logs: int = Field(0, description="Total number of logs in the month")

