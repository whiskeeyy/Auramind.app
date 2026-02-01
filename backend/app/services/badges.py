from datetime import datetime, time
import logging
from typing import List, Optional
from app.models.calendar import HealthSummary

class BadgeService:
    """
    Service to evaluate and award badges based on user activity.
    """
    
    BADGES = {
        "FIRST_STEP": "Ghi nhật ký lần đầu tiên",
        "STREAK_3": "Chuỗi 3 ngày liên tiếp",
        "STREAK_7": "Chuỗi 7 ngày liên tiếp",
        "STREAK_30": "Chuỗi 30 ngày liên tiếp",
        "EARLY_BIRD": "Thức dậy sớm (5:00 - 8:00)",
        "NIGHT_OWL": "Cú đêm (23:00 - 4:00)",
        "BALANCE_MASTER": "Cân bằng hoàn hảo (Mood tốt + Ngủ đủ)",
        "ACTIVE_SOUL": "Tâm hồn năng động (5000+ bước chân)"
    }

    def __init__(self, supabase_client):
        self.supabase = supabase_client

    async def check_new_badges(self, user_id: str, new_log: dict, current_profile: dict) -> List[dict]:
        """
        Evaluate rules and return list of newly earned badges.
        
        Args:
            user_id: User UUID
            new_log: Dict containing the new mood log data
            current_profile: Dict containing profile data (streak, logs count, etc.)
            
        Returns:
            List of new badge objects: [{'code': 'STREAK_3', 'name': '...'}]
        """
        newly_earned = []
        
        # 1. Get existing badges to avoid duplicates
        existing_badges_response = self.supabase.table("user_achievements")\
            .select("badge_code").eq("user_id", user_id).execute()
        existing_codes = {b['badge_code'] for b in existing_badges_response.data}

        # 2. Define Rules
        potential_badges = []

        # --- Rule: FIRST_STEP ---
        # If this is the first log (conceptually), but profile might not be updated yet appropriately depending on trigger timing.
        # A safer check is if 'longest_streak' is 0 or 1 and no logs existed before.
        # But simplify: if not in existing_codes
        potential_badges.append("FIRST_STEP")

        # --- Rule: STREAK Badges ---
        streak = current_profile.get('current_streak', 0)
        # Note: The trigger usually updates streak AFTER insert. 
        # If we call this AFTER insert, we should fetch the updated profile first.
        # For simplicity, we assume we pass the *updated* profile or handle offset.
        
        if streak >= 3: potential_badges.append("STREAK_3")
        if streak >= 7: potential_badges.append("STREAK_7")
        if streak >= 30: potential_badges.append("STREAK_30")

        # --- Rule: Time Based ---
        # Parse created_at (which is usually UTC in DB, but let's check local time if possible or rely on simple hour check)
        # Assuming new_log['created_at'] is ISO string or datetime
        # For MVP, we'll check the current server time if created_at isn't passed explicitly or parse it.
        created_at = datetime.fromisoformat(new_log['created_at'].replace('Z', '+00:00')) if isinstance(new_log.get('created_at'), str) else datetime.now()
        
        # Simple hour check (UTC adjustment needed if we want local user time, but ignoring for MVP simplification)
        # Let's assume input log might have 'local_time' or we use strict UTC windows.
        # Logic: Early Bird 5-8 AM, Night Owl 23-4
        hour = created_at.hour
        if 5 <= hour < 8:
            potential_badges.append("EARLY_BIRD")
        elif hour >= 23 or hour < 4:
            potential_badges.append("NIGHT_OWL")

        # --- Rule: Health & Mood (BALANCE_MASTER) ---
        mood = new_log.get('mood_score', 0)
        health = new_log.get('health_metrics') or {}
        sleep = health.get('sleep_hours', 0)
        steps = health.get('steps', 0) # Support 'steps' or 'total_steps' key

        if mood >= 7 and sleep >= 7:
            potential_badges.append("BALANCE_MASTER")
            
        if steps >= 5000:
            potential_badges.append("ACTIVE_SOUL")

        # 3. Filter and Insert New Badges
        for code in potential_badges:
            if code not in existing_codes:
                try:
                    # Insert into DB
                    data = {
                        "user_id": user_id,
                        "badge_code": code,
                        "earned_at": datetime.now().isoformat()
                    }
                    self.supabase.table("user_achievements").insert(data).execute()
                    
                    # Add to result
                    newly_earned.append({
                        "code": code,
                        "name": self.BADGES.get(code, code),
                        "description": "Bạn đã mở khóa thành tựu mới!"
                    })
                    existing_codes.add(code) # Prevent double add in same loop
                except Exception as e:
                    logging.error(f"Error awarding badge {code}: {e}")

        return newly_earned
