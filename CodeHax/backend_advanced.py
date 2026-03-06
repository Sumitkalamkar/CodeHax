from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from groq import Groq
import os
import logging
from datetime import datetime
from dotenv import load_dotenv
import json

# Load environment variables
load_dotenv()

# Configuration
GROQ_MODEL = "openai/gpt-oss-120b"  # Correct Groq model
TEMPERATURE = 0.3
MAX_TOKENS = 2000
TIMEOUT = 30

# Setup advanced logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="CodeHax - Hacker's Debug Bot",
    description="Elite code debugging with Groq AI",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Groq client
try:
    api_key = os.getenv("GROQ_API_KEY")
    if not api_key:
        raise ValueError("GROQ_API_KEY environment variable not set")
    client = Groq(api_key=api_key)
    logger.info("✓ Groq AI Client initialized successfully")
except Exception as e:
    logger.error(f"✗ Failed to initialize Groq: {e}")
    raise

# Pydantic Models
class CodeRequest(BaseModel):
    code: str
    error: str = ""
    language: str = "python"
    context: str = ""
    
    class Config:
        schema_extra = {
            "example": {
                "code": "def add(a, b):\n    return a + b",
                "error": "TypeError",
                "language": "python",
                "context": "Function should handle edge cases"
            }
        }

class DebugResponse(BaseModel):
    solution: str
    explanation: str
    fixed_code: str
    tips: list[str]

class HealthResponse(BaseModel):
    status: str
    model: str
    version: str
    timestamp: str = None
    
    def __init__(self, **data):
        super().__init__(**data)
        if self.timestamp is None:
            self.timestamp = datetime.now().isoformat()

class RequestLog(BaseModel):
    timestamp: str
    language: str
    code_length: int
    has_error: bool
    response_length: int
    status: str

def parse_response(text: str) -> tuple:
    """
    Parse Groq response and extract sections.
    More robust parsing to handle various formatting.
    """
    
    solution = ""
    explanation = ""
    fixed_code = ""
    tips = []
    
    logger.info(f"Parsing response ({len(text)} characters)...")
    
    lines = text.split('\n')
    current_section = None
    section_content = {
        'solution': [],
        'explanation': [],
        'fixed_code': [],
        'tips': []
    }
    
    code_block_active = False
    
    for i, line in enumerate(lines):
        line_lower = line.lower().strip()
        
        # Detect section headers (case-insensitive)
        if 'solution:' in line_lower:
            current_section = 'solution'
            content = line.split(':', 1)[1].strip() if ':' in line else ''
            if content:
                section_content['solution'].append(content)
            logger.debug(f"Line {i}: Found SOLUTION section")
            
        elif 'explanation:' in line_lower:
            current_section = 'explanation'
            content = line.split(':', 1)[1].strip() if ':' in line else ''
            if content:
                section_content['explanation'].append(content)
            logger.debug(f"Line {i}: Found EXPLANATION section")
            
        elif 'fixed_code:' in line_lower or 'fixed code:' in line_lower:
            current_section = 'fixed_code'
            code_block_active = False
            content = line.split(':', 1)[1].strip() if ':' in line else ''
            if content and content not in ['```', '```python', '```javascript', '```java', '```cpp']:
                section_content['fixed_code'].append(content)
            logger.debug(f"Line {i}: Found FIXED_CODE section")
            
        elif 'tips:' in line_lower:
            current_section = 'tips'
            logger.debug(f"Line {i}: Found TIPS section")
            
        # Handle code blocks
        elif line.strip().startswith('```'):
            if current_section == 'fixed_code':
                code_block_active = not code_block_active
                logger.debug(f"Line {i}: Code block {'started' if code_block_active else 'ended'}")
            continue
            
        # Add content to current section
        elif current_section and line.strip():
            if current_section == 'tips':
                # Clean up tip bullets and formatting
                tip = line.strip()
                if tip.startswith('-') or tip.startswith('•') or tip.startswith('*'):
                    tip = tip[1:].strip()
                if tip and len(tip) > 3:  # Ignore very short lines
                    section_content['tips'].append(tip)
                    
            elif current_section == 'fixed_code':
                # Add code lines (skip markdown markers)
                if line.strip() not in ['```', '```python', '```javascript', '```java', '```cpp', '```rust', '```go']:
                    section_content['fixed_code'].append(line)
            else:
                # Add to solution/explanation
                section_content[current_section].append(line)
    
    # Join sections
    solution = '\n'.join(section_content['solution']).strip()
    explanation = '\n'.join(section_content['explanation']).strip()
    fixed_code = '\n'.join(section_content['fixed_code']).strip()
    tips = [t.strip() for t in section_content['tips'] if t.strip() and len(t) > 2]
    
    logger.info(f"✓ Parsed response - Solution: {len(solution)}ch, Explanation: {len(explanation)}ch, Code: {len(fixed_code)}ch, Tips: {len(tips)}")
    
    return solution, explanation, fixed_code, tips

