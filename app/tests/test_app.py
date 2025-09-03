from app.main import app
from fastapi.testclient import TestClient

client = TestClient(app)


def test_analyze_ok():
    resp = client.post("/analyze", json={"text": "I love cloud engineering!"})
    assert resp.status_code == 200
    data = resp.json()
    assert data["original_text"] == "I love cloud engineering!"
    assert data["word_count"] == 4
    # Character counts depend on definition; just sanity checks:
    assert data["character_count"] >= data["character_count_no_spaces"] > 0


def test_analyze_bad_request():
    resp = client.post("/analyze", json={"text": ""})
    assert resp.status_code == 422  # Pydantic validation triggers
