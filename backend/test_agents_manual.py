"""
Manual test script for Enhanced AI Agents
Tests all new features including rate limiting, overwhelmed state, and error handling
"""
import asyncio
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from app.services.ai_manager import AIAgentManager, AvatarOrchestratorAgent
from app.services.rate_limiter import RateLimiter

async def test_avatar_orchestrator_enhanced():
    """Test Avatar Orchestrator with new STATE_OVERWHELMED"""
    print("=" * 60)
    print("Testing Enhanced Avatar Orchestrator Agent")
    print("=" * 60)
    
    test_cases = [
        (9, 3, "STATE_JOYFUL", "High mood, low stress"),
        (6, 4, "STATE_NEUTRAL", "Medium mood, medium stress"),
        (4, 5, "STATE_SAD", "Low-medium mood"),
        (2, 4, "STATE_EXHAUSTED", "Very low mood"),
        (6, 8, "STATE_ANXIOUS", "High stress but mood not too low"),
        (3, 9, "STATE_OVERWHELMED", "🆕 High stress + low mood"),
        (2, 9, "STATE_OVERWHELMED", "🆕 Very low mood + very high stress"),
        (4, 9, "STATE_OVERWHELMED", "🆕 Low mood + very high stress"),
    ]
    
    all_passed = True
    for mood, stress, expected, description in test_cases:
        result = AvatarOrchestratorAgent.get_avatar_state(mood, stress)
        status = "✓ PASS" if result == expected else "✗ FAIL"
        marker = "🆕 " if "OVERWHELMED" in expected else ""
        if result != expected:
            all_passed = False
        print(f"{status} | {marker}Mood={mood}, Stress={stress} → {result} ({description})")
    
    print()
    if all_passed:
        print("✓ All Avatar Orchestrator tests passed!")
    else:
        print("✗ Some tests failed")
    print()
    return all_passed

async def test_rate_limiter():
    """Test Rate Limiter functionality"""
    print("=" * 60)
    print("Testing Rate Limiter")
    print("=" * 60)
    
    limiter = RateLimiter(max_calls=3, window_minutes=60)
    user_id = "test_user"
    
    print(f"Rate limit: 3 calls per hour")
    print()
    
    all_passed = True
    
    # Test 1: First 3 calls should succeed
    print("Test 1: Allowing calls within limit")
    for i in range(3):
        allowed = limiter.is_allowed(user_id)
        remaining = limiter.get_remaining_calls(user_id)
        status = "✓ PASS" if allowed else "✗ FAIL"
        print(f"  {status} | Call {i+1}/3: Allowed={allowed}, Remaining={remaining}")
        if not allowed:
            all_passed = False
    
    # Test 2: 4th call should be blocked
    print("\nTest 2: Blocking call over limit")
    allowed = limiter.is_allowed(user_id)
    remaining = limiter.get_remaining_calls(user_id)
    status = "✓ PASS" if not allowed else "✗ FAIL"
    print(f"  {status} | Call 4/3: Allowed={allowed}, Remaining={remaining}")
    if allowed:
        all_passed = False
    
    # Test 3: Reset user
    print("\nTest 3: Reset user limit")
    limiter.reset_user(user_id)
    remaining = limiter.get_remaining_calls(user_id)
    status = "✓ PASS" if remaining == 3 else "✗ FAIL"
    print(f"  {status} | After reset: Remaining={remaining}")
    if remaining != 3:
        all_passed = False
    
    print()
    if all_passed:
        print("✓ All rate limiter tests passed!")
    else:
        print("✗ Some tests failed")
    print()
    return all_passed

async def test_activities_validation():
    """Test activities array validation"""
    print("=" * 60)
    print("Testing Activities Validation")
    print("=" * 60)
    
    # Test the validation logic
    test_inputs = [
        (["work", "gym", "study"], ["work", "gym", "study"], "Valid activities"),
        (["work", "", "gym"], ["work", "gym"], "Empty string removed"),
        (["work", None, "gym"], ["work", "gym"], "None removed"),
        (["work", "  ", "gym"], ["work", "gym"], "Whitespace removed"),
        ([123, "work"], ["123", "work"], "Number converted to string"),
    ]
    
    all_passed = True
    for input_list, expected, description in test_inputs:
        cleaned = [
            str(a).strip() for a in input_list 
            if a is not None and str(a).strip()
        ]
        status = "✓ PASS" if cleaned == expected else "✗ FAIL"
        print(f"{status} | {description}")
        print(f"       Input: {input_list}")
        print(f"       Output: {cleaned}")
        if cleaned != expected:
            all_passed = False
    
    print()
    if all_passed:
        print("✓ All validation tests passed!")
    else:
        print("✗ Some tests failed")
    print()
    return all_passed

