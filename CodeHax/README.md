# CodeHax 

<div align="center">

[![GitHub stars](https://img.shields.io/github/stars/yourusername/codehax?style=flat-square)](https://github.com/yourusername/codehax)
[![GitHub forks](https://img.shields.io/github/forks/yourusername/codehax?style=flat-square)](https://github.com/yourusername/codehax)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.11+-blue?style=flat-square&logo=python)](https://www.python.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue?style=flat-square&logo=flutter)](https://flutter.dev/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-green?style=flat-square&logo=fastapi)](https://fastapi.tiangolo.com/)
[![Groq](https://img.shields.io/badge/Groq-AI-orange?style=flat-square)](https://console.groq.com/)

**AI-powered code debugging chatbot with a hacker aesthetic interface**

[Quick Start](#quick-start) | [Documentation](#documentation) | [Features](#features) | [Deployment](#deployment) | [Contributing](#contributing)

</div>

---

## Overview

**CodeHax** is an intelligent code debugging assistant that analyzes your buggy code and provides instant solutions. Built with **Groq's lightning-fast AI**, it delivers fixes in seconds, not minutes.

Perfect for developers who want to:
- Debug faster - Get instant fixes with explanations
- Learn better - Understand *why* bugs happen
- Code confidently - Get tips to prevent issues
- Ship quicker - Spend less time debugging

---

## Features

### Smart Debugging
- Multi-language support - Python, JavaScript, Java, C++, Rust, and more
- Error analysis - Identifies root causes instantly
- Auto-fix generation - Provides corrected, working code
- Learning tips - Get best practices to prevent issues

### Hacker Aesthetic UI
- Terminal-style dark interface - Green monospace aesthetic
- Smooth animations - Delightful interactions
- Real-time responses - See fixes appear as you type
- Copy to clipboard - Share solutions easily

### Lightning-Fast AI
- Groq mixtral-8x7b - 10-30x faster than traditional LLMs
- Sub-2 second responses - For most code snippets
- Streaming support - Real-time feedback
- Efficient API calls - Minimal costs

### Production-Ready
- Fully containerized - Docker support included
- Auto-deployment - GitHub to Render auto-deploy
- HTTPS/SSL - Secure by default
- Error tracking - Built-in monitoring
- Scalable - Handles traffic spikes

---

## Tech Stack

```
Frontend:        Flutter 3.0+ (Dart)
Backend:         FastAPI (Python 3.11)
AI Engine:       Groq (mixtral-8x7b-32768)
Deployment:      Render.com / Docker / AWS
Database:        Optional (MongoDB Atlas free tier)
Monitoring:      CloudWatch / Sentry (free)
```

---

## Architecture

```
┌─────────────────┐         ┌──────────────────┐
│                 │         │                  │
│  Flutter App    │────────▶│  FastAPI Backend │
│  (UI Layer)     │         │  (Logic Layer)   │
│                 │◀────────│                  │
└─────────────────┘         └──────┬───────────┘
                                   │
                                   │
                            ┌──────▼──────────┐
                            │                 │
                            │  Groq AI        │
                            │  (mixtral-8x7b) │
                            │                 │
                            └─────────────────┘
```

---

## Quick Start

### Prerequisites
- [Flutter 3.0+](https://flutter.dev/docs/get-started/install)
- [Python 3.11+](https://www.python.org/)
- [Docker](https://www.docker.com/) (for deployment)
- [Groq API Key](https://console.groq.com) (free)

### Local Development (5 minutes)

#### Backend Setup

```bash
# Clone repository
git clone https://github.com/yourusername/codehax.git
cd codehax

# Create virtual environment
python -m venv venv

# Activate venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Create .env file
cp .env.example .env
# Edit .env and add your GROQ_API_KEY

# Run backend
python backend.py
# Server running on http://localhost:8000
```

#### Frontend Setup

```bash
# Create Flutter project
flutter create code_hax
cd code_hax

# Copy files
cp ../main.dart lib/main.dart
cp ../pubspec.yaml .

# Get dependencies
flutter pub get

# Update backend URL in lib/main.dart (line 63)
# final String backendUrl = 'http://YOUR_COMPUTER_IP:8000';

# Run app
flutter run
```

#### Test It

In Flutter app:
1. Select language: Python
2. Paste buggy code
3. Click "SCAN FOR BUGS"
4. Get instant fix

---

## Documentation

### API Endpoints

#### Health Check
```bash
GET /health

Response:
{
  "status": "online",
  "model": "mixtral-8x7b-32768",
  "version": "1.0.0"
}
```

#### Debug Code
```bash
POST /debug

Request:
{
  "code": "def add(a, b):\n    return a + b\n\nprint(add(5, '3'))",
  "error": "TypeError: unsupported operand type",
  "language": "python",
  "context": "Function should add two numbers"
}

Response:
{
  "solution": "Add type checking before addition",
  "explanation": "Python can't add int and str. Need to convert or validate types.",
  "fixed_code": "def add(a, b):\n    if not isinstance(a, (int, float)) or not isinstance(b, (int, float)):\n        raise TypeError('Both arguments must be numbers')\n    return a + b",
  "tips": [
    "Always validate input types",
    "Use type hints for clarity",
    "Consider using TypedDict for complex types"
  ]
}
```

### Supported Languages

| Language   | Status | Example                  |
|-----------|--------|--------------------------|
| Python    | Yes    | `def hello(): print("world")` |
| JavaScript| Yes    | `const x = 5;`          |
| Java      | Yes    | `public class Test {}`  |
| C++       | Yes    | `int main() {}`         |
| Rust      | Yes    | `fn main() {}`          |
| TypeScript| Yes    | `const x: number = 5;`  |
| Go        | Yes    | `func main() {}`        |
| C#        | Yes    | `class Program {}`      |

---

## Deployment

### Recommended: Render.com (5 minutes, FREE)

```bash
# 1. Push to GitHub
git add . && git commit -m "Deploy" && git push origin main

# 2. Go to https://render.com
# 3. Click "New Web Service"
# 4. Select GitHub repo
# 5. Set GROQ_API_KEY environment variable
# 6. Deploy!

# Your API: https://codehax-backend.onrender.com
```

**Why Render?**
- Completely FREE (no credit card)
- No auto-sleep
- Auto-deploy on git push
- HTTPS included
- Production-ready

See [RENDER_QUICKSTART.txt](RENDER_QUICKSTART.txt) for detailed guide.

### Other Options

| Platform      | Cost      | Setup Time | Notes              |
|---------------|-----------|------------|-------------------|
| Render        | FREE      | 5 min      | BEST               |
| Railway       | $5/mo     | 5 min      | Good alternative   |
| AWS App Runner| ~$10/mo   | 10 min     | If you want AWS    |
| Heroku        | $7/mo     | 5 min      | Traditional choice |
| Oracle Cloud  | FREE      | 20 min     | Advanced users     |

See [FREE_DEPLOYMENT.txt](FREE_DEPLOYMENT.txt) for all options.

---

## Usage Examples

### Example 1: Python Error

```python
# Input code with error
def calculate_total(items, tax_rate):
    return sum(items) * tax_rate + sum(items)

# Error: TypeErrors when items contain strings
result = calculate_total([10, 20, "30"], 0.1)
```

**CodeHax Response:**
```
SOLUTION: Validate item types before processing
EXPLANATION: sum() fails with mixed types. Filter or validate first.
FIXED_CODE: 
def calculate_total(items, tax_rate):
    items = [float(i) for i in items if isinstance(i, (int, float, str))]
    total = sum(items)
    return total * (1 + tax_rate)

TIPS:
- Use type hints: items: List[float]
- Consider using Pydantic for validation
- Add unit tests for edge cases
```

### Example 2: JavaScript Error

```javascript
// Input code
const fetchData = async () => {
  const response = await fetch('/api/data');
  const data = response.json();
  console.log(data);
}
```

**CodeHax Response:**
```
SOLUTION: await the json() parsing
EXPLANATION: json() returns a Promise, must await it
FIXED_CODE:
const fetchData = async () => {
  const response = await fetch('/api/data');
  const data = await response.json();
  console.log(data);
}

TIPS:
- Always await async operations
- Add error handling with try-catch
- Handle network failures gracefully
```

---

## Configuration

### Environment Variables

```env
# .env file
GROQ_API_KEY=gsk_xxxxxxxxxxxxxxxxxx     # Required
PYTHONUNBUFFERED=1                      # For logs
```

### Backend Settings

Edit `config.py`:

```python
GROQ_MODEL = "mixtral-8x7b-32768"  # AI model
TEMPERATURE = 0.3                   # 0=precise, 1=creative
MAX_TOKENS = 1500                   # Max response length
TIMEOUT = 30                         # Request timeout
```

### Flutter Settings

Edit `lib/main.dart` (line 63):

```dart
final String backendUrl = 'https://your-api-url.com';
```

---

## Performance

### Response Times
- First request: 2-3 seconds (model loading)
- Subsequent: 1-2 seconds
- Large code (50+ lines): 2-4 seconds
- Small snippets (10 lines): ~1 second

### Costs
- Render.com: FREE tier (750 hrs/month = 1 service 24/7)
- Groq API: ~$0.01-0.10 per request
- Monthly estimate: $5-20 for moderate usage

---

## Security

### Best Practices

**Environment Variables**
```bash
# Never hardcode API keys!
export GROQ_API_KEY="your_key_here"
```

**HTTPS Only**
- All production URLs are HTTPS
- SSL certificate auto-managed by Render

**API Key Rotation**
- Rotate Groq keys regularly
- Use Secrets Manager for production

**Rate Limiting**
- Groq free: 30 req/minute
- Implement queue for high traffic

**Input Validation**
- Code snippets max 1000 lines
- Language validated
- Timeout protection

---

## Development

### Running Tests

```bash
# Backend tests
python -m pytest tests/

# Flutter tests
flutter test
```

### Code Style

```bash
# Python
pip install black flake8
black backend.py
flake8 backend.py

# Dart
dart analyze
dart format lib/
```

### Docker Locally

```bash
# Build image
docker build -t codehax .

# Run container
docker run -p 8000:8000 \
  -e GROQ_API_KEY=your_key \
  codehax

# Using docker-compose
docker-compose up --build
```

---

## Roadmap

### Completed
- [x] Multi-language support
- [x] Hacker UI aesthetic
- [x] Free deployment
- [x] Auto-scaling
- [x] HTTPS support

### Planned
- [ ] Code explanation feature
- [ ] Performance optimization tips
- [ ] Security vulnerability detection
- [ ] Test case generation
- [ ] Dark/Light theme toggle
- [ ] Code syntax highlighting
- [ ] Debug history saving
- [ ] Share solutions via URL
- [ ] Browser extension
- [ ] VSCode plugin

---

## Contributing

We love contributions! Here's how to help:

### 1. Fork & Clone
```bash
git clone https://github.com/yourusername/codehax.git
cd codehax
```

### 2. Create Branch
```bash
git checkout -b feature/your-feature
```

### 3. Make Changes
```bash
# Write code
# Test thoroughly
# Follow style guide
```

### 4. Commit & Push
```bash
git add .
git commit -m "Add: your feature description"
git push origin feature/your-feature
```

### 5. Create Pull Request
- Go to GitHub
- Create PR with detailed description
- Wait for review

### Development Setup

```bash
# Install dev dependencies
pip install -r requirements-dev.txt

# Run linter
flake8 .

# Format code
black .

# Run tests
pytest
```

---

## License

MIT License - see [LICENSE](LICENSE) file for details

```
MIT License (c) 2024

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software")...
```

---

## Bug Reports

Found a bug? [Open an issue!](https://github.com/yourusername/codehax/issues)

**Please include:**
- Code snippet that triggers the bug
- Expected behavior
- Actual behavior
- Environment info (OS, Python version, etc.)

---

## Discussion

Have questions or ideas?

- [Read the docs](README.md)
- [Start a discussion](https://github.com/yourusername/codehax/discussions)
- [Chat on Discord](https://discord.gg/your-server)
- [Email us](mailto:hello@codehax.dev)

---

## Learning Resources

### Getting Started
1. [QUICKSTART.txt](QUICKSTART.txt) - 10-minute setup
2. [RENDER_QUICKSTART.txt](RENDER_QUICKSTART.txt) - Free deployment
3. [API_REFERENCE.md](API_REFERENCE.md) - API examples

### Deployment
- [FREE_DEPLOYMENT.txt](FREE_DEPLOYMENT.txt) - All free options
- [AWS_DEPLOYMENT.txt](AWS_DEPLOYMENT.txt) - AWS setup guide
- [DEPLOYMENT_CHECKLIST.txt](DEPLOYMENT_CHECKLIST.txt) - Step-by-step

### Understanding the Code
- `backend.py` - FastAPI server
- `backend_advanced.py` - Production version with logging
- `main.dart` - Flutter UI
- `config.py` - Configuration

---

## Authors

**Created by:** Sumit Pandurang Kalamkar  
**Version:** 1.0.0  
**Last Updated:** January 2025

---

## Show Your Support

If CodeHax helped you debug faster, consider:

- Star the repository
- Fork and contribute
- Share with friends
- Tweet about it

---

## Useful Links

- [Groq Console](https://console.groq.com) - Get API key
- [Render.com](https://render.com) - Deploy free
- [Flutter Docs](https://flutter.dev/docs) - Learn Flutter
- [FastAPI Docs](https://fastapi.tiangolo.com/) - Learn FastAPI
- [GitHub](https://github.com/yourusername/codehax) - Source code

---

<div align="center">

### Made with love for developers who want to debug faster

[Back to Top](#codehax---elite-code-debugger)

**[Live Demo](https://codehax-backend.onrender.com/docs)** | **[Report Bug](https://github.com/yourusername/codehax/issues)** | **[Request Feature](https://github.com/yourusername/codehax/issues)**

</div>
