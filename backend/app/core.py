import os
from supabase import create_client, Client
from dotenv import load_dotenv
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

load_dotenv()

# Environment variables
SUPABASE_URL: str = os.environ.get("SUPABASE_URL", "")
SUPABASE_ANON_KEY: str = os.environ.get("SUPABASE_ANON_KEY", "")

# Backward compatibility: if SUPABASE_ANON_KEY not set, fall back to SUPABASE_KEY
if not SUPABASE_ANON_KEY:
    SUPABASE_ANON_KEY = os.environ.get("SUPABASE_KEY", "")

if not SUPABASE_URL or not SUPABASE_ANON_KEY:
    raise ValueError(
        "SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env file. "
        "Get them from: https://app.supabase.com/project/_/settings/api\n"
        "CRITICAL: Use the ANON key (or PUBLISHABLE key), NOT the service_role key!"
    )

# Validate JWT secret is set (required for authentication)
jwt_secret: str = os.environ.get("SUPABASE_JWT_SECRET", "")
if not jwt_secret:
    print(
        "WARNING: SUPABASE_JWT_SECRET is not set. "
        "Authentication will not work properly. "
        "Please add it to your .env file."
    )

# Security scheme for extracting Bearer token
security_scheme = HTTPBearer()


def get_supabase_with_auth(
    credentials: HTTPAuthorizationCredentials = Depends(security_scheme)
) -> Client:
    """
    Create a per-request Supabase client with user's JWT forwarded.
    
    This enables Row Level Security (RLS) enforcement at the database layer.
    The client will use auth.uid() from the JWT to filter data automatically.
    
    CRITICAL: This function creates a NEW client for EACH request.
    Do NOT cache or make this global.
    
    Args:
        credentials: Bearer token from Authorization header
        
    Returns:
        Client: Authenticated Supabase client with RLS enabled
        
    Raises:
        HTTPException: If authentication token is missing
    """
    if not credentials:
        raise HTTPException(
            status_code=401, 
            detail="Missing authentication token"
        )
    
    user_jwt = credentials.credentials
    
    # Create client with ANON key (not service_role!)
    client = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)
    
    # Forward user's JWT to enable RLS
    # Supabase will verify the JWT and set auth.uid() for RLS policies
    client.postgrest.auth(user_jwt)
    
    return client


# Optional: For endpoints that don't require auth (public data)
def get_supabase_anon() -> Client:
    """
    Anonymous client for public data access.
    Use only for truly public endpoints.
    
    Returns:
        Client: Anonymous Supabase client (no user context)
    """
    return create_client(SUPABASE_URL, SUPABASE_ANON_KEY)


# Legacy function for backward compatibility
# DEPRECATED: Use get_supabase_with_auth instead
def get_supabase() -> Client:
    """
    DEPRECATED: Returns anonymous client without user context.
    
    This function is kept for backward compatibility but should NOT be used
    for user-specific data operations as it bypasses RLS.
    
    Use get_supabase_with_auth instead to enforce Row Level Security.
    """
    return get_supabase_anon()
