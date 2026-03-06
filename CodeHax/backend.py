from fastapi import FastAPI, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from groq import Groq
from datetime import datetime
from bson import ObjectId
import os
import logging
from dotenv import load_dotenv
import uuid
import resend
from pydantic import BaseModel, EmailStr
import random
from datetime import timedelta

# Import custom modules
from backend_database import get_users_collection, get_chat_history_collection
from backend_auth import hash_password, verify_password, create_access_token, get_user_id_from_token
from backend_models import (
    UserRegister, UserLogin, UserResponse, TokenResponse,
    ChatHistoryCreate, ChatHistoryResponse, SuccessResponse
)

# Load environment
load_dotenv()

# Logging setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI
app = FastAPI(
    title="CodeHax - Professional Edition",
    description="Code Debugger with MongoDB & Authentication",
    version="2.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Groq
try:
    groq_api_key = os.getenv("GROQ_API_KEY")
    if not groq_api_key:
        raise ValueError("GROQ_API_KEY not found")
    groq_client = Groq(api_key=groq_api_key)
    logger.info("✓ Groq API initialized")
except Exception as e:
    logger.error(f"✗ Groq initialization failed: {e}")
    raise


# ============================================
# AUTHENTICATION ENDPOINTS
# ============================================

@app.post("/auth/signup", response_model=TokenResponse)
async def signup(user_data: UserRegister):
    """Register new user"""
    logger.info(f"Signup attempt: {user_data.email}")
    
    users = get_users_collection()
    
    # Check if user exists
    existing = users.find_one({
        "$or": [
            {"email": user_data.email},
            {"username": user_data.username}
        ]
    })
    
    if existing:
        raise HTTPException(
            status_code=400,
            detail="User already exists"
        )
    
    # Create user
    try:
        new_user = {
            "username": user_data.username,
            "email": user_data.email,
            "password_hash": hash_password(user_data.password),
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
            "is_active": True
        }
        
        result = users.insert_one(new_user)
        user_id = str(result.inserted_id)
        
        # Create token
        token = create_access_token({"sub": user_id})
        
        logger.info(f"✓ User registered: {user_data.email}")
        
        return TokenResponse(
            access_token=token,
            user=UserResponse(
                _id=user_id,
                username=user_data.username,
                email=user_data.email,
                created_at=new_user["created_at"],
                is_active=True
            )
        )
    except Exception as e:
        logger.error(f"✗ Signup error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/auth/login", response_model=TokenResponse)
async def login(user_data: UserLogin):
    """Login user"""
    logger.info(f"Login attempt: {user_data.email}")
    
    users = get_users_collection()
    
    # Find user
    user = users.find_one({"email": user_data.email})
    
    if not user or not verify_password(user_data.password, user["password_hash"]):
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password"
        )
    
    # Create token
    user_id = str(user["_id"])
    token = create_access_token({"sub": user_id})
    
    logger.info(f"✓ User logged in: {user_data.email}")
    
    return TokenResponse(
        access_token=token,
        user=UserResponse(
            _id=user_id,
            username=user["username"],
            email=user["email"],
            created_at=user["created_at"],
            is_active=user["is_active"]
        )
    )

@app.get("/auth/verify")
async def verify_token(authorization: str = Header(None)):
    """Verify token"""
    if not authorization:
        raise HTTPException(status_code=401, detail="No token provided")
    
    token = authorization.replace("Bearer ", "")
    user_id = get_user_id_from_token(token)
    
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    users = get_users_collection()
    user = users.find_one({"_id": ObjectId(user_id)})
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return SuccessResponse(
        message="Token is valid",
        data={
            "user_id": user_id,
            "email": user["email"],
            "username": user["username"]
        }
    )


# ============================================
# USER ENDPOINTS
# ============================================

@app.get("/user/profile", response_model=UserResponse)
async def get_profile(authorization: str = Header(None)):
    """Get user profile"""
    if not authorization:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    token = authorization.replace("Bearer ", "")
    user_id = get_user_id_from_token(token)
    
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    users = get_users_collection()
    user = users.find_one({"_id": ObjectId(user_id)})
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return UserResponse(
        _id=str(user["_id"]),
        username=user["username"],
        email=user["email"],
        created_at=user["created_at"],
        is_active=user["is_active"]
    )


# ============================================
# CHAT HISTORY ENDPOINTS - WITH SESSION SUPPORT
# ============================================

