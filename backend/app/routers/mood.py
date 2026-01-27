from fastapi import APIRouter, HTTPException, Depends
from typing import List
from app.models.mood import MoodLogCreate, MoodLogResponse
from app.core import get_supabase
from app.auth import get_current_user
from supabase import Client

router = APIRouter(prefix="/mood-logs", tags=["Mood Logs"])


@router.post("/", response_model=MoodLogResponse)
async def create_mood_log(
    log: MoodLogCreate,
    current_user: str = Depends(get_current_user),
    supabase: Client = Depends(get_supabase)
):
    """
    Create a new mood log for the authenticated user.
    
    Requires authentication via Bearer token in Authorization header.
    """
    data = log.model_dump()
    data["user_id"] = current_user  # Use authenticated user ID
    
    try:
        response = supabase.table("mood_logs").insert(data).execute()
        # Supabase-py v2 returns a response object with .data
        if not response.data:
            raise HTTPException(status_code=500, detail="Failed to create mood log")
        return response.data[0]
    except Exception as e:
        print(f"DB Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/", response_model=List[MoodLogResponse])
async def get_mood_logs(
    current_user: str = Depends(get_current_user),
    supabase: Client = Depends(get_supabase)
):
    """
    Get all mood logs for the authenticated user.
    
    Requires authentication via Bearer token in Authorization header.
    Returns only the logs belonging to the authenticated user.
    """
    try:
        response = supabase.table("mood_logs").select("*").eq("user_id", current_user).execute()
        return response.data
    except Exception as e:
        print(f"DB Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

