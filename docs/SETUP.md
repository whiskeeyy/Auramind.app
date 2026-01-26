# Auramind Setup Guide

## Prerequisites

### Required Software
- **Python 3.10+**: [Download](https://www.python.org/downloads/)
- **Flutter 3.0+**: [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Git**: [Download](https://git-scm.com/downloads)
- **Supabase Account**: [Sign up](https://supabase.com/)

### Recommended Tools
- **VS Code** with Flutter and Python extensions
- **Postman** or **Thunder Client** for API testing
- **Android Studio** or **Xcode** for mobile development

---

## 🗄️ Database Setup

### 1. Create Supabase Project
1. Go to [supabase.com](https://supabase.com/) and create a new project
2. Wait for the project to initialize (~2 minutes)
3. Note your project URL and anon key

### 2. Run Database Schema
1. Navigate to SQL Editor in Supabase dashboard
2. Copy contents from `database/schema.sql`
3. Execute the SQL script
4. Verify tables are created in Table Editor

---

## 🔧 Backend Setup

### 1. Install Dependencies
```bash
cd backend
python -m venv venv

# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate

pip install -r requirements.txt
```

### 2. Configure Environment
Create `.env` file in `backend/` directory:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
```

### 3. Run Backend
```bash
uvicorn app.main:app --reload
```

Backend will be available at `http://localhost:8000`

### 4. Test API
```bash
# Health check
curl http://localhost:8000/health

# Or run tests
python -m pytest
```

---

## 📱 Mobile Setup

### 1. Install Flutter
Follow the official guide for your OS:
- [Windows](https://docs.flutter.dev/get-started/install/windows)
- [macOS](https://docs.flutter.dev/get-started/install/macos)
- [Linux](https://docs.flutter.dev/get-started/install/linux)

Verify installation:
```bash
flutter doctor
```

### 2. Install Dependencies
```bash
cd mobile/auramind_app
flutter pub get
```

### 3. Configure API Endpoint
Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:8000';
```

> **Note**: Use your computer's IP address (not localhost) when testing on physical devices.

### 4. Run App
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Or just run (will prompt for device)
flutter run
```

---

## 🧪 Testing

### Backend Tests
```bash
cd backend
python -m pytest -v
```

### Mobile Tests
```bash
cd mobile/auramind_app
flutter test
```

---

## 🔐 Security Notes

### Environment Variables
Never commit `.env` files! They are already in `.gitignore`.

### API Keys
- Use Supabase **anon key** for client-side (mobile)
- Use **service role key** only in backend (never expose to client)

### CORS
Current CORS settings allow all origins for development. Update in production:
```python
# app/main.py
allow_origins=["https://your-production-domain.com"]
```

---

## 🐛 Troubleshooting

### Backend Issues

**Import errors**
```bash
# Make sure venv is activated
pip install -r requirements.txt
```

**Port already in use**
```bash
# Use different port
uvicorn app.main:app --reload --port 8001
```

### Flutter Issues

**Flutter not found**
- Add Flutter to PATH
- Restart terminal

**Dependencies error**
```bash
flutter clean
flutter pub get
```

**Build errors**
```bash
# iOS
cd ios && pod install && cd ..

# Android
flutter clean
```

---

## 📚 Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Material 3 Design](https://m3.material.io/)
