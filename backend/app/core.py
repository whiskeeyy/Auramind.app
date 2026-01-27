import os
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

url: str = os.environ.get("SUPABASE_URL", "https://xyz.supabase.co")
key: str = os.environ.get("SUPABASE_KEY", "dummy-key")

# Validate JWT secret is set (required for authentication)
jwt_secret: str = os.environ.get("SUPABASE_JWT_SECRET", "")
if not jwt_secret and url != "https://xyz.supabase.co":
    print(
        "WARNING: SUPABASE_JWT_SECRET is not set. "
        "Authentication will not work properly. "
        "Please add it to your .env file."
    )

# Lazy initialization or just global
supabase: Client = create_client(url, key)

def get_supabase() -> Client:
    return supabase

