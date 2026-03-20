from fastapi.testclient import TestClient
from app.main import app
from app.services.ai_manager import get_ai_manager
from unittest.mock import MagicMock, AsyncMock
import pytest

client = TestClient(app)

# Create a mock manager
mock_manager = MagicMock()
mock_manager.empathizer = MagicMock()
# Async mocking for the respond method
mock_manager.empathizer.respond = AsyncMock(return_value="I understand completely.")
mock_manager.chat = AsyncMock(return_value={"reply": "I understand completely.", "avatar_state": "STATE_NEUTRAL"})

def get_mock_ai_manager():
    return mock_manager

app.dependency_overrides[get_ai_manager] = get_mock_ai_manager

from app.auth import get_current_user
from app.core import get_supabase_with_auth

MOCK_USER_ID = "550e8400-e29b-41d4-a716-446655440001"

async def override_get_current_user():
    return MOCK_USER_ID

mock_supabase = MagicMock()
mock_table = MagicMock()
mock_supabase.table.return_value = mock_table

def override_get_supabase():
    return mock_supabase

app.dependency_overrides[get_current_user] = override_get_current_user
app.dependency_overrides[get_supabase_with_auth] = override_get_supabase

def test_chat_endpoint():
    payload = {"message": "I am feeling sad today."}
    response = client.post("/chat/", json=payload)
    assert response.status_code == 200
    assert response.json()["reply"] == "I understand completely."
