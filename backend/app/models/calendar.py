from pydantic import BaseModel, Field
from typing import List, Optional

class DaySummary(BaseModel):
    """Summary of mood data for a single day"""
    date: str = Field(..., description="Date in YYYY-MM-DD format")
    average_mood_score: float = Field(..., ge=1, le=10, description="Average mood score for the day")
    primary_avatar_state: str = Field(..., description="Most common avatar state")
    top_activities: List[str] = Field(default=[], description="Top activities for the day")
    log_count: int = Field(..., ge=0, description="Number of logs for the day")

class MonthlyCalendarResponse(BaseModel):
    """Calendar data for a full month"""
    year: int
    month: int
    days: List[DaySummary] = Field(default=[], description="List of day summaries with data")
    monthly_insight: Optional[str] = Field(None, description="AI-generated monthly pattern insight")
    total_logs: int = Field(0, description="Total number of logs in the month")
