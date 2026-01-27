import os
from typing import Optional
from fastapi import HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt
from dotenv import load_dotenv

load_dotenv()

# Security scheme for Bearer token (required authentication)
security = HTTPBearer()

# Security scheme for optional authentication
security_optional = HTTPBearer(auto_error=False)

# Get JWT secret from environment
SUPABASE_JWT_SECRET = os.environ.get("SUPABASE_JWT_SECRET")

if not SUPABASE_JWT_SECRET:
    raise ValueError(
        "SUPABASE_JWT_SECRET environment variable is not set. "
        "Please add it to your .env file. You can find it in your Supabase project settings "
        "under Settings > API > JWT Secret."
    )


def verify_jwt_token(token: str) -> dict:
    """
    Verify and decode a Supabase JWT token.
    
    Args:
        token: The JWT token string to verify
        
    Returns:
        dict: Decoded token payload containing user information
        
    Raises:
        HTTPException: If token is invalid, expired, or malformed
    """
    try:
        # Decode and verify the JWT token
        # Supabase uses HS256 algorithm by default
        payload = jwt.decode(
            token,
            SUPABASE_JWT_SECRET,
            algorithms=["HS256"],
            audience="authenticated"  # Supabase default audience
        )
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=401,
            detail="Token has expired. Please login again."
        )
    except jwt.InvalidTokenError as e:
        raise HTTPException(
            status_code=401,
            detail=f"Invalid authentication token: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=401,
            detail=f"Authentication failed: {str(e)}"
        )


async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Security(security)
) -> str:
    """
    FastAPI dependency to extract and verify the current authenticated user.
    
    This dependency should be used in route handlers that require authentication.
    It extracts the JWT token from the Authorization header, verifies it,
    and returns the user ID.
    
    Usage:
        @router.get("/protected")
        async def protected_route(user_id: str = Depends(get_current_user)):
            # user_id is the authenticated user's UUID
            pass
    
    Args:
        credentials: HTTP Authorization credentials (Bearer token)
        
    Returns:
        str: The authenticated user's UUID
        
    Raises:
        HTTPException: If authentication fails
    """
    # Check if credentials are provided (should always be true with auto_error=True)
    if credentials is None:
        raise HTTPException(
            status_code=401,
            detail="Authorization header missing"
        )
    
    token = credentials.credentials
    payload = verify_jwt_token(token)
    
    # Extract user ID from token payload
    user_id = payload.get("sub")
    
    if not user_id:
        raise HTTPException(
            status_code=401,
            detail="Invalid token: user ID not found"
        )
    
    return user_id


# Optional: Dependency for optional authentication
async def get_current_user_optional(
    credentials: Optional[HTTPAuthorizationCredentials] = Security(security_optional)
) -> Optional[str]:
    """
    Optional authentication dependency.
    Returns user_id if authenticated, None if not.
    Does not raise an error if no token is provided.
    
    Usage:
        @router.get("/public-or-private")
        async def route(user_id: Optional[str] = Depends(get_current_user_optional)):
            if user_id:
                # User is authenticated
                pass
            else:
                # User is not authenticated
                pass
    """
    if credentials is None:
        return None
    
    try:
        token = credentials.credentials
        payload = verify_jwt_token(token)
        user_id = payload.get("sub")
        return user_id
    except HTTPException:
        return None
