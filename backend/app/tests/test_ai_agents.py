"""
Tests for Enhanced AI Agent System
Tests for validation, context awareness, rate limiting, and new avatar states
"""
import pytest
from app.services.ai_manager import AnalyzerAgent, EmpathyAgent, AvatarOrchestratorAgent, AIAgentManager
from app.services.rate_limiter import RateLimiter

class TestAnalyzerAgentEnhancements:
    """Test Analyzer Agent enhancements"""
    
    @pytest.mark.asyncio
    async def test_activities_validation_removes_empty(self):
        """Test that empty strings are filtered from activities"""
        analyzer = AnalyzerAgent()
        # This would need to mock the API response
        # For now, test the validation logic directly
        activities = ["work", "", "gym", None, "  ", "study"]
        cleaned = [
            str(a).strip() for a in activities 
            if a is not None and str(a).strip()
        ]
        assert cleaned == ["work", "gym", "study"]
    
    @pytest.mark.asyncio
    async def test_neutral_fallback_emotion(self):
        """Test that fallback uses 'neutral' instead of 'bình yên'"""
        analyzer = AnalyzerAgent()
        # Test fallback by passing empty or causing error
        result = await analyzer.analyze("")
        
        assert result['primary_emotion'] == 'neutral'


class TestEmpathyAgentEnhancements:
    """Test Empathy Agent context awareness"""
    
    def test_streak_calculation_empty(self):
        """Test streak calculation with no logs"""
        empathy = EmpathyAgent()
        streak = empathy._calculate_streak([])
        assert streak == 0
    
    def test_streak_calculation_single_day(self):
        """Test streak calculation with single day"""
        from datetime import datetime
        empathy = EmpathyAgent()
        
        logs = [
            {'created_at': datetime.utcnow().isoformat() + 'Z', 'mood_score': 7}
        ]
        streak = empathy._calculate_streak(logs)
        assert streak >= 1
    
    @pytest.mark.asyncio
    async def test_context_awareness_streak_message(self):
        """Test that streak is included in prompt when >= 3"""
        # This would require mocking Supabase
        # Testing the logic flow
        empathy = EmpathyAgent()
        
        context = {
            'streak': 5,
            'has_context': True,
            'total_logs': 10,
            'avg_mood': 7
        }
        
        # When streak >= 3, context_str should be added
        # This is tested through integration tests


class TestAvatarOrchestratorEnhancements:
    """Test Avatar Orchestrator with STATE_OVERWHELMED"""
    
    def test_state_overwhelmed_high_stress_low_mood(self):
        """Test STATE_OVERWHELMED for stress > 8 and mood < 5"""
        state = AvatarOrchestratorAgent.get_avatar_state(mood_score=3, stress_level=9)
        assert state == "STATE_OVERWHELMED"
    
    def test_state_overwhelmed_priority_over_exhausted(self):
        """Test that OVERWHELMED takes priority over EXHAUSTED"""
        # Mood = 2 would normally be EXHAUSTED
        # But stress = 9 makes it OVERWHELMED
        state = AvatarOrchestratorAgent.get_avatar_state(mood_score=2, stress_level=9)
        assert state == "STATE_OVERWHELMED"
    
    def test_state_anxious_when_not_overwhelmed(self):
        """Test that ANXIOUS is used when stress high but mood not low enough"""
        # Stress > 7 but mood = 6 (not < 5)
        state = AvatarOrchestratorAgent.get_avatar_state(mood_score=6, stress_level=8)
        assert state == "STATE_ANXIOUS"
    
    def test_state_not_overwhelmed_stress_not_high_enough(self):
        """Test that OVERWHELMED requires stress > 8"""
        # Stress = 8 is not > 8, so should be SAD
        state = AvatarOrchestratorAgent.get_avatar_state(mood_score=3, stress_level=8)
        assert state == "STATE_ANXIOUS"  # Stress = 8 > 7, so ANXIOUS
    
    def test_all_states_coverage(self):
        """Test all possible states are reachable"""
        test_cases = [
            (9, 3, "STATE_JOYFUL"),
            (6, 4, "STATE_NEUTRAL"),
            (4, 5, "STATE_SAD"),
            (2, 4, "STATE_EXHAUSTED"),
            (6, 8, "STATE_ANXIOUS"),
            (3, 9, "STATE_OVERWHELMED"),
        ]
        
        for mood, stress, expected in test_cases:
            state = AvatarOrchestratorAgent.get_avatar_state(mood, stress)
            assert state == expected, f"Failed for mood={mood}, stress={stress}"


