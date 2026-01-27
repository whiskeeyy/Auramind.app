"""
Rate Limiter for AI API calls
Simple in-memory rate limiter to prevent abuse on free tier
"""
from datetime import datetime, timedelta
from collections import defaultdict
import threading
from typing import Dict, List

class RateLimiter:
    """
    Simple in-memory rate limiter for AI API calls per user
    
    For production, consider using Redis or Supabase Edge Functions
    for distributed rate limiting across multiple server instances.
    """
    
    def __init__(self, max_calls: int = 20, window_minutes: int = 60):
        """
        Initialize rate limiter
        
        Args:
            max_calls: Maximum number of calls allowed per window
            window_minutes: Time window in minutes
        """
        self.max_calls = max_calls
        self.window = timedelta(minutes=window_minutes)
        self.calls: Dict[str, List[datetime]] = defaultdict(list)
        self.lock = threading.Lock()
    
    def is_allowed(self, user_id: str) -> bool:
        """
        Check if user is allowed to make an AI call
        
        Args:
            user_id: User ID to check
            
        Returns:
            True if allowed, False if rate limited
        """
        with self.lock:
            now = datetime.utcnow()
            
            # Remove calls outside the current window
            self.calls[user_id] = [
                call_time for call_time in self.calls[user_id]
                if now - call_time < self.window
            ]
            
            # Check if user has exceeded the limit
            if len(self.calls[user_id]) >= self.max_calls:
                return False
            
            # Record this call
            self.calls[user_id].append(now)
            return True
    
    def get_remaining_calls(self, user_id: str) -> int:
        """
        Get number of remaining calls for a user
        
        Args:
            user_id: User ID to check
            
        Returns:
            Number of remaining calls in current window
        """
        with self.lock:
            now = datetime.utcnow()
            
            # Remove calls outside the current window
            self.calls[user_id] = [
                call_time for call_time in self.calls[user_id]
                if now - call_time < self.window
            ]
            
            return max(0, self.max_calls - len(self.calls[user_id]))
    
    def reset_user(self, user_id: str):
        """
        Reset rate limit for a specific user
        
        Args:
            user_id: User ID to reset
        """
        with self.lock:
            if user_id in self.calls:
                del self.calls[user_id]
    
    def cleanup_old_entries(self):
        """
        Remove all expired entries to free memory
        Should be called periodically
        """
        with self.lock:
            now = datetime.utcnow()
            users_to_remove = []
            
            for user_id, call_times in self.calls.items():
                # Remove expired calls
                self.calls[user_id] = [
                    call_time for call_time in call_times
                    if now - call_time < self.window
                ]
                
                # Mark empty users for removal
                if not self.calls[user_id]:
                    users_to_remove.append(user_id)
            
            # Remove users with no active calls
            for user_id in users_to_remove:
                del self.calls[user_id]

# Singleton instance
rate_limiter = RateLimiter(max_calls=20, window_minutes=60)

def get_rate_limiter() -> RateLimiter:
    """Dependency injection for FastAPI"""
    return rate_limiter