@app.post("/chat/save")
async def save_chat(data: dict, authorization: str = Header(None)):
    """Save chat to history - GROUPS BY SESSION_ID (FIXED VERSION)"""

    if not authorization:
        raise HTTPException(status_code=401, detail="Not authenticated")

    token = authorization.replace("Bearer ", "")
    user_id = get_user_id_from_token(token)

    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")

    try:
        chat_history = get_chat_history_collection()

        session_id = data.get("session_id")

        if not session_id:
            raise HTTPException(status_code=400, detail="session_id is required")

        print("SESSION FROM FRONTEND:", session_id)

        record = {
            "user_id": user_id,
            "session_id": session_id,
            "user_prompt": data.get("user_prompt", ""),
            "ai_response": data.get("ai_response", ""),
            "fixed_code": data.get("fixed_code", ""),
            "tips": data.get("tips", []),
            "language": data.get("language", "python"),
            "response_type": data.get("response_type", "generation"),
            "timestamp": datetime.utcnow(),
        }

        result = chat_history.insert_one(record)

        logger.info(f"✓ Chat saved for user: {user_id} in session: {session_id}")

        return {
            "status": "success",
            "id": str(result.inserted_id),
            "session_id": session_id
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Save chat error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

    
@app.get("/chat/history")
async def get_history(
    page: int = 1,
    limit: int = 20,
    authorization: str = Header(None)
):
    """Get chat SESSIONS for user - GROUPS BY SESSION_ID"""
    if not authorization:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    token = authorization.replace("Bearer ", "")
    user_id = get_user_id_from_token(token)
    
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    try:
        chat_history = get_chat_history_collection()
        
        all_chats = list(chat_history.find(
            {"user_id": user_id}
        ).sort("timestamp", -1))
        
        sessions = {}
        for chat in all_chats:
            session_id = chat.get("session_id", chat['_id'])
            if session_id not in sessions:
                sessions[session_id] = {
                    "_id": str(chat["_id"]),
                    "session_id": session_id,
                    "user_id": chat["user_id"],
                    "user_prompt": chat.get("user_prompt", ""),
                    "ai_response": chat.get("ai_response", ""),
                    "fixed_code": chat.get("fixed_code", ""),
                    "tips": chat.get("tips", []),
                    "language": chat.get("language", "python"),
                    "timestamp": chat["timestamp"].isoformat(),
                    "message_count": 0
                }
            
            sessions[session_id]["message_count"] += 1
        
        sessions_list = list(sessions.values())
        total = len(sessions_list)
        
        skip = (page - 1) * limit
        items = sessions_list[skip:skip + limit]
        
        return {
            "success": True,
            "items": items,
            "total": total,
            "page": page,
            "limit": limit,
            "pages": (total + limit - 1) // limit
        }
    except Exception as e:
        logger.error(f"✗ Error fetching history: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/chat/session/{session_id}")
async def get_session_messages(
    session_id: str,
    authorization: str = Header(None)
):
    """Get ALL messages in a session"""
    if not authorization:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    token = authorization.replace("Bearer ", "")
    user_id = get_user_id_from_token(token)
    
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    try:
        chat_history = get_chat_history_collection()
        
        messages = list(chat_history.find({
            "user_id": user_id,
            "session_id": session_id
        }).sort("timestamp", 1))
        
        items = [
            {
                "_id": str(m["_id"]),
                "user_prompt": m.get("user_prompt", ""),
                "ai_response": m.get("ai_response", ""),
                "fixed_code": m.get("fixed_code", ""),
                "tips": m.get("tips", []),
                "language": m.get("language", "python"),
                "timestamp": m["timestamp"].isoformat()
            }
            for m in messages
        ]
        
        return {
            "success": True,
            "session_id": session_id,
            "messages": items,
            "total": len(items)
        }
    except Exception as e:
        logger.error(f"Error fetching session: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ============================================
# OTP ENDPOINTS
# ============================================

otp_store = {}

class EmailRequest(BaseModel):
    email: EmailStr

class VerifyRequest(BaseModel):
    email: EmailStr
    otp: str


@app.post("/auth/send-otp")
async def send_otp(data: EmailRequest):
    otp = str(random.randint(100000, 999999))

    otp_store[data.email] = {
        "otp": otp,
        "expires": datetime.utcnow() + timedelta(minutes=5)
    }

    try:
        resend.api_key = os.getenv("RESEND_API_KEY")
        resend.Emails.send({
            "from": "onboarding@resend.dev",
            "to": data.email,
            "subject": "CodeHax OTP Verification",
            "text": f"Your OTP is: {otp}"
        })
        logger.info(f"✓ OTP sent to {data.email}")
    except Exception as e:
        logger.error(f"✗ Email sending failed: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to send OTP: {str(e)}")

    return {"success": True}


@app.post("/auth/verify-otp")
async def verify_otp(data: VerifyRequest):

    record = otp_store.get(data.email)

    if not record:
        raise HTTPException(status_code=400, detail="OTP not found")

    if datetime.utcnow() > record["expires"]:
        raise HTTPException(status_code=400, detail="OTP expired")

    if record["otp"] != data.otp:
        raise HTTPException(status_code=400, detail="Invalid OTP")

    del otp_store[data.email]

    return {"success": True}


# ============================================
# CODE PROCESSING ENDPOINTS
# ============================================

def parse_response(text: str) -> tuple:
    """Parse Groq response"""
    solution = ""
    explanation = ""
    fixed_code = ""
    tips = []
    
    lines = text.split('\n')
    current_section = None
    section_content = {
        'solution': [],
        'explanation': [],
        'fixed_code': [],
        'tips': []
    }
    
    for line in lines:
        line_lower = line.lower().strip()
        
        if 'solution:' in line_lower:
            current_section = 'solution'
            content = line.split(':', 1)[1].strip() if ':' in line else ''
            if content:
                section_content['solution'].append(content)
        elif 'explanation:' in line_lower:
            current_section = 'explanation'
            content = line.split(':', 1)[1].strip() if ':' in line else ''
            if content:
                section_content['explanation'].append(content)
        elif 'fixed_code:' in line_lower:
            current_section = 'fixed_code'
            content = line.split(':', 1)[1].strip() if ':' in line else ''
            if content and content not in ['```', '```python']:
                section_content['fixed_code'].append(content)
        elif 'tips:' in line_lower:
            current_section = 'tips'
        elif current_section and line.strip():
            if current_section == 'tips':
                tip = line.strip()
                if tip.startswith('-') or tip.startswith('•'):
                    tip = tip[1:].strip()
                if tip:
                    section_content['tips'].append(tip)
            elif current_section == 'fixed_code':
                if line.strip() not in ['```', '```python']:
                    section_content['fixed_code'].append(line)
            else:
                section_content[current_section].append(line)
    
    solution = '\n'.join(section_content['solution']).strip()
    explanation = '\n'.join(section_content['explanation']).strip()
    fixed_code = '\n'.join(section_content['fixed_code']).strip()
    tips = [t for t in section_content['tips'] if t.strip()]
    
    return solution, explanation, fixed_code, tips


@app.post("/debug")
async def debug_code(request: dict, authorization: str = Header(None)):
    """Debug code (with session memory + continuous chat support)"""

    if not authorization:
        raise HTTPException(status_code=401, detail="Not authenticated")

    token = authorization.replace("Bearer ", "")
    user_id = get_user_id_from_token(token)

    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")

    try:
        code = request.get("code")
        language = request.get("language", "python")
        error = request.get("error", "")
        context = request.get("context", "")
        session_id = request.get("session_id")

        if not code:
            raise HTTPException(status_code=400, detail="Code is required")

        history_messages = []

        if session_id:
            chat_history = get_chat_history_collection()

            old_msgs = list(chat_history.find({
                "user_id": user_id,
                "session_id": session_id
            }).sort("timestamp", 1))

            for m in old_msgs:
                if m.get("user_prompt"):
                    history_messages.append({
                        "role": "user",
                        "content": m["user_prompt"]
                    })

                if m.get("ai_response"):
                    history_messages.append({
                        "role": "assistant",
                        "content": m["ai_response"]
                    })

        history_messages.append({
            "role": "system",
            "content": """You are an elite hacker and code expert.

Always respond in this format:

SOLUTION:
Short explanation.

EXPLANATION:
Detailed explanation.

FIXED_CODE:
Complete working code only.

TIPS:
- Tip 1
- Tip 2
- Tip 3
- Tip 4
"""
        })

        history_messages.append({
            "role": "user",
            "content": f"{code}\n\nLanguage: {language}\nError: {error}\nContext: {context}"
        })

        message = groq_client.chat.completions.create(
            model="openai/gpt-oss-120b",
            messages=history_messages,
            max_tokens=2000,
            temperature=0.3
        )

        response_text = message.choices[0].message.content
        solution, explanation, fixed_code, tips = parse_response(response_text)

        if not fixed_code:
            fixed_code = code
        if not tips:
            tips = ["Handle edge cases", "Add validation", "Test inputs"]

        return {
            "solution": solution or "Analysis complete",
            "explanation": explanation or "See code above",
            "fixed_code": fixed_code,
            "tips": tips[:5]
        }

    except Exception as e:
        logger.error(f"✗ Debug error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ============================================
# HEALTH ENDPOINTS
# ============================================

@app.get("/health")
async def health():
    """Health check"""
    return {
        "status": "online",
        "version": "2.0.0",
        "features": ["auth", "mongodb", "chat_history", "sessions"]
    }

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "name": "CodeHax Professional",
        "version": "2.0.0",
        "status": "ready"
    }

if __name__ == "__main__":
    import uvicorn
    logger.info("=" * 60)
    logger.info("CodeHax Professional Backend - Starting")
    logger.info("Features: Authentication, MongoDB, Chat History, Sessions")
    logger.info("=" * 60)
    uvicorn.run(app, host="0.0.0.0", port=8000)