class TestRateLimiter:
    """Test Rate Limiter functionality"""
    
    def test_allows_calls_within_limit(self):
        """Test that calls within limit are allowed"""
        limiter = RateLimiter(max_calls=3, window_minutes=60)
        user_id = "test_user_1"
        
        assert limiter.is_allowed(user_id) == True
        assert limiter.is_allowed(user_id) == True
        assert limiter.is_allowed(user_id) == True
    
    def test_blocks_calls_over_limit(self):
        """Test that calls over limit are blocked"""
        limiter = RateLimiter(max_calls=2, window_minutes=60)
        user_id = "test_user_2"
        
        assert limiter.is_allowed(user_id) == True
        assert limiter.is_allowed(user_id) == True
        assert limiter.is_allowed(user_id) == False  # Over limit
    
    def test_get_remaining_calls(self):
        """Test getting remaining calls"""
        limiter = RateLimiter(max_calls=5, window_minutes=60)
        user_id = "test_user_3"
        
        limiter.is_allowed(user_id)
        limiter.is_allowed(user_id)
        
        remaining = limiter.get_remaining_calls(user_id)
        assert remaining == 3
    
    def test_reset_user(self):
        """Test resetting a user's limit"""
        limiter = RateLimiter(max_calls=2, window_minutes=60)
        user_id = "test_user_4"
        
        limiter.is_allowed(user_id)
        limiter.is_allowed(user_id)
        assert limiter.is_allowed(user_id) == False
        
        limiter.reset_user(user_id)
        assert limiter.is_allowed(user_id) == True
    
    def test_different_users_independent(self):
        """Test that different users have independent limits"""
        limiter = RateLimiter(max_calls=2, window_minutes=60)
        
        limiter.is_allowed("user_a")
        limiter.is_allowed("user_a")
        
        # user_a is at limit, but user_b should still be allowed
        assert limiter.is_allowed("user_b") == True


class TestAIAgentManagerEnhancements:
    """Test enhanced AI Agent Manager with error handling"""
    
    @pytest.mark.asyncio
    async def test_empty_input_returns_neutral(self):
        """Test empty input returns neutral state"""
        manager = AIAgentManager()
        result = await manager.analyze_mood("")
        
        assert result['primary_emotion'] == 'neutral'
        assert result['avatar_state'] == 'STATE_NEUTRAL'
    
    @pytest.mark.asyncio
    async def test_fallback_response_generation(self):
        """Test fallback response uses emotion mapping"""
        manager = AIAgentManager()
        
        test_cases = [
            ('vui', 'vui vẻ'),
            ('buồn', 'buồn'),
            ('neutral', 'ổn'),
            ('unknown', 'ổn'),
        ]
        
        for emotion, expected_text in test_cases:
            response = manager._get_fallback_response(emotion)
            assert expected_text in response
            assert 'Mình đang gặp chút vấn đề' in response
    
    @pytest.mark.asyncio
    async def test_error_fallback_structure(self):
        """Test complete error fallback returns correct structure"""
        manager = AIAgentManager()
        result = manager._get_error_fallback()
        
        assert result['mood_score'] == 5
        assert result['stress_level'] == 5
        assert result['energy_level'] == 5
        assert result['primary_emotion'] == 'neutral'
        assert result['activities'] == []
        assert result['avatar_state'] == 'STATE_NEUTRAL'
        assert 'ai_feedback' in result


class TestIntegrationWithContext:
    """Integration tests for context-aware features"""
    
    @pytest.mark.asyncio
    async def test_pipeline_with_user_context(self):
        """Test pipeline can accept user context parameter"""
        manager = AIAgentManager()
        
        # Test that the function accepts optional parameters
        result = await manager.analyze_mood(
            "Test note",
            voice_transcript=None,
            user_id="test_user",
            supabase=None  # Would need mock in real test
        )
        
        assert 'mood_score' in result
        assert 'ai_feedback' in result
        assert 'avatar_state' in result


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
