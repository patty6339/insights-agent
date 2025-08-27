from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import Optional
import uvicorn

app = FastAPI(title="Insight-Agent", version="0.1.0")


class AnalyzeRequest(BaseModel):
    text: str = Field(..., min_length=1, description="Text to analyze")


class AnalyzeResponse(BaseModel):
    original_text: str
    word_count: int
    character_count: int
    character_count_no_spaces: int
    note: Optional[str] = None


@app.post("/analyze", response_model=AnalyzeResponse)
def analyze(payload: AnalyzeRequest):
    try:
        text = payload.text
        words = text.split()
        word_count = len(words)
        char_count = len(text)
        char_count_no_spaces = len(text.replace(" ", ""))

        return AnalyzeResponse(
            original_text=text,
            word_count=word_count,
            character_count=char_count,
            character_count_no_spaces=char_count_no_spaces,
            note="MVP analysis; extend here with sentiment/LLM later.",
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8080, log_level="info")
