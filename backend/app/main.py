from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import jobs

app = FastAPI(title="EOS Job Summary API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:4200",  # Angular dev server
        "http://localhost:3000",  # Flutter web dev server
        "http://127.0.0.1:3000",
    ],
    allow_methods=["GET"],
    allow_headers=["*"],
)

app.include_router(jobs.router, prefix="/api")
