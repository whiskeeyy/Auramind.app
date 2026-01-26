import os
import json
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()

# Configure Gemini
api_key = os.environ.get("GEMINI_API_KEY")
if api_key:
    genai.configure(api_key=api_key)

class AnalyzerAgent:
    def __init__(self):
        self.model = genai.GenerativeModel('gemini-1.5-flash',
            generation_config={"response_mime_type": "application/json"})

    async def analyze(self, text: str) -> dict:
        prompt = f"""
        Analyze the following user journal entry and extract emotional metrics.
        Return ONLY a JSON object with these keys:
        - mood_score (int 1-10): 1 is worst, 10 is best
        - stress_level (int 1-10): 1 is low stress, 10 is high stress
        - energy_level (int 1-10): 1 is low energy, 10 is high energy
        - topics (list of strings): key themes (e.g. "work", "relationship")
        - short_summary (string): 1 sentence summary

        User Entry: "{text}"
        """
        try:
            response = self.model.generate_content(prompt)
            return json.loads(response.text)
        except Exception as e:
            print(f"Analyzer Error: {e}")
            # Fallback
            return {"mood_score": 5, "stress_level": 5, "energy_level": 5, "topics": [], "short_summary": "Could not analyze."}

class EmpathyAgent:
    def __init__(self):
        self.model = genai.GenerativeModel('gemini-1.5-flash')

    async def respond(self, text: str, mood_data: dict) -> str:
        prompt = f"""
        You are Auramind, an empathetic AI companion.
        The user just shared: "{text}"
        Their analyzed mood is: {mood_data.get('mood_score', 5)}/10.
        
        Provide a warm, supportive response using Reflective Listening.
        Do NOT give medical advice. Keep it under 50 words.
        """
        try:
            response = self.model.generate_content(prompt)
            return response.text.strip()
        except Exception as e:
            print(f"Empathy Error: {e}")
            return "I'm listening. Tell me more."

class AIAgentManager:
    def __init__(self):
        self.analyzer = AnalyzerAgent()
        self.empathizer = EmpathyAgent()

    async def analyze_mood(self, note: str, voice_transcript: str = None) -> dict:
        combined_text = (note or "") + " " + (voice_transcript or "")
        combined_text = combined_text.strip()
        
        if not combined_text:
             return {
                 "mood_score": 5, 
                 "stress_level": 5, 
                 "energy_level": 5,
                 "feedback": "I'm here for you. Tell me more."
             }

        # Parallel execution could be better here, but sequential for MVP safety
        # 1. Analyze
        metrics = await self.analyzer.analyze(combined_text)
        
        # 2. Empathize
        feedback = await self.empathizer.respond(combined_text, metrics)
        
        # Merge results
        return {
            "mood_score": metrics.get('mood_score', 5),
            "stress_level": metrics.get('stress_level', 5),
            "energy_level": metrics.get('energy_level', 5),
            "feedback": feedback
        }

ai_manager = AIAgentManager()

def get_ai_manager():
    return ai_manager
