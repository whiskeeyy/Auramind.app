# Kỹ Năng Flutter Nâng Cao

Dự án Auramind yêu cầu những kỹ năng xử lý UI và logic đặc thù mang tính "thấu cảm". Tài liệu này liệt kê các kỹ thuật chuyên sâu khi làm việc trên nhánh `mobile/`.

## 1. Glassmorphism UI (Thiết kế Kính Mờ)
Sử dụng `BackdropFilter` thần thánh để tạo chiều sâu trực quan.
- **Lưu ý hiệu suất**: Tránh lạm dụng `BackdropFilter` ở danh sách dài (ListView/Sliver) vì `sigmaX`, `sigmaY` yêu cầu GPU tính toán rất lớn, làm giảm FPS. Chỉ dùng chúng ở Widget tĩnh mang tính hiển thị (Dashboard Card, Dialog).
- **Thủ thuật**: Đóng gói thành `GlassContainer` Widget để tái sử dụng.

## 2. Dynamic Theming theo Mood (Màu sắc theo tâm trạng)
Khi người dùng trượt thanh Mood Slider, toàn bộ background hoặc điểm nhấn chính (Accent Color) phải đổi màu (Color Tweening).
- **Kỹ năng**: Dùng `AnimatedContainer` hoặc `TweenAnimationBuilder` để chuyển đổi mượt mà giữa các mã màu (Đỏ -> Cam -> Xanh Dương -> Xanh Lá).

## 3. Khởi tạo & Đồng Bộ State với AuthWrapper
- **Bài toán**: Rất nhiều người dùng đang log tài khoản, đột ngột mất mạng hoặc JWT token hết hạn.
- **Giải pháp**: Lắng nghe `Supabase.instance.client.auth.onAuthStateChange`. Không cần Provider rườm rà cho phần này, dùng StreamBuilder hoặc StatefulWidget kết hợp Navigator ẩn bên trong rễ (Root) ứng dụng.

## 4. Tương lai gần (Phase 9): Nhận Diện Khuôn Mặt (Face Detection)
Để xử lý *Face-to-Toon*, bạn sẽ cần:
- **`camera` plugin**: Thu luồng video (video stream) thời gian thực từ camera trước.
- **`google_mlkit_face_detection`**: Chạy Offline trên máy.
- **Isolate / Compute**: Đẩy việc lấy tọa độ khuôn mặt (mắt mở/nhắm, miệng hé) sang một thread khác (Isolates) để không làm block UI Thread chính của Flutter. Bạn không thể làm việc nặng này trên Main Thread!
