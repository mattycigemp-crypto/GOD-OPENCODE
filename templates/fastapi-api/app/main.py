from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import health

app = FastAPI(
    title="{{PROJECT_NAME}}",
    version="0.1.0",
    description="Production FastAPI application",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router, prefix="/api/v1")


@app.get("/")
async def root():
    return {"status": "ok", "service": "{{PROJECT_NAME}}"}
