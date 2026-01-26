from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Auramind API",
    description="Backend for Auramind - Digital Companion",
    version="0.1.0"
)

# CORS (Allow all for MVP dev)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Welcome to Auramind API", "status": "active"}

@app.get("/health")
async def health_check():
    return {"status": "ok"}

from app.routers import mood, chat
app.include_router(mood.router)
app.include_router(chat.router)
