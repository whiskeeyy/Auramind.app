---
description: Deploy backend
---
# Deploy Backend Workflow

Quy trình tự động hóa cho AI Agent triển khai Backend FastAPI. Mọi lệnh chạy gốc từ thư mục `backend/` hoặc thư mục gốc dự án.

## 1. Kiểm tra Linter & Formatter
Chạy kiểm tra code Python bằng `flake8` hoặc `black`.
```bash
# Di chuyển vào backend
cd backend
# Kích hoạt môi trường (giả định)
# source venv/bin/activate
# Chạy Linter
flake8 app/
```

## 2. Validation & Testing
Chạy toàn bộ Unit Tests bằng `pytest`.
```bash
pytest app/tests/
```

## 3. Quản lý Dependencies
Trích xuất requirements.txt mới nhất.
```bash
pip freeze > requirements.txt
```

## 4. Xây dựng & Khởi động Docker (Tùy chọn)
Nếu triển khai bằng Docker.
```bash
docker build -t auramind-backend .
docker run -d -p 8000:8000 --env-file .env auramind-backend
```

## 5. Xác minh (Health Check)
```bash
curl http://localhost:8000/docs
```
