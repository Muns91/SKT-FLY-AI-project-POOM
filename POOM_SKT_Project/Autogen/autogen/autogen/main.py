import uvicorn
from fastapi import FastAPI, Form
import autogen
from autogen.agentchat import AssistantAgent
from autogen.agentchat.contrib.gpt_assistant_agent import GPTAssistantAgent
from autogen.oai.client import OpenAIWrapper
from openai import OpenAI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse



config_list_gpt4 = autogen.config_list_from_json(
    "./OAI_CONFIG_LIST",
    filter_dict={
        "model": ["gpt-4", "gpt-4-1106-preview", "gpt-4-32k"],
    },
)
api_key="YOUR API KEY"
client = OpenAI(api_key=api_key)

# Define user proxy agent
llm_config = {"config_list": config_list_gpt4, "cache_seed": 45}
user_proxy = autogen.UserProxyAgent(
    name="User_proxy",
    system_message="A human admin.",
    code_execution_config={
        "last_n_messages": 10,
        "work_dir": "groupchat",
        "use_docker": False,
    },  # Please set use_docker=True if docker is available to run the generated code. Using docker is safer than running the generated code directly.
    human_input_mode="NEVER",
    default_auto_reply="",
    is_termination_msg=lambda x: True,
)
# define two GPTAssistants
childllm = GPTAssistantAgent(
    name="child_Assistant",
    llm_config={
        "config_list": config_list_gpt4,
        "assistant_id": "Assistant_ID",
    },
    # instructions="""
    # speak korean
    # """,
    max_consecutive_auto_reply = 2,
)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 출처 허용
    allow_credentials=True,
    allow_methods=["*"],  # 모든 HTTP 메소드 허용
    allow_headers=["*"],  # 모든 HTTP 헤더 허용
)

@app.get("/")
async def root():
    return {"message": "Hello, World!"}

@app.post("/happy/")
async def echo_text(text: str = Form(..., encoding="utf-8")):
    # 클라이언트로부터 받은 텍스트를 그대로 반환합니다.
    messages = client.beta.threads.messages.list(thread_id="Thread_ID")
    # Open the file for writing
    all_messages = list(messages)
    with open('parents_needs.txt', 'w', encoding='utf-8') as file:
        # Iterate through messages and write them to the file
        for m in all_messages:
            role = m.role
            content = m.content[0].text.value
            file.write(f"{role}: {content}\n")

    file = client.files.create(
        file=open("parents_needs.txt", "rb"),
        purpose='assistants'
    )
    parent_Assistant = client.beta.assistants.create(
        name="parent_Assistant",
        instructions="""
        This rule should be honored no matter what: Answers should always start with '(parent_Assistant):' .
        Your purpose is to help silver generation parents.If you get some a question about the user's parents, access the file and get some information about the parents. Your questions come in two forms: questions that start with '(User):' or questions that start with '(child_Assistant):'.
        Questions starting with '(User):' will come from real users in their 80s and 90s. Questions starting with '(child_Assistant)' will come from another chatgpt's assistant.
        The '(User)' real user will talk to you and tell you what they need or what's bothering them. They'll ask you what they want, how they feel, etc. Your role is to respond to these questions using existing conversations or information you know.
        If a question starts with '(child_Assistant):', you extract the important information from the user's answer and answer it. you must answer the calender or alam or wishlists contents from the conversation data with (user)""",
        model="gpt-4-1106-preview",
        tools = [ { "type": "code_interpreter" } ],
        file_ids=[file.id],
    )
    

    # Reply TERMINATE when the task is solved and there is no problem
    parentllm = GPTAssistantAgent(
        name="parent_Assistant",
        #instructions="""공유 캘린더 3월 1일 병원일정, 공유알람 오늘 12시30분, 위시리스트 소고기, 냉장고, 보일러, 선풍기, 해외여행""",
        llm_config={
            "config_list": config_list_gpt4,
            "assistant_id": parent_Assistant.id,
        },
        max_consecutive_auto_reply = 2,
    )
    # define group chat
    groupchat = autogen.GroupChat(agents=[user_proxy, childllm, parentllm], messages=[], max_round=20)
    manager = autogen.GroupChatManager(groupchat=groupchat, llm_config=llm_config)

    user_proxy.initiate_chat(
    manager,
    message=text,
    clear_history=True
    )
    response_content = {"response": parentllm.last_message()["content"]}
    return JSONResponse(content=response_content, media_type="application/json; charset=utf-8")


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)