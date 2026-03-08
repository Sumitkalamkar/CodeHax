<div align="center">

# ⚡ CodeHax

<img src="code_hax/Screenshot/logo.png" alt="CodeHax Logo" width="120" height="120" />

### `// your elite code assistant`

**AI-powered code debugging chatbot with a hacker aesthetic interface**

[Quick Start](#-quick-start) | [Documentation](#-documentation) | [Features](#-features) | [Deployment](#-deployment) | [Contributing](#-contributing)

---

![Stars](https://img.shields.io/github/stars/Sumitkalamkar/CodeHax?style=flat-square&color=00ff41)
![Forks](https://img.shields.io/github/forks/Sumitkalamkar/CodeHax?style=flat-square&color=00ff41)
![License](https://img.shields.io/github/license/Sumitkalamkar/CodeHax?style=flat-square&color=00ff41)
![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=flat-square&logo=python&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat-square&logo=flutter&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-009688?style=flat-square&logo=fastapi&logoColor=white)
![Groq](https://img.shields.io/badge/Groq-AI-F55036?style=flat-square)
![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-47A248?style=flat-square&logo=mongodb&logoColor=white)
![Vercel](https://img.shields.io/badge/Deployed-Vercel-000000?style=flat-square&logo=vercel&logoColor=white)

---

🌐 **Live Demo:** [https://codehax.vercel.app](https://codehax.vercel.app)  
📡 **API Docs:** [https://codehax-backend.onrender.com/docs](https://codehax-backend.onrender.com/docs)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Requirements](#-requirements)
- [Quick Start](#-quick-start)
- [Environment Variables](#-environment-variables)
- [API Documentation](#-api-documentation)
- [Deployment](#-deployment)
  - [Vercel (Frontend)](#vercel-frontend)
  - [Render (Backend)](#render-backend)
  - [AWS (Full Stack)](#aws-full-stack)
  - [Docker](#docker)
- [Keep Alive (Cron Job)](#-keep-alive)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🔥 Overview

**CodeHax** is a full-stack AI-powered code debugging and analysis chatbot. It helps developers instantly identify bugs, optimize code, and understand complex logic — all within a sleek, cyberpunk-themed interface.

Powered by **Groq's ultra-fast inference**, CodeHax delivers AI responses in milliseconds. It features full user authentication, persistent chat sessions stored in MongoDB, and email OTP verification.

> **"Don't just debug. Hack the solution."**

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🤖 **AI Code Debugging** | Instant bug detection and fixes powered by Groq AI |
| 💬 **Session Memory** | AI remembers full conversation context within sessions |
| 📚 **Neural Vault** | Chat history stored in MongoDB, grouped by session |
| 🔐 **JWT Authentication** | Secure login/signup with bcrypt password hashing |
| 📧 **Email OTP** | 6-digit OTP email verification via Resend API |
| 🌐 **Multi-Language** | Python, JavaScript, Java, C++, Rust, Go |
| 📱 **Fully Responsive** | Mobile, tablet and desktop layouts |
| ⚡ **Ultra Fast** | Groq LPU delivers sub-second AI responses |
| 🎨 **Hacker UI** | Dark cyberpunk aesthetic with neon green accents |

---

## 📸 Screenshots

<div align="center">

| Login Page | Signup Page |OTP Verification | Chat Interface |Debugger Interface|
|:---:|:---:|:---:|
| ![Login](code_hax/Screenshot/login_page.png) | ![Chat](code_hax/Screenshot/Neural_vault_chat.png) |![OTP](code_hax/Screenshot/signup_page.png) | ![Chat](code_hax/Screenshot/Neural_vault_chat.png) |![Chat](code_hax/Screenshot/Neural_vault_chat.png) |


</div>

---

## 🛠️ Tech Stack

### Frontend
| Technology | Version | Purpose |
|-----------|---------|---------|
| Flutter | 3.0+ | Cross-platform UI framework |
| Dart | 3.0+ | Programming language |
| google_fonts | ^6.1.0 | Custom fonts (RobotoMono) |
| flutter_markdown | ^0.7.7 | Render markdown in chat |
| flutter_secure_storage | ^9.0.0 | Secure token storage |
| http | ^1.1.0 | HTTP client for API calls |

### Backend
| Technology | Version | Purpose |
|-----------|---------|---------|
| Python | 3.10.11 | Backend language |
| FastAPI | 0.104.1 | REST API framework |
| Uvicorn | 0.24.0 | ASGI server |
| Pydantic | 2.5.0 | Data validation |
| pymongo | 4.6.0 | MongoDB driver |
| python-jose | 3.3.0 | JWT token handling |
| passlib + bcrypt | 1.7.4 / 4.1.1 | Password hashing |
| Groq | 0.10.0 | AI model API client |
| resend | latest | Email OTP delivery |

### Infrastructure
| Service | Purpose |
|---------|---------|
| MongoDB Atlas | Cloud database |
| Groq API | AI inference engine |
| Resend | Transactional email |
| Vercel | Frontend hosting |
| Render | Backend hosting |
| cron-job.org | Keep-alive pinging |

---

## 📁 Project Structure

```
CodeHax/                          # Root repository
│
├── 📂 code_hax/                  # Flutter Frontend
│   ├── 📂 assets/
│   │   └── logo.png              # App logo
│   ├── 📂 lib/
│   │   ├── 📂 constants/
│   │   │   └── app_constants.dart      # Colors, URLs, constants
│   │   ├── 📂 models/
│   │   │   └── api_response.dart       # API response models
│   │   ├── 📂 screens/
│   │   │   ├── login_page.dart         # Login screen
│   │   │   ├── signup_page.dart        # Sign up screen
│   │   │   ├── otp_page.dart           # Email OTP verification
│   │   │   ├── chat_with_sidebar.dart  # Main chat interface
│   │   │   ├── debugger_page.dart      # Code debugger tab
│   │   │   └── chat_history_page.dart  # Chat history viewer
│   │   ├── 📂 services/
│   │   │   ├── api_service.dart        # Groq API calls
│   │   │   ├── auth_service.dart       # Auth & token management
│   │   │   └── chat_history_service.dart # MongoDB chat history
│   │   └── main.dart                   # App entry point & routing
│   ├── 📂 web/
│   │   ├── index.html
│   │   └── favicon.png
│   └── pubspec.yaml                    # Flutter dependencies
│
├── 📂 CodeHax/                   # Python Backend
│   ├── backend.py                # Main FastAPI application
│   ├── backend_auth.py           # JWT creation & verification
│   ├── backend_database.py       # MongoDB connection & collections
│   ├── backend_models.py         # Pydantic request/response models
│   ├── .env                      # Environment variables (not committed)
│   └── requirements.txt          # Python dependencies
│
├── .python-version               # Python version pin (3.10.11)
└── README.md
```

---

## 📦 Requirements

### System Requirements

| Requirement | Minimum Version |
|------------|----------------|
| Python | 3.10.11 |
| Flutter SDK | 3.0.0 |
| Dart SDK | 3.0.0 |
| Git | 2.x |
| Node.js (for Vercel CLI) | 16+ |

### Accounts Required

| Service | Free Plan | Link |
|---------|-----------|------|
| MongoDB Atlas | ✅ 512MB free | [mongodb.com](https://mongodb.com) |
| Groq API | ✅ Free tier | [console.groq.com](https://console.groq.com) |
| Resend | ✅ 3000 emails/month free | [resend.com](https://resend.com) |
| Vercel | ✅ Free hobby plan | [vercel.com](https://vercel.com) |
| Render | ✅ Free tier | [render.com](https://render.com) |

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Sumitkalamkar/CodeHax.git
cd CodeHax
```

### 2. Backend Setup

```bash
# Navigate to backend
cd CodeHax

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

Create a `.env` file:

```bash
cp .env.example .env   # or create manually
```

Fill in your `.env`:

```env
GROQ_API_KEY=gsk_xxxxxxxxxxxxxxxxxxxx
MONGO_URI=mongodb+srv://user:password@cluster.mongodb.net/codehax
SECRET_KEY=your_super_secret_jwt_key_here
RESEND_API_KEY=re_xxxxxxxxxxxxxxxxxxxx
```

Run the backend:

```bash
python backend.py
```

✅ Backend running at: `http://localhost:8000`  
✅ API docs at: `http://localhost:8000/docs`

---

### 3. Frontend Setup

```bash
# Navigate to Flutter project
cd ../code_hax

# Install Flutter dependencies
flutter pub get
```

Update `lib/constants/app_constants.dart` with your backend URL:

```dart
static const String baseUrl = 'http://localhost:8000'; // local dev
// static const String baseUrl = 'https://codehax-backend.onrender.com'; // production
```

Run the app:

```bash
# Run in Chrome browser
flutter run -d chrome

# Run on connected device
flutter run
```

---

## 🔐 Environment Variables

### Backend `.env`

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `GROQ_API_KEY` | ✅ | Groq AI API key | `gsk_abc123...` |
| `MONGO_URI` | ✅ | MongoDB Atlas connection string | `mongodb+srv://...` |
| `SECRET_KEY` | ✅ | JWT signing secret (32+ chars) | `my_super_secret_key` |
| `RESEND_API_KEY` | ✅ | Resend email API key | `re_abc123...` |

### How to get each key

<details>
<summary>🔑 GROQ_API_KEY</summary>

1. Visit [console.groq.com](https://console.groq.com)
2. Sign up / Login
3. Go to **API Keys** → **Create API Key**
4. Copy and paste into `.env`

</details>

<details>
<summary>🍃 MONGO_URI</summary>

1. Visit [mongodb.com](https://mongodb.com) → Create free account
2. Create a new **Cluster** (free M0 tier)
3. Go to **Database Access** → Add a user with password
4. Go to **Network Access** → Add `0.0.0.0/0` (allow all IPs)
5. Go to **Connect** → **Connect your application**
6. Copy the connection string and replace `<password>`

</details>

<details>
<summary>📧 RESEND_API_KEY</summary>

1. Visit [resend.com](https://resend.com) → Sign up
2. Go to **API Keys** → **Create API Key**
3. Verify your domain at **Domains** → Add your domain
4. Add DNS records to your domain registrar (GoDaddy, Namecheap etc.)
5. Copy the API key into `.env`

</details>

---

## 📡 API Documentation

Full interactive docs: [https://codehax-backend.onrender.com/docs](https://codehax-backend.onrender.com/docs)

### Authentication Endpoints

| Method | Endpoint | Body | Description |
|--------|----------|------|-------------|
| `POST` | `/auth/signup` | `{username, email, password}` | Register new user |
| `POST` | `/auth/login` | `{email, password}` | Login & get JWT token |
| `GET` | `/auth/verify` | Header: `Authorization: Bearer <token>` | Verify token |
| `POST` | `/auth/send-otp` | `{email}` | Send 6-digit OTP |
| `POST` | `/auth/verify-otp` | `{email, otp}` | Verify OTP code |

### Chat Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/debug` | Send code for AI analysis |
| `POST` | `/chat/save` | Save chat message to history |
| `GET` | `/chat/history` | Get all sessions for user |
| `GET` | `/chat/session/{session_id}` | Get all messages in a session |

### Example Request — Debug Code

```bash
curl -X POST https://codehax-backend.onrender.com/debug \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "def add(a, b):\n  return a - b",
    "language": "python",
    "error": "wrong output",
    "session_id": "1234567890"
  }'
```

### Example Response

```json
{
  "solution": "The subtraction operator is used instead of addition",
  "explanation": "Line 2 uses '-' instead of '+' operator...",
  "fixed_code": "def add(a, b):\n  return a + b",
  "tips": [
    "Always test with simple inputs first",
    "Use descriptive function names",
    "Add type hints for clarity"
  ]
}
```

---

## ☁️ Deployment

### Vercel (Frontend)

**Prerequisites:** Node.js installed, Vercel account

```bash
# Install Vercel CLI
npm install -g vercel

# Build Flutter web app
cd code_hax
flutter build web

# Deploy to Vercel
cd build/web
vercel --prod
```

Follow the prompts:
- Select your Vercel account
- Link to existing project or create new
- Set project name (e.g., `codehax`)

✅ Your app will be live at `https://codehax.vercel.app`

To update after code changes:
```bash
flutter build web && cd build/web && vercel --prod
```

---

### Render (Backend)

1. Push your code to GitHub
2. Go to [render.com](https://render.com) → **New Web Service**
3. Connect your GitHub repository
4. Configure:
   - **Runtime:** Python
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `python backend.py`
5. Add all environment variables in the **Environment** tab
6. Add `.python-version` file to repo root:
   ```
   3.10.11
   ```
7. Click **Deploy**

✅ Backend live at `https://your-service.onrender.com`

---

### AWS (Full Stack)

#### Option A: AWS Elastic Beanstalk (Backend)

```bash
# Install AWS CLI & EB CLI
pip install awscli awsebcli

# Configure AWS
aws configure
# Enter: Access Key, Secret Key, Region (e.g. ap-south-1), Output: json

# Initialize Elastic Beanstalk
cd CodeHax
eb init codehax-backend --platform python-3.10 --region ap-south-1

# Create environment
eb create codehax-prod

# Set environment variables
eb setenv GROQ_API_KEY=xxx MONGO_URI=xxx SECRET_KEY=xxx RESEND_API_KEY=xxx

# Deploy
eb deploy
```

#### Option B: AWS EC2 (Manual)

```bash
# 1. Launch EC2 instance (Ubuntu 22.04, t2.micro for free tier)
# 2. SSH into instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# 3. Install dependencies
sudo apt update
sudo apt install python3.10 python3-pip nginx -y

# 4. Clone repo
git clone https://github.com/Sumitkalamkar/CodeHax.git
cd CodeHax/CodeHax

# 5. Install Python packages
pip3 install -r requirements.txt

# 6. Create .env file
nano .env
# Add your environment variables

# 7. Install & configure PM2 to keep app running
sudo npm install -g pm2
pm2 start "python3 backend.py" --name codehax-backend
pm2 save
pm2 startup

# 8. Configure Nginx as reverse proxy
sudo nano /etc/nginx/sites-available/codehax
```

Nginx config:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/codehax /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 9. Add SSL with Certbot
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d your-domain.com
```

#### Option C: AWS S3 + CloudFront (Frontend)

```bash
# Build Flutter web
flutter build web

# Create S3 bucket
aws s3 mb s3://codehax-frontend

# Enable static website hosting
aws s3 website s3://codehax-frontend --index-document index.html --error-document index.html

# Upload build files
aws s3 sync build/web/ s3://codehax-frontend --acl public-read

# Create CloudFront distribution (via AWS Console)
# Origin: your S3 bucket URL
# Enable HTTPS
# Set default root object: index.html
```

---

### Docker

#### Backend Dockerfile

```dockerfile
FROM python:3.10.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["python", "backend.py"]
```

#### docker-compose.yml

```yaml
version: '3.8'

services:
  backend:
    build: ./CodeHax
    ports:
      - "8000:8000"
    environment:
      - GROQ_API_KEY=${GROQ_API_KEY}
      - MONGO_URI=${MONGO_URI}
      - SECRET_KEY=${SECRET_KEY}
      - RESEND_API_KEY=${RESEND_API_KEY}
    restart: always
```

```bash
# Build and run
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

---

## ⏰ Keep Alive

Render's free tier spins down after 15 minutes of inactivity. To prevent this, set up a free cron job:

1. Go to [cron-job.org](https://cron-job.org) → Create account
2. Create new cron job:
   - **URL:** `https://codehax-backend.onrender.com/health`
   - **Schedule:** Custom → `*/14 * * * *` (every 14 minutes)
3. Save

This pings your backend every 14 minutes keeping it always awake. ✅

---

## 🤝 Contributing

Contributions are welcome! Here's how:

1. **Fork** the repository
2. Create a **feature branch**
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. **Commit** your changes
   ```bash
   git commit -m "Add: AmazingFeature description"
   ```
4. **Push** to the branch
   ```bash
   git push origin feature/AmazingFeature
   ```
5. Open a **Pull Request**

### Commit Convention

| Prefix | Usage |
|--------|-------|
| `Add:` | New feature |
| `Fix:` | Bug fix |
| `Update:` | Update existing feature |
| `Remove:` | Remove code/file |
| `Docs:` | Documentation changes |

---

## 🐛 Known Issues

- Render free tier has cold start (~30 sec) on first request after inactivity
- OTP is stored in memory — restarting server clears pending OTPs

---

## 🗺️ Roadmap

- [ ] Custom GPT model trained from scratch
- [ ] VS Code Extension
- [ ] Support for more languages (TypeScript, Swift, Kotlin)
- [ ] Code execution sandbox
- [ ] Team collaboration sessions
- [ ] Mobile app (Android/iOS)

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

<div align="center">

**Sumit Kalamkar**

[![GitHub](https://img.shields.io/badge/GitHub-Sumitkalamkar-181717?style=for-the-badge&logo=github)](https://github.com/Sumitkalamkar)

</div>

---

<div align="center">

**If you found this useful, please ⭐ the repo!**

`// CodeHax — where bugs come to die`

</div>
