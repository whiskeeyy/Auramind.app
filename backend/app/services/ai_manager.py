import os
import json
import google.generativeai as genai
from dotenv import load_dotenv
from datetime import datetime, timedelta
from typing import Optional
from supabase import Client

load_dotenv()

# Configure Gemini
api_key = os.environ.get("GEMINI_API_KEY")
if api_key:
    genai.configure(api_key=api_key)

class AnalyzerAgent:
    """
    Analyzer Agent - Extracts emotional metrics from user journal entries
    
    Enhancements:
    - Validates activities array (no null/empty strings)
    - Fallback emotion changed to "neutral"
    """
    def __init__(self):
        self.model = genai.GenerativeModel('gemini-1.5-flash',
            generation_config={"response_mime_type": "application/json"})

    async def analyze(self, text: str) -> dict:
        prompt = f"""Role: Bạn là một chuyên gia phân tích tâm lý học dữ liệu (Data Psychologist).
Task: Phân tích nội dung nhật ký người dùng để trích xuất các chỉ số cảm xúc.
Input: {text}
Constraints:
- Chỉ trả về kết quả định dạng JSON nguyên bản
- Tuyệt đối không chào hỏi hay giải thích thêm
- Thang điểm từ 1 đến 10
- Tối ưu câu trả lời để sử dụng ít token nhất có thể nhưng vẫn đảm bảo chất lượng

Output Format:
{{
  "mood_score": [1-10],
  "stress_level": [1-10],
  "energy_level": [1-10],
  "primary_emotion": "[vui, buồn, giận, lo lắng, bình yên, mệt mỏi, neutral]",
  "activities": ["tag1", "tag2"],
  "summary": "[Tóm tắt trạng thái trong 1 câu]"
}}"""
        try:
            response = self.model.generate_content(prompt)
            result = json.loads(response.text)
            
            # Validate and clean activities array
            activities = result.get('activities', [])
            # Filter out null, empty strings, and non-string values
            cleaned_activities = [
                str(a).strip() for a in activities 
                if a is not None and str(a).strip()
            ]
            result['activities'] = cleaned_activities
            
            # Ensure primary_emotion has a default
            if not result.get('primary_emotion'):
                result['primary_emotion'] = 'neutral'
            
            return result
        except Exception as e:
            print(f"Analyzer Error: {e}")
            # Fallback with neutral emotion
            return {
                "mood_score": 5, 
                "stress_level": 5, 
                "energy_level": 5, 
                "primary_emotion": "neutral",
                "activities": [], 
                "summary": "Không thể phân tích."
            }

