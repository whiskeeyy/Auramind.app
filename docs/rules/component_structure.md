# Component Structure

Cấu trúc dự án Auramind được chia thành hai mảng rõ ràng:

## 1. Flutter Mobile (thư mục `mobile/auramind_app/lib/`)
Sử dụng kiến trúc phân tách ranh giới rõ ràng dựa trên (Feature-Based & Layer-Based):

- `screens/`: Các màn hình đại diện cho một trang cụ thể (Page). Ví dụ: `home_screen.dart`, `dashboard_screen.dart`.
- `widgets/`: Các UI Component nhỏ, có thể tái sử dụng (Reusable Component). Ví dụ: `streak_widget.dart` (Atomic Design).
- `services/`: Lớp logic xử lý việc gọi API, tương tác với Supabase Auth, hoặc logic nghiệp vụ không gắn liền với UI (Ví dụ: `api_service.dart`, `auth_service.dart`).
- `models/`: Chứa các Object Model ánh xạ với dữ liệu Database để dễ quản lý.
- `utils/`: Constants, Helpers chung cho toàn app như ThemeColors, TextStyles.

## 2. FastAPI Backend (thư mục `backend/app/`)
Cấu trúc module hóa cao độ:

- `main.py`: Điểm entry của ứng dụng FastAPI. Setup CORS, Exception handlers.
- `routers/`: Controller APIs, map HTTP Endpoint với các Service layer (Ví dụ: `routers/mood.py`, `routers/auth.py`).
- `services/`: Core logic - Chứa business logic, pipeline xử lý AI (Ví dụ: `services/ai_manager.py`). Đây là nơi Antigravity Agents hoạt động.
- `models/`: SQLAlchemy hoặc Pydantic Schemas giúp validate dữ liệu vào/ra.
- `core.py` (hoặc `config/`): Các cấu hình chung, Security, Rate Limiting, JWT management.

### Quy tắc bất biến
- **Không nhúng Business Logic vào Controller/Router**: Routers chỉ làm nhiệm vụ nhận Request, validate request, pass xuống cho Layer Service xử lý và trả lại Response.
- **Tái sử dụng Component UI**: Bất kì khối UI nào lặp lại từ 2 nơi trở lên cần được chuyển thành một file trong folder `widgets/`.