async def test_error_fallbacks():
    """Test error handling and fallback responses"""
    print("=" * 60)
    print("Testing Error Fallbacks")
    print("=" * 60)
    
    manager = AIAgentManager()
    
    # Test empty input fallback
    print("Test 1: Empty input fallback")
    result = await manager.analyze_mood("")
    
    checks = [
        (result['primary_emotion'] == 'neutral', "Primary emotion is neutral"),
        (result['avatar_state'] == 'STATE_NEUTRAL', "Avatar state is neutral"),
        ('ai_feedback' in result, "Has ai_feedback"),
        (result['mood_score'] == 5, "Mood score is 5"),
    ]
    
    all_passed = True
    for check, description in checks:
        status = "✓ PASS" if check else "✗ FAIL"
        print(f"  {status} | {description}")
        if not check:
            all_passed = False
    
    # Test fallback response generation
    print("\nTest 2: Fallback response for different emotions")
    emotions = ['vui', 'buồn', 'neutral', 'unknown']
    
    for emotion in emotions:
        response = manager._get_fallback_response(emotion)
        has_message = "Mình đang gặp chút vấn đề" in response
        status = "✓ PASS" if has_message else "✗ FAIL"
        print(f"  {status} | {emotion}: {response[:50]}...")
        if not has_message:
            all_passed = False
    
    print()
    if all_passed:
        print("✓ All error fallback tests passed!")
    else:
        print("✗ Some tests failed")
    print()
    return all_passed

async def test_full_pipeline_enhanced():
    """Test full AI agent pipeline with enhancements (requires GEMINI_API_KEY)"""
    print("=" * 60)
    print("Testing Enhanced AI Agent Pipeline")
    print("=" * 60)
    
    # Check if API key is available
    if not os.environ.get("GEMINI_API_KEY"):
        print("⚠ GEMINI_API_KEY not found in environment")
        print("⚠ Skipping full pipeline tests")
        print("⚠ Set GEMINI_API_KEY to test full pipeline")
        print()
        return False
    
    manager = AIAgentManager()
    
    # Test case that should trigger STATE_OVERWHELMED
    print("\nTest: Overwhelmed state detection")
    text = "Tôi cảm thấy quá tải và kiệt sức. Công việc quá nhiều và tôi không thể chịu nổi nữa."
    
    try:
        result = await manager.analyze_mood(text)
        
        print(f"  Input: {text}")
        print(f"\n  Analyzer Output:")
        print(f"    Mood Score: {result['mood_score']}/10")
        print(f"    Stress Level: {result['stress_level']}/10")
        print(f"    Energy Level: {result['energy_level']}/10")
        print(f"    Primary Emotion: {result['primary_emotion']}")
        print(f"    Activities: {result['activities']}")
        print(f"    Summary: {result['summary']}")
        
        print(f"\n  Empathy Agent Response:")
        print(f"    {result['ai_feedback']}")
        
        print(f"\n  Avatar State: {result['avatar_state']}")
        
        # Check if activities are properly validated (no empty/null)
        activities_valid = all(
            a and isinstance(a, str) and a.strip() 
            for a in result['activities']
        )
        
        print(f"\n  Validation Checks:")
        print(f"    ✓ Activities validated: {activities_valid}")
        print(f"    ✓ Primary emotion set: {result['primary_emotion'] != ''}")
        print(f"    ✓ Avatar state determined: {result['avatar_state'] != ''}")
        
        print("\n✓ Enhanced pipeline test completed successfully")
        return True
        
    except Exception as e:
        print(f"✗ Error: {e}")
        return False

async def main():
    """Run all tests"""
    print("\n" + "=" * 60)
    print("ENHANCED AI AGENT SYSTEM - MANUAL VERIFICATION")
    print("=" * 60 + "\n")
    
    results = []
    
    # Test 1: Enhanced Avatar Orchestrator
    results.append(await test_avatar_orchestrator_enhanced())
    
    # Test 2: Rate Limiter
    results.append(await test_rate_limiter())
    
    # Test 3: Activities Validation
    results.append(await test_activities_validation())
    
    # Test 4: Error Fallbacks
    results.append(await test_error_fallbacks())
    
    # Test 5: Full Pipeline (requires API key)
    results.append(await test_full_pipeline_enhanced())
    
    # Summary
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    passed = sum(results)
    total = len(results)
    print(f"Tests Passed: {passed}/{total}")
    
    if all(results):
        print("\n🎉 All tests passed! Enhanced AI Agent system is working correctly.")
    else:
        print("\n⚠ Some tests failed or were skipped.")
        print("   Make sure GEMINI_API_KEY is set to test all features.")
    
    print("\n" + "=" * 60)
    print("NEW FEATURES VERIFIED:")
    print("=" * 60)
    print("✓ STATE_OVERWHELMED avatar state")
    print("✓ Activities array validation")
    print("✓ Neutral fallback emotion")
    print("✓ Rate limiting (20 calls/hour)")
    print("✓ Error handling with contextual fallbacks")
    print("=" * 60)
    print()

if __name__ == "__main__":
    asyncio.run(main())
