# Coding Standards

## 1. Môi trường Frontend (Flutter/Dart)
Dự án sử dụng Flutter làm ngôn ngữ xây dựng UI/UX cho ứng dụng mobile.

### Conventions
- Tuân thủ chặt chẽ **Effective Dart**.
- Sử dụng `camelCase` cho biến, hàm (`moodScore`, `fetchData()`).
- Sử dụng `PascalCase` cho tên Class, Enum (`MoodCheckinScreen`, `AvatarState`).
- Sử dụng `snake_case` cho tên file thư mục (`home_screen.dart`, `api_service.dart`).

### Linter & Formatting
- Code Flutter luôn phải format bởi `dart format` trước khi commit.
- Chạy `flutter analyze` để đảm bảo code không có warning hay lỗi nào.
- Nên ưu tiên các modifier `const` ở những widget hoặc resource không thay đổi trạng thái (Stateless) để tối ưu hoá hiệu suất.

### State Management
- Hiện tại sử dụng kết hợp `StatefulWidget` (cho Local State) và `Provider` (Global State nếu mở rộng).

## 2. Môi trường Backend (FastAPI/Python)
Dự án sử dụng Python for AI Processing.

### Conventions
- Tuân thủ **PEP-8**.
- Sử dụng `snake_case` cho tên hàm, biến và tên file (`analyze_mood()`, `rate_limiter.py`).
- Sử dụng `PascalCase` cho Classes (`AIAgentManager`, `AnalyzerAgent`).
- Tuân thủ Type Hinting nghiêm ngặt ở mọi hàm (e.g., `def chat(message: str) -> dict:`).

### Error Handling
- Hỗ trợ các lớp fallback (Ví dụ: Emulator Agent gọi bị lỗi -> có layer fallback Default Message).
- Ưu tiên Raise `HTTPException` từ FastAPI với thông báo lỗi cụ thể để Client (Flutter) có thể bắt và thông báo cho User.

---

*Lưu ý: Mọi đóng góp (Pull Request) cần tuân thủ hướng dẫn trên để dự án luôn thống nhất và rõ ràng.*
