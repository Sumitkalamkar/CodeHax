from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
from bson import ObjectId



class UserRegister(BaseModel):
    """User registration request"""
    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr
    password: str = Field(..., min_length=6)
    
    class Config:
        schema_extra = {
            "example": {
                "username": "codehacker",
                "email": "user@example.com",
                "password": "SecurePassword123"
            }
        }

class UserLogin(BaseModel):
    """User login request"""
    email: EmailStr
    password: str
    
    class Config:
        schema_extra = {
            "example": {
                "email": "user@example.com",
                "password": "SecurePassword123"
            }
        }

class UserInDB(BaseModel):
    """User in database"""
    id: Optional[str] = Field(None, alias="_id")
    username: str
    email: str
    password_hash: str
    created_at: datetime
    updated_at: datetime
    is_active: bool = True
    
    class Config:
        populate_by_name = True

class UserResponse(BaseModel):
    """User response (without password)"""
    id: str = Field(alias="_id")
    username: str
    email: str
    created_at: datetime
    is_active: bool
    
    class Config:
        populate_by_name = True
        schema_extra = {
            "example": {
                "_id": "507f1f77bcf86cd799439011",
                "username": "codehacker",
                "email": "user@example.com",
                "created_at": "2024-01-15T10:30:00Z",
                "is_active": True
            }
        }

class TokenResponse(BaseModel):
    """Token response"""
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
    
    class Config:
        schema_extra = {
            "example": {
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "token_type": "bearer",
                "user": {
                    "_id": "507f1f77bcf86cd799439011",
                    "username": "codehacker",
                    "email": "user@example.com"
                }
            }
        }


class ChatHistoryCreate(BaseModel):
    """Create chat history record"""
    user_prompt: str
    ai_response: str
    language: str
    response_type: str = "generation"  # or "debug"
    
    class Config:
        schema_extra = {
            "example": {
                "user_prompt": "write python code for even numbers",
                "ai_response": "def is_even(n): return n % 2 == 0",
                "language": "python",
                "response_type": "generation"
            }
        }

class ChatHistory(BaseModel):
    """Chat history record"""
    id: Optional[str] = Field(None, alias="_id")
    user_id: str
    user_prompt: str
    ai_response: str
    fixed_code: Optional[str] = None
    tips: Optional[List[str]] = None
    language: str
    response_type: str
    timestamp: datetime
    
    class Config:
        populate_by_name = True
        schema_extra = {
            "example": {
                "_id": "507f1f77bcf86cd799439011",
                "user_id": "507f1f77bcf86cd799439012",
                "user_prompt": "write python code for even numbers",
                "ai_response": "Here's code to find even numbers",
                "fixed_code": "for n in range(1, 11):\n    if n % 2 == 0:\n        print(n)",
                "tips": ["Use modulo operator", "Handle edge cases"],
                "language": "python",
                "response_type": "generation",
                "timestamp": "2024-01-15T10:30:00Z"
            }
        }

class ChatHistoryResponse(BaseModel):
    """Chat history response"""
    id: str = Field(alias="_id")
    user_id: str
    user_prompt: str
    ai_response: str
    fixed_code: Optional[str]
    tips: Optional[List[str]]
    language: str
    response_type: str
    timestamp: datetime
    
    class Config:
        populate_by_name = True


class SuccessResponse(BaseModel):
    """Generic success response"""
    status: str = "success"
    message: str
    data: Optional[dict] = None
    
    class Config:
        schema_extra = {
            "example": {
                "status": "success",
                "message": "Operation completed successfully",
                "data": {}
            }
        }

class ErrorResponse(BaseModel):
    """Generic error response"""
    status: str = "error"
    message: str
    detail: Optional[str] = None
    
    class Config:
        schema_extra = {
            "example": {
                "status": "error",
                "message": "An error occurred",
                "detail": "Error details here"
            }
        }

class PaginatedResponse(BaseModel):
    """Paginated response"""
    items: List[dict]
    total: int
    page: int
    page_size: int
    total_pages: int


