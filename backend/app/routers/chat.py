from fastapi import APIRouter, HTTPException, Depends
from app.models.chat import ChatRequest, ChatResponse
from app.services.ai_manager import get_ai_manager
from app.auth import get_current_user
from app.core import get_supabase_with_auth
from app.services.rate_limiter import get_rate_limiter
from supabase import Client

router = APIRouter(prefix="/chat", tags=["AI Chat"])

@router.post("/", response_model=ChatResponse)
async def chat_with_ai(
    request: ChatRequest, 
    current_user: str = Depends(get_current_user),
    ai_manager = Depends(get_ai_manager),
    supabase: Client = Depends(get_supabase_with_auth),
    rate_limiter = Depends(get_rate_limiter)
):
    """
    Real-time chat with Aura AI companion.
    
    Flow:
    1. Authenticate & Check Rate Limit
    2. Store User Message
    3. Fetch History (Context)
    4. AI Processing
    5. Store Assistant Message
    6. Return Response
    """
    
    # 1. Rate Limiting
    if not rate_limiter.is_allowed(current_user):
        remaining = rate_limiter.get_remaining_calls(current_user)
        raise HTTPException(
            status_code=429,
            detail=f"Rate limit exceeded. {remaining} calls remaining."
        )

    try:
        # 2. Store User Message
        supabase.table("chat_messages").insert({
            "user_id": current_user,
            "role": "user",
            "content": request.message
        }).execute()
        
        # 3. Fetch History (Last 10 messages)
        # Sort by created_at desc to get recent, then reverse back for context
        history_response = supabase.table("chat_messages")\
            .select("role, content")\
            .eq("user_id", current_user)\
            .order("created_at", desc=True)\
            .limit(10)\
            .execute()
            
        # Supabase returns most recent first, we need chronological order for AI
        history = history_response.data[::-1] if history_response.data else []
        
        # 4. AI Processing
        ai_result = await ai_manager.chat(request.message, history)
        
        reply_text = ai_result.get("reply", "Mình đang gặp chút trục trặc, bạn thử lại sau nhé.")
        avatar_state = ai_result.get("avatar_state", "STATE_NEUTRAL")
        
        # 5. Store Assistant Message
        supabase.table("chat_messages").insert({
            "user_id": current_user,
            "role": "assistant",
            "content": reply_text,
            "avatar_state": avatar_state
        }).execute()
        
        # 6. Return Response
        return ChatResponse(
            reply=reply_text,
            avatar_state=avatar_state,
            remaining_calls=rate_limiter.get_remaining_calls(current_user)
        )
        
    except Exception as e:
        print(f"Chat Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
