from fastapi import APIRouter, HTTPException, Depends, Query
from typing import List
from datetime import datetime
from collections import Counter, defaultdict
from app.models.mood import MoodLogCreate, MoodLogResponse
from app.models.calendar import DaySummary, MonthlyCalendarResponse
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


@router.get("/calendar/", response_model=MonthlyCalendarResponse)
async def get_calendar_data(
    month: int = Query(..., ge=1, le=12, description="Month (1-12)"),
    year: int = Query(..., ge=2020, le=2050, description="Year"),
    include_insight: bool = Query(False, description="Include AI-generated monthly insight"),
    current_user: str = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_with_auth)
):
    """
    Get aggregated mood and health data for holistic calendar view.
    
    Returns daily summaries with:
    - Average mood score (for heatmap coloring)
    - Primary avatar state (for icon display)
    - Top activities
    - Health summary (steps, sleep, meditation, etc.)
    - Log count
    
    Optionally includes AI-generated correlation insight (uses 1 API call).
    Philosophy: "Calendar là nơi kể lại câu chuyện của người dùng"
    """
    from app.services.ai_manager import get_ai_manager
    from app.services.rate_limiter import get_rate_limiter
    from app.models.calendar import HealthSummary
    
    # Build date range for the month
    start_date = f"{year}-{month:02d}-01T00:00:00"
    if month == 12:
        end_date = f"{year + 1}-01-01T00:00:00"
    else:
        end_date = f"{year}-{month + 1:02d}-01T00:00:00"
    
    try:
        # Query mood logs for the month (including health_metrics)
        response = supabase.table("mood_logs")\
            .select("mood_score, avatar_state, activities, health_metrics, created_at")\
            .eq("user_id", current_user)\
            .gte("created_at", start_date)\
            .lt("created_at", end_date)\
            .order("created_at", desc=False)\
            .execute()
        
        logs = response.data or []
        
        if not logs:
            return MonthlyCalendarResponse(
                year=year,
                month=month,
                days=[],
                monthly_insight=None,
                total_logs=0
            )
        
        # Aggregate by date
        daily_data = defaultdict(lambda: {
            "mood_scores": [],
            "avatar_states": [],
            "activities": [],
            "health_metrics": []  # Collect all health metrics for aggregation
        })
        
        for log in logs:
            # Parse date (handle timezone)
            created_at = log["created_at"]
            if isinstance(created_at, str):
                date_str = created_at[:10]  # Extract YYYY-MM-DD
            else:
                date_str = created_at.strftime("%Y-%m-%d")
            
            daily_data[date_str]["mood_scores"].append(log["mood_score"])
            if log.get("avatar_state"):
                daily_data[date_str]["avatar_states"].append(log["avatar_state"])
            if log.get("activities"):
                daily_data[date_str]["activities"].extend(log["activities"])
            if log.get("health_metrics"):
                daily_data[date_str]["health_metrics"].append(log["health_metrics"])
        
        # Build day summaries
        days = []
        insight_data = []  # For AI analysis
        
        for date_str, data in sorted(daily_data.items()):
            avg_mood = sum(data["mood_scores"]) / len(data["mood_scores"])
            
            # Most common avatar state
            if data["avatar_states"]:
                primary_state = Counter(data["avatar_states"]).most_common(1)[0][0]
            else:
                primary_state = "STATE_NEUTRAL"
            
            # Top 3 activities
            if data["activities"]:
                top_activities = [a for a, _ in Counter(data["activities"]).most_common(3)]
            else:
                top_activities = []
            
            # Aggregate health metrics (if any exist)
            health_summary = None
            if data["health_metrics"]:
                health_agg = {
                    "steps": [],
                    "sleep_hours": [],
                    "meditation_min": [],
                    "water_glasses": [],
                    "exercise_min": []
                }
                for hm in data["health_metrics"]:
                    if hm.get("steps") is not None:
                        health_agg["steps"].append(hm["steps"])
                    if hm.get("sleep_hours") is not None:
                        health_agg["sleep_hours"].append(hm["sleep_hours"])
                    if hm.get("meditation_min") is not None:
                        health_agg["meditation_min"].append(hm["meditation_min"])
                    if hm.get("water_glasses") is not None:
                        health_agg["water_glasses"].append(hm["water_glasses"])
                    if hm.get("exercise_min") is not None:
                        health_agg["exercise_min"].append(hm["exercise_min"])
                
                # Only create summary if at least one metric exists
                if any(health_agg.values()):
                    health_summary = HealthSummary(
                        total_steps=sum(health_agg["steps"]) if health_agg["steps"] else None,
                        avg_sleep_hours=round(sum(health_agg["sleep_hours"]) / len(health_agg["sleep_hours"]), 1) if health_agg["sleep_hours"] else None,
                        total_meditation_min=sum(health_agg["meditation_min"]) if health_agg["meditation_min"] else None,
                        avg_water_glasses=round(sum(health_agg["water_glasses"]) / len(health_agg["water_glasses"]), 1) if health_agg["water_glasses"] else None,
                        total_exercise_min=sum(health_agg["exercise_min"]) if health_agg["exercise_min"] else None
                    )
            
            days.append(DaySummary(
                date=date_str,
                average_mood_score=round(avg_mood, 1),
                primary_avatar_state=primary_state,
                top_activities=top_activities,
                log_count=len(data["mood_scores"]),
                health_summary=health_summary
            ))
            
            # Prepare data for insight agent (include health for correlation)
            insight_data.append({
                "date": date_str,
                "avg_mood": avg_mood,
                "avatar_state": primary_state,
                "activities": top_activities,
                "health": health_summary.model_dump() if health_summary else None
            })
        
        # Generate monthly insight if requested (and rate limit allows)
        monthly_insight = None
        if include_insight and len(days) >= 3:
            rate_limiter = get_rate_limiter()
            if rate_limiter.is_allowed(current_user):
                ai_manager = get_ai_manager()
                # Use correlation analysis for holistic insight
                monthly_insight = await ai_manager.get_holistic_insight(insight_data)
        
        return MonthlyCalendarResponse(
            year=year,
            month=month,
            days=days,
            monthly_insight=monthly_insight,
            total_logs=len(logs)
        )
        
    except Exception as e:
        print(f"Calendar DB Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

