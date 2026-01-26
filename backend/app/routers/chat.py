from fastapi import APIRouter, HTTPException, Depends
from app.models.chat import ChatRequest, ChatResponse
from app.services.ai_manager import get_ai_manager

router = APIRouter(prefix="/chat", tags=["AI Chat"])

@router.post("/", response_model=ChatResponse)
async def chat_with_ai(request: ChatRequest, ai_manager = Depends(get_ai_manager)):
    try:
        # For chat, we treat the message as the 'note' and assume neutral mood context 
        # unless provided. In a real app, we'd fetch user history.
        # Here we just use the Empathy Agent directly.
        
        # We dummy up a mood_data context for the empathy agent
        mood_context = {"mood_score": 5} 
        
        response_text = await ai_manager.empathizer.respond(request.message, mood_context)
        return ChatResponse(reply=response_text)
    except Exception as e:
        print(f"Chat Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
