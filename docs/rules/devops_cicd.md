# DevOps & CI/CD Guidelines

Tài liệu này hướng dẫn cách cấu hình, kiểm thử và tự động hóa quy trình triển khai cho Auramind.

## 1. Môi trường (Environments)
- **Local**: Môi trường phát triển trên máy lập trình viên. Database sử dụng Supabase Local hoặc kết nối thẳng lên Supabase Project (Dev).
- **Production**: Môi trường thực tế phục vụ người dùng, kết nối với Supabase Production và Gemini API thực.

## 2. Database Migrations (Supabase)
Mọi thay đổi liên quan đến cấu trúc dữ liệu, Row Level Security (RLS) bắt buộc phải tạo file migration trong thư mục `database/`.
- Không bao giờ thay đổi trực tiếp trên UI Supabase Dashboard cho Production.
- Tên file dạng: `migration_00X_mo_ta_ngan.sql`.

## 3. CI/CD Pipeline (Sử dụng GitHub Actions)
Thư mục `.github/workflows/` lưu trữ các kịch bản chạy tự động.

### 3.1. Backend (FastAPI) Validation
Khi có Pull Request (PR) merge vào `main` hoặc push commit mới:
1. **Linter**: Chạy `flake8` hoặc `pylint` để kiểm tra chuẩn code (PEP-8).
2. **Tests**: Tự động chạy bộ test `pytest`. Nếu bất kỳ test nào thất bại (FAIL), PR sẽ bị chặn (block merge).

### 3.2. Mobile (Flutter) Validation
1. **Linter**: Chạy `flutter analyze`.
2. **Format**: Chạy `dart format --set-exit-if-changed .` để đảm bảo code sạch.
3. **Tests**: Chạy `flutter test`.

## 4. Bảo mật (Security & API Keys)
- Tuyệt đối không hardcode API Keys, Supabase URL cục bộ vào source code.
- Môi trường Local: Lưu vào `.env`.
- Môi trường CI/CD: Lưu vào **GitHub Secrets**.
- Môi trường Production Hosting: Thiết lập Environment Variables trong trang quản trị Server (Railway, Render, AWS, v.v.).

## 5. Review Quy trình
Một tính năng chỉ được xem là hoàn tất (Definition of Done) khi:
1. Code tuân thủ chuẩn `coding_standards.md`.
2. Đi qua CI pipeline không lỗi.
3. Đã viết/chỉnh sửa Migration (nếu có).
4. Tính năng hoạt động mượt mà không làm sập (crash) hệ thống hiện hành.
