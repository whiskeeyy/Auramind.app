from pydantic import BaseModel
from typing import Optional

class ChatRequest(BaseModel):
    message: str
    voice_transcript: Optional[str] = None

class ChatResponse(BaseModel):
    reply: str
    avatar_state: str = "STATE_NEUTRAL"
    remaining_calls: int = 20
