from fastapi.testclient import TestClient
from app.main import app
from app.core import get_supabase
from app.auth import get_current_user
from unittest.mock import MagicMock
import pytest

client = TestClient(app)

# Mock Supabase
mock_supabase = MagicMock()
mock_table = MagicMock()
mock_supabase.table.return_value = mock_table

def override_get_supabase():
    return mock_supabase

# Mock authentication - return a test user ID
MOCK_USER_ID = "550e8400-e29b-41d4-a716-446655440001"

async def override_get_current_user():
    return MOCK_USER_ID

app.dependency_overrides[get_supabase] = override_get_supabase
app.dependency_overrides[get_current_user] = override_get_current_user

def test_read_main():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Welcome to Auramind API", "status": "active"}

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_create_mood_log():
    # Setup mock return
    mock_data = [{
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "user_id": MOCK_USER_ID,  # Use mocked user ID
        "mood_score": 7,
        "stress_level": 3,
        "energy_level": 5,
        "note": "Feeling good",
        "activities": ["coding"],
        "voice_transcript": None,
        "ai_feedback": None,
        "created_at": "2026-01-26T12:00:00Z"
    }]
    mock_table.insert.return_value.execute.return_value.data = mock_data
    
    payload = {
        "mood_score": 7,
        "stress_level": 3,
        "energy_level": 5,
        "note": "Feeling good",
        "activities": ["coding"]
    }
    response = client.post("/mood-logs/", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["mood_score"] == 7
    assert data["id"] == "550e8400-e29b-41d4-a716-446655440000"

def test_get_mood_logs():
    mock_data = [{
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "user_id": "550e8400-e29b-41d4-a716-446655440001",
        "mood_score": 8,
        "stress_level": 2,
        "energy_level": 8,
        "created_at": "2026-01-26T12:00:00Z"
    }]
    mock_table.select.return_value.eq.return_value.execute.return_value.data = mock_data
    
    response = client.get("/mood-logs/")
    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0]["mood_score"] == 8
