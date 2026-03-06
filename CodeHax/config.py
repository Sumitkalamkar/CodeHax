"""
CodeHax Configuration
Edit these settings to customize behavior
"""

# API Configuration
GROQ_MODEL = "openai/gpt-oss-120b"  # Fast and efficient model
TEMPERATURE = 0.3  # 0=precise, 1=creative
MAX_TOKENS = 2000  # Max response length
TIMEOUT = 30  # Seconds

# Server Configuration
HOST = "0.0.0.0"
PORT = 8000
CORS_ORIGINS = ["*"]  # Allow all origins (change for production)

# Debug Configuration
DEBUG_MODE = True
LOG_REQUESTS = True

# Supported Languages
SUPPORTED_LANGUAGES = {
    "python": "Python",
    "javascript": "JavaScript",
    "java": "Java",
    "cpp": "C++",
    "rust": "Rust",
    "csharp": "C#",
    "go": "Go",
    "typescript": "TypeScript",
}

# System Prompt Components
SYSTEM_PREFIX = "You are an elite hacker/developer debugging code. Be direct, efficient, and give practical solutions."
RESPONSE_FORMAT = """Respond in this exact format:
SOLUTION: [Direct fix explanation]
EXPLANATION: [Why this happens]
FIXED_CODE: [Complete corrected code]
TIPS: 
- Tip 1
- Tip 2
- Tip 3"""
