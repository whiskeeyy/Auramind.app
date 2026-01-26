from pydantic import BaseModel
from typing import Optional

class ChatRequest(BaseModel):
    message: str
    context: Optional[str] = None # Optional context like previous mood
    voice_transcript: Optional[str] = None # For future voice support

class ChatResponse(BaseModel):
    reply: str
