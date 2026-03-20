# Feature Development Workflow

Quy trình chuẩn để rẽ nhánh, phát triển, và đưa một tính năng mới vào Auramind.

## 1. Tìm Hiểu & Thiết Kế (Planning & Design)
- **Tài liệu tham khảo**: Đọc kỹ `PRD.md` và thẻ task trong `TASKS.md`.
- **Hỏi kỹ trước khi làm**: Nếu yêu cầu tạo màn hình mới, phải hiểu rõ: Dữ liệu này lưu ở đâu? AI có cần can thiệp không? Có cần Migration database không?

## 2. Rẽ Nhánh (Branching)
Tạo nhánh làm việc từ `develop`:
```bash
git checkout develop
git pull origin develop
git checkout -b feature/ten-tinh-nang-moi
```

## 3. Thực Thi (Execution Pipeline)

### Bước 3.1: Database (Supabase) - *Nếu cần*
Mọi thứ bắt đầu từ Data.
- Viết file `migration_00X_ten.sql` trong `database/`.
- Định nghĩa Tables, Columns.
- Viết RLS Policies cho bảng đó (Bắt buộc).
- Chạy thử migration trên local supabase/dev database.

### Bước 3.2: FastAPI Backend - *Nếu có logic server/AI*
- **Models**: Tạo file trong `backend/app/models/` mapping với Table mới.
- **Services**: Viết logic xử lý (ví dụ gọi AI Agents) trong `services/`.
- **Routers**: Tạo Endpoint API (RESTful) trong `routers/`, gọi xuống Services. 
- **Bảo mật**: Thêm dependency `get_current_user` để đảm bảo API bị khóa bởi JWT.
- **Kiểm thử**: Chạy Postman hoặc Swagger UI (`/docs`) để test API.

### Bước 3.3: Flutter Mobile - *Giao diện người dùng*
- **Models**: Tạo class Dart parse JSON từ API trả về (`fromJson`, `toJson`).
- **Services**: Thêm hàm gọi API bằng file `api_service.dart`.
- **UI Widgets**: Xây dựng UI ở thư mục `screens/` và `widgets/` tuân thủ `styling_guidelines.md`.
- **State**: Bắn State Call vào UI để thay đổi màn hình (Loading State, Error State, Success State).

## 4. Tích Hợp & Kiểm Thử (Integration & Verify)
- Chạy App gọi thẳng xuống API Backend đang run local. 
- Chơi thử toàn bộ flow (Ví dụ: Từ form nhập -> Gửi API -> AI Chat -> UI đổi màu).
- Sửa lỗi (nếu có).

## 5. Commit & Push
- Gom các thay đổi thành các Commit nhỏ (Atomic Commits, ENG).
- Cập nhật `TASKS.md` đánh dấu `[x]` vào các đầu mục nhỏ đã xong.
- Đẩy nhánh lên Git và tạo Pull Request.
