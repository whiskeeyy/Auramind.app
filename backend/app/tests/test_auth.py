import pytest
import os
from datetime import datetime, timedelta
import jwt
from fastapi import HTTPException
from fastapi.security import HTTPAuthorizationCredentials

# IMPORTANT: Set environment variable BEFORE importing auth module
TEST_JWT_SECRET = "test-secret-key-for-unit-tests"
os.environ["SUPABASE_JWT_SECRET"] = TEST_JWT_SECRET

# Now import auth module (it will use the TEST_JWT_SECRET)
from app.auth import verify_jwt_token, get_current_user


def create_test_token(user_id: str, exp_delta: timedelta = timedelta(hours=1)) -> str:
    """Helper function to create test JWT tokens"""
    payload = {
        "sub": user_id,
        "aud": "authenticated",
        "exp": datetime.utcnow() + exp_delta,
        "iat": datetime.utcnow()
    }
    return jwt.encode(payload, TEST_JWT_SECRET, algorithm="HS256")


def test_verify_valid_token():
    """Test that a valid JWT token is correctly verified"""
    user_id = "550e8400-e29b-41d4-a716-446655440000"
    token = create_test_token(user_id)
    
    payload = verify_jwt_token(token)
    
    assert payload["sub"] == user_id
    assert payload["aud"] == "authenticated"


def test_verify_expired_token():
    """Test that expired tokens raise HTTPException"""
    user_id = "550e8400-e29b-41d4-a716-446655440000"
    # Create token that expired 1 hour ago
    token = create_test_token(user_id, exp_delta=timedelta(hours=-1))
    
    with pytest.raises(HTTPException) as exc_info:
        verify_jwt_token(token)
    
    assert exc_info.value.status_code == 401
    assert "expired" in exc_info.value.detail.lower()


def test_verify_invalid_signature():
    """Test that tokens with invalid signature raise HTTPException"""
    user_id = "550e8400-e29b-41d4-a716-446655440000"
    # Create token with different secret
    payload = {
        "sub": user_id,
        "aud": "authenticated",
        "exp": datetime.utcnow() + timedelta(hours=1)
    }
    token = jwt.encode(payload, "wrong-secret", algorithm="HS256")
    
    with pytest.raises(HTTPException) as exc_info:
        verify_jwt_token(token)
    
    assert exc_info.value.status_code == 401
    assert "invalid" in exc_info.value.detail.lower()


def test_verify_malformed_token():
    """Test that malformed tokens raise HTTPException"""
    malformed_token = "not.a.valid.jwt.token"
    
    with pytest.raises(HTTPException) as exc_info:
        verify_jwt_token(malformed_token)
    
    assert exc_info.value.status_code == 401


def test_verify_token_missing_user_id():
    """Test that tokens without 'sub' claim can be decoded but have no user_id"""
    payload = {
        "aud": "authenticated",
        "exp": datetime.utcnow() + timedelta(hours=1)
    }
    token = jwt.encode(payload, TEST_JWT_SECRET, algorithm="HS256")
    
    # This should decode successfully but have no 'sub'
    decoded = verify_jwt_token(token)
    assert decoded.get("sub") is None


@pytest.mark.asyncio
async def test_get_current_user_success():
    """Test successful user extraction from valid token"""
    user_id = "550e8400-e29b-41d4-a716-446655440000"
    token = create_test_token(user_id)
    
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)
    
    extracted_user_id = await get_current_user(credentials)
    
    assert extracted_user_id == user_id


@pytest.mark.asyncio
async def test_get_current_user_no_sub():
    """Test that missing 'sub' claim raises HTTPException"""
    payload = {
        "aud": "authenticated",
        "exp": datetime.utcnow() + timedelta(hours=1)
    }
    token = jwt.encode(payload, TEST_JWT_SECRET, algorithm="HS256")
    
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)
    
    with pytest.raises(HTTPException) as exc_info:
        await get_current_user(credentials)
    
    assert exc_info.value.status_code == 401
    assert "user ID not found" in exc_info.value.detail


@pytest.mark.asyncio
async def test_get_current_user_expired_token():
    """Test that expired token raises HTTPException in get_current_user"""
    user_id = "550e8400-e29b-41d4-a716-446655440000"
    token = create_test_token(user_id, exp_delta=timedelta(hours=-1))
    
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)
    
    with pytest.raises(HTTPException) as exc_info:
        await get_current_user(credentials)
    
    assert exc_info.value.status_code == 401
    assert "expired" in exc_info.value.detail.lower()


@pytest.mark.asyncio
async def test_get_current_user_none_credentials():
    """Test that None credentials raises HTTPException"""
    with pytest.raises(HTTPException) as exc_info:
        await get_current_user(None)
    
    assert exc_info.value.status_code == 401
    assert "missing" in exc_info.value.detail.lower()
