from fastapi import APIRouter, HTTPException, Depends
from typing import List
from app.models.mood import MoodLogCreate, MoodLogResponse
from app.core import get_supabase
from supabase import Client

router = APIRouter(prefix="/mood-logs", tags=["Mood Logs"])

# FIXME: Replace with actual auth dependency to get current user ID
FAKE_USER_ID = "00000000-0000-0000-0000-000000000000"

@router.post("/", response_model=MoodLogResponse)
async def create_mood_log(log: MoodLogCreate, supabase: Client = Depends(get_supabase)):
    data = log.model_dump()
    data["user_id"] = FAKE_USER_ID
    
    try:
        response = supabase.table("mood_logs").insert(data).execute()
        # Supabase-py v2 returns a response object with .data
        if not response.data:
             raise HTTPException(status_code=500, detail="Failed to create mood log")
        return response.data[0]
    except Exception as e:
        # In dev, we might want to return the mock if DB fails due to missing keys
        print(f"DB Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/", response_model=List[MoodLogResponse])
async def get_mood_logs(supabase: Client = Depends(get_supabase)):
    try:
        response = supabase.table("mood_logs").select("*").eq("user_id", FAKE_USER_ID).execute()
        return response.data
    except Exception as e:
        print(f"DB Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
