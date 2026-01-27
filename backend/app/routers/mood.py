from fastapi import APIRouter, HTTPException, Depends
from typing import List
from app.models.mood import MoodLogCreate, MoodLogResponse
from app.core import get_supabase_with_auth
from app.auth import get_current_user
from supabase import Client

router = APIRouter(prefix="/mood-logs", tags=["Mood Logs"])


@router.post("/", response_model=MoodLogResponse)
async def create_mood_log(
    log: MoodLogCreate,
    current_user: str = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_with_auth)
):
    """
    Create a new mood log for the authenticated user.
    
    Automatically analyzes the journal entry using AI agents to extract:
    - Emotional metrics (mood, stress, energy)
    - Primary emotion and activities
    - Vietnamese empathetic response (with context awareness and streak detection)
    - Avatar state for UI
    
    Features:
    - Rate limiting (20 calls per hour per user)
    - Context awareness from previous logs
    - Automatic profile avatar_state update
    
    Requires authentication via Bearer token in Authorization header.
    RLS automatically enforces that user_id matches auth.uid().
    """
    from app.services.ai_manager import get_ai_manager
    from app.services.rate_limiter import get_rate_limiter
    
    # Check rate limit
    rate_limiter = get_rate_limiter()
    if not rate_limiter.is_allowed(current_user):
        remaining = rate_limiter.get_remaining_calls(current_user)
        raise HTTPException(
            status_code=429,
            detail=f"Rate limit exceeded. You have {remaining} AI analysis calls remaining this hour. Please try again later."
        )
    
    # Run AI agent pipeline if there's content to analyze
    if log.note or log.voice_transcript:
        ai_manager = get_ai_manager()
        
        # Pass user context for context-aware responses
        ai_results = await ai_manager.analyze_mood(
            log.note, 
            log.voice_transcript,
            user_id=current_user,
            supabase=supabase
        )
        
        # Override/populate fields with AI analysis
        log.mood_score = ai_results.get('mood_score', log.mood_score)
        log.stress_level = ai_results.get('stress_level', log.stress_level)
        log.energy_level = ai_results.get('energy_level', log.energy_level)
        log.primary_emotion = ai_results.get('primary_emotion')
        log.activities = ai_results.get('activities', log.activities)
        log.summary = ai_results.get('summary')
        ai_feedback = ai_results.get('ai_feedback')
        avatar_state = ai_results.get('avatar_state')
    else:
        ai_feedback = None
        avatar_state = "STATE_NEUTRAL"
    
    # Prepare data for database
    data = log.model_dump()
    data["user_id"] = current_user  # Use authenticated user ID
    data["ai_feedback"] = ai_feedback
    data["avatar_state"] = avatar_state
    
    try:
        # Insert mood log
        response = supabase.table("mood_logs").insert(data).execute()
        # Supabase-py v2 returns a response object with .data
        if not response.data:
            raise HTTPException(status_code=500, detail="Failed to create mood log")
        
        # Update user profile with current avatar state (for fast dashboard loading)
        try:
            supabase.table("profiles").update({
                "avatar_state": avatar_state
            }).eq("user_id", current_user).execute()
        except Exception as profile_error:
            # Non-critical error, log but don't fail the request
            print(f"Profile update error (non-critical): {profile_error}")
        
        return response.data[0]
    except HTTPException:
        raise
    except Exception as e:
        print(f"DB Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/", response_model=List[MoodLogResponse])
async def get_mood_logs(
    current_user: str = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_with_auth)
):
    """
    Get all mood logs for the authenticated user.
    
    Requires authentication via Bearer token in Authorization header.
    RLS automatically filters: USING (auth.uid() = user_id)
    Manual .eq("user_id", current_user) filter kept for defense-in-depth.
    """
    try:
        response = supabase.table("mood_logs").select("*").eq("user_id", current_user).execute()
        return response.data
    except Exception as e:
        print(f"DB Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

