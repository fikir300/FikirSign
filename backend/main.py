
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import sqlite3

app = FastAPI(title="Fikr Sign API")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

DATABASE = "feedback.db"


def setup_database():
    with sqlite3.connect(DATABASE) as conn:
        conn.execute("""
            CREATE TABLE IF NOT EXISTS feedback (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                message TEXT NOT NULL,
                rating INTEGER NOT NULL
            )
        """)


setup_database()


class Feedback(BaseModel):
    message: str
    rating: int


@app.get("/")
def home():
    return {"message": "Fikr Sign API is running"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.post("/feedback")
def submit_feedback(feedback: Feedback):
    with sqlite3.connect(DATABASE) as conn:
        cursor = conn.execute(
            "INSERT INTO feedback (message, rating) VALUES (?, ?)",
            (feedback.message, feedback.rating)
        )
        feedback_id = cursor.lastrowid

    return {
        "message": "Feedback saved successfully",
        "id": feedback_id,
        "feedback": feedback.model_dump()
    }


@app.get("/feedback")
def list_feedback():
    with sqlite3.connect(DATABASE) as conn:
        conn.row_factory = sqlite3.Row
        rows = conn.execute(
            "SELECT id, message, rating FROM feedback ORDER BY id DESC"
        ).fetchall()

    return {"feedback": [dict(row) for row in rows]}
