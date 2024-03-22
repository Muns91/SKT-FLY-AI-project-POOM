from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

# 이 예제에서는 Assistant의 기능을 모방하는 함수를 만들겠습니다.
# 실제로는 OpenAI API를 호출하여 질문에 대한 답변을 받아야 합니다.
def mock_chatgpt_assistant(question: str) -> str:
    # 이 함수는 예제로 제공되며, 실제 구현에서는 OpenAI API를 호출해야 합니다.
    return f"이것은 질문에 대한 모의 답변입니다: {question}"

class Question(BaseModel):
    text: str

@app.post("/chat/")
async def chat(question: Question):
    if not question.text:
        raise HTTPException(status_code=400, detail="질문은 비어있을 수 없습니다.")
    answer = mock_chatgpt_assistant(question.text)
    return {"question": question.text, "answer": answer}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