class EmpathyAgent:
    """
    Empathy Agent - Provides compassionate Vietnamese responses using reflective listening
    
    Enhancements:
    - Context awareness from previous mood logs
    - Streak detection and encouragement
    """
    def __init__(self):
        self.model = genai.GenerativeModel('gemini-1.5-flash')

    async def get_user_context(self, user_id: str, supabase: Client) -> dict:
        """
        Fetch recent mood logs to provide context
        
        Args:
            user_id: User ID to fetch logs for
            supabase: Supabase client
            
        Returns:
            dict with context information (streak, recent_moods, etc.)
        """
        try:
            # Fetch mood logs from last 7 days
            seven_days_ago = (datetime.utcnow() - timedelta(days=7)).isoformat()
            
            response = supabase.table("mood_logs")\
                .select("created_at, mood_score")\
                .eq("user_id", user_id)\
                .gte("created_at", seven_days_ago)\
                .order("created_at", desc=True)\
                .execute()
            
            logs = response.data if response.data else []
            
            # Detect consecutive day streak
            streak = self._calculate_streak(logs)
            
            # Calculate average mood
            avg_mood = sum(log['mood_score'] for log in logs) / len(logs) if logs else 5
            
            return {
                'streak': streak,
                'total_logs': len(logs),
                'avg_mood': avg_mood,
                'has_context': len(logs) > 0
            }
        except Exception as e:
            print(f"Context fetch error: {e}")
            return {
                'streak': 0,
                'total_logs': 0,
                'avg_mood': 5,
                'has_context': False
            }
    
    def _calculate_streak(self, logs: list) -> int:
        """Calculate consecutive day streak from logs"""
        if not logs:
            return 0
        
        # Group logs by date
        dates = set()
        for log in logs:
            log_date = datetime.fromisoformat(log['created_at'].replace('Z', '+00:00')).date()
            dates.add(log_date)
        
        # Count consecutive days from today
        streak = 0
        current_date = datetime.utcnow().date()
        
        while current_date in dates:
            streak += 1
            current_date = current_date - timedelta(days=1)
        
        return streak

    async def respond(self, text: str, analyzer_output: dict, user_context: Optional[dict] = None) -> str:
        mood_score = analyzer_output.get('mood_score', 5)
        primary_emotion = analyzer_output.get('primary_emotion', 'neutral')
        
        # Build context string for prompt
        context_str = ""
        if user_context and user_context.get('has_context'):
            streak = user_context.get('streak', 0)
            if streak >= 3:
                context_str = f"\nNgười dùng đã ghi nhật ký {streak} ngày liên tiếp - hãy khen ngợi điều này!"
        
        prompt = f"""Role: Bạn là Aura, một người bạn ảo thấu cảm, chuyên gia hỗ trợ tinh thần.
Context: Dựa vào nhật ký gốc: "{text}" và dữ liệu phân tích: mood_score={mood_score}/10, primary_emotion={primary_emotion}.{context_str}
Action:
- Sử dụng kỹ thuật Lắng nghe phản chiếu (Reflective Listening)
- Phản hồi bằng tiếng Việt nhẹ nhàng, xưng "mình" và gọi người dùng là "bạn"
Constraints:
- Phản hồi ngắn gọn (không quá 3 câu)
- KHÔNG đưa ra lời khuyên y khoa hay chẩn đoán bệnh
- {"Nếu mood_score < 3, hãy kèm theo một lời trấn an sâu sắc" if mood_score < 3 else ""}
- Tối ưu câu trả lời để sử dụng ít token nhất có thể nhưng vẫn đảm bảo chất lượng
Target: Giúp người dùng cảm thấy được lắng nghe và vỗ về."""
        try:
            response = self.model.generate_content(prompt)
            return response.text.strip()
        except Exception as e:
            print(f"Empathy Error: {e}")
            return "Mình đang lắng nghe bạn. Hãy chia sẻ thêm nhé."

class AvatarOrchestratorAgent:
    """
    Avatar Orchestrator - Determines avatar state based on mood and stress levels
    
    Enhancements:
    - Added STATE_OVERWHELMED for high stress + low mood
    """
    @staticmethod
    def get_avatar_state(mood_score: int, stress_level: int) -> str:
        """
        Mapping Logic (Priority order):
        1. Stress > 8 AND Mood < 5: STATE_OVERWHELMED
        2. Stress > 7: STATE_ANXIOUS
        3. Mood 8-10: STATE_JOYFUL
        4. Mood 5-7: STATE_NEUTRAL
        5. Mood 3-4: STATE_SAD
        6. Mood 1-2: STATE_EXHAUSTED
        """
        # Priority 1: Overwhelmed (high stress + low mood)
        if stress_level > 8 and mood_score < 5:
            return "STATE_OVERWHELMED"
        
        # Priority 2: High stress (but not overwhelmed)
        if stress_level > 7:
            return "STATE_ANXIOUS"
        
        # Priority 3: Mood-based states
        if mood_score >= 8:
            return "STATE_JOYFUL"
        elif mood_score >= 5:
            return "STATE_NEUTRAL"
        elif mood_score >= 3:
            return "STATE_SAD"
        else:
            return "STATE_EXHAUSTED"

