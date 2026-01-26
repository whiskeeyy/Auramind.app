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

def get_mock_ai_manager():
    return mock_manager

app.dependency_overrides[get_ai_manager] = get_mock_ai_manager

def test_chat_endpoint():
    payload = {"message": "I am feeling sad today."}
    response = client.post("/chat/", json=payload)
    assert response.status_code == 200
    assert response.json()["reply"] == "I understand completely."
