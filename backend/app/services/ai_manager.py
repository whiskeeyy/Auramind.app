class AIAgentManager:
    def __init__(self):
        # future: initialize gemini client
        pass

    async def analyze_mood(self, note: str, voice_transcript: str = None) -> dict:
        """
        Analyzes the text/voice input to extract mood metrics.
        Returns: {score, stress, energy, feedback}
        """
        # MVP: Simple Mock Logic or Regex
        # Real: Call Gemini Analyzer Agent
        
        combined_text = (note or "") + " " + (voice_transcript or "")
        combined_text = combined_text.strip()
        
        if not combined_text:
             return {
                 "mood_score": 5, 
                 "stress_level": 5, 
                 "energy_level": 5,
                 "feedback": "I'm here for you. Tell me more."
             }

        # Mock logic
        return {
            "mood_score": 7, # Placeholder
            "stress_level": 4,
            "energy_level": 6,
            "feedback": f"I hear you saying: '{combined_text[:20]}...'. It sounds like a balanced day."
        }

ai_manager = AIAgentManager()

def get_ai_manager():
    return ai_manager