@app.post("/debug", response_model=DebugResponse)
async def debug_code(request: CodeRequest):
    """
    Debug or generate code using Groq AI.
    Handles both debugging existing code and generating new code.
    """
    
    request_id = datetime.now().isoformat()
    logger.info(f"[{request_id}] New request - Language: {request.language}, Code: {len(request.code)}ch, Error: {bool(request.error)}")
    
    # Validate input
    if not request.code or not request.code.strip():
        logger.warning(f"[{request_id}] Empty code provided")
        raise HTTPException(status_code=400, detail="Code field is required")
    
    try:
        # Craft intelligent prompt
        prompt = f"""You are CodeHax, an elite hacker and code expert AI. Your mission: provide COMPLETE, WORKING CODE SOLUTIONS.

TASK INPUT:
Language: {request.language}
Request: {request.code}
{f'Error/Bug: {request.error}' if request.error else 'Task: Code generation or improvement'}
{f'Context: {request.context}' if request.context else ''}

CRITICAL INSTRUCTIONS:
1. ALWAYS provide COMPLETE, EXECUTABLE CODE
2. DO NOT use placeholders or '...'
3. DO NOT say "your code here" or similar
4. Provide REAL, WORKING CODE that can run immediately
5. Use proper {request.language} syntax

RESPONSE FORMAT (MANDATORY - Follow exactly):

SOLUTION:
One or two sentences explaining the fix/solution.

EXPLANATION:
2-4 sentences explaining how the code works and why.

FIXED_CODE:
```{request.language}
<COMPLETE WORKING CODE - REAL CODE, NOT PLACEHOLDERS>
```

TIPS:
- Practical tip 1 for improvement
- Practical tip 2 for code quality
- Practical tip 3 for best practices
- Practical tip 4 for performance

Remember: CODE MUST BE COMPLETE AND WORKING."""

        logger.info(f"[{request_id}] Calling Groq API with {GROQ_MODEL}...")
        
        # Call Groq API
        message = client.chat.completions.create(
            model=GROQ_MODEL,
            messages=[
                {
                    "role": "user",
                    "content": prompt
                }
            ],
            max_tokens=MAX_TOKENS,
            temperature=TEMPERATURE,
        )
        
        response_text = message.choices[0].message.content
        logger.info(f"[{request_id}] ✓ Groq response received ({len(response_text)}ch)")
        
        # Parse the response
        solution, explanation, fixed_code, tips = parse_response(response_text)
        
        # Ensure all fields have content
        if not solution:
            solution = "Solution generated successfully"
            logger.warning(f"[{request_id}] No solution extracted, using default")
        
        if not explanation:
            explanation = "Review the fixed code above for details"
            logger.warning(f"[{request_id}] No explanation extracted, using default")
        
        if not fixed_code or len(fixed_code) < 10:
            logger.warning(f"[{request_id}] No valid code extracted, using original code")
            fixed_code = request.code
        
        if not tips or len(tips) == 0:
            logger.warning(f"[{request_id}] No tips extracted, using defaults")
            tips = [
                "Handle edge cases properly",
                "Add input validation",
                "Include error handling",
                "Test with various inputs",
                "Keep code readable and maintainable"
            ]
        
        # Ensure we have max 5 tips
        tips = tips[:5]
        
        logger.info(f"[{request_id}] ✓ Response ready - Solution: {len(solution)}ch, Code: {len(fixed_code)}ch, Tips: {len(tips)}")
        
        return DebugResponse(
            solution=solution,
            explanation=explanation,
            fixed_code=fixed_code,
            tips=tips
        )
        
    except Exception as e:
        logger.error(f"[{request_id}] ✗ Error: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Error processing request: {str(e)}"
        )

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint with system status"""
    logger.info("Health check requested")
    return HealthResponse(
        status="online",
        model=GROQ_MODEL,
        version="1.0.0"
    )

@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "name": "CodeHax",
        "description": "Elite Code Debugger & Generator with Groq AI",
        "version": "1.0.0",
        "model": GROQ_MODEL,
        "status": "operational",
        "endpoints": {
            "debug": {
                "method": "POST",
                "path": "/debug",
                "description": "Debug or generate code"
            },
            "health": {
                "method": "GET",
                "path": "/health",
                "description": "System health check"
            },
            "docs": {
                "method": "GET",
                "path": "/docs",
                "description": "API documentation"
            }
        }
    }

if __name__ == "__main__":
    import uvicorn
    logger.info("=" * 70)
    logger.info("Starting CodeHax Advanced Backend Server")
    logger.info(f"Model: {GROQ_MODEL}")
    logger.info(f"Temperature: {TEMPERATURE}")
    logger.info(f"Max Tokens: {MAX_TOKENS}")
    logger.info("Server: http://0.0.0.0:8000")
    logger.info("API Docs: http://127.0.0.1:8000/docs")
    logger.info("=" * 70)
    uvicorn.run(app, host="0.0.0.0", port=8000)