class AIAgentManager:
    """
    Orchestrates the three AI agents in a pipeline with enhanced error handling
    
    Enhancements:
    - Context-aware responses
    - Robust error handling with fallbacks
    - Rate limiting support
    """
    def __init__(self):
        self.analyzer = AnalyzerAgent()
        self.empathizer = EmpathyAgent()
        self.orchestrator = AvatarOrchestratorAgent()

    async def analyze_mood(
        self, 
        note: str, 
        voice_transcript: str = None,
        user_id: Optional[str] = None,
        supabase: Optional[Client] = None
    ) -> dict:
        """
        Main pipeline for processing user journal entries
        
        Args:
            note: Text note from user
            voice_transcript: Optional voice-to-text transcript
            user_id: Optional user ID for context fetching
            supabase: Optional Supabase client for context fetching
            
        Returns:
            dict containing all agent outputs with error handling
        """
        combined_text = (note or "") + " " + (voice_transcript or "")
        combined_text = combined_text.strip()
        
        if not combined_text:
            return self._get_empty_response()

        try:
            # Step 1: Analyze emotional metrics
            analyzer_output = await self.analyzer.analyze(combined_text)
            
            # Step 2: Get user context (if available)
            user_context = None
            if user_id and supabase:
                try:
                    user_context = await self.empathizer.get_user_context(user_id, supabase)
                except Exception as e:
                    print(f"Context fetch error (non-critical): {e}")
                    user_context = None
            
            # Step 3: Generate empathetic response
            try:
                ai_feedback = await self.empathizer.respond(
                    combined_text, 
                    analyzer_output,
                    user_context
                )
            except Exception as e:
                print(f"Empathy error: {e}")
                # Fallback response using primary_emotion
                emotion = analyzer_output.get('primary_emotion', 'neutral')
                ai_feedback = self._get_fallback_response(emotion)
            
            # Step 4: Determine avatar state
            avatar_state = self.orchestrator.get_avatar_state(
                analyzer_output.get('mood_score', 5),
                analyzer_output.get('stress_level', 5)
            )
            
            # Merge all results
            return {
                "mood_score": analyzer_output.get('mood_score', 5),
                "stress_level": analyzer_output.get('stress_level', 5),
                "energy_level": analyzer_output.get('energy_level', 5),
                "primary_emotion": analyzer_output.get('primary_emotion', 'neutral'),
                "activities": analyzer_output.get('activities', []),
                "summary": analyzer_output.get('summary', ''),
                "ai_feedback": ai_feedback,
                "avatar_state": avatar_state
            }
            
        except Exception as e:
            print(f"Pipeline error: {e}")
            # Complete fallback when entire pipeline fails
            return self._get_error_fallback()
    
    def _get_empty_response(self) -> dict:
        """Response for empty input"""
        return {
            "mood_score": 5, 
            "stress_level": 5, 
            "energy_level": 5,
            "primary_emotion": "neutral",
            "activities": [],
            "summary": "Chưa có nội dung.",
            "ai_feedback": "Mình ở đây để lắng nghe bạn. Hãy chia sẻ cảm xúc của bạn nhé.",
            "avatar_state": "STATE_NEUTRAL"
        }
    
    def _get_fallback_response(self, emotion: str) -> str:
        """
        Generate fallback response when Empathy Agent fails
        Uses primary_emotion to create contextual message
        """
        emotion_map = {
            'vui': 'vui vẻ',
            'buồn': 'buồn',
            'giận': 'tức giận',
            'lo lắng': 'lo lắng',
            'bình yên': 'bình yên',
            'mệt mỏi': 'mệt mỏi',
            'neutral': 'ổn'
        }
        emotion_text = emotion_map.get(emotion, 'ổn')
        return f"Mình đang gặp chút vấn đề, nhưng mình thấy bạn đang {emotion_text}. Hãy thử thở sâu nhé!"
    
    def _get_error_fallback(self) -> dict:
        """Complete fallback when entire pipeline fails"""
        return {
            "mood_score": 5,
            "stress_level": 5,
            "energy_level": 5,
            "primary_emotion": "neutral",
            "activities": [],
            "summary": "Không thể phân tích lúc này.",
            "ai_feedback": "Mình đang gặp chút vấn đề kỹ thuật. Hãy thử lại sau nhé!",
            "avatar_state": "STATE_NEUTRAL"
        }

# Singleton instance
ai_manager = AIAgentManager()

def get_ai_manager():
    """Dependency injection for FastAPI"""
    return ai_manager
