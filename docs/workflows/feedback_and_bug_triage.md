# Feedback & Bug Triage Workflow

Trong giai đoạn MVP và Growth, ứng dụng sẽ có nhiều lỗi (Bugs) và đóng góp từ người dùng (Feedback). Đây là quy trình xử lý chúng để đảm bảo dự án luôn ổn định và chiều lòng người dùng.

## 1. Phân Loại Nguồn Lỗi (Triage)
Khi nhận được báo cáo lỗi, cần xác định ngay nó thuộc lớp (layer) nào:
- **UI/UX Bug (Flutter)**: Ví dụ nút bấm bị lệch, màn hình giật lag khi tải biểu đồ.
- **Logic Bug (Backend)**: Tính sai Streak, API trả về 500 ném exception.
- **AI/Prompt Bug (Antigravity)**: Agent AI trả lời sai ngữ cảnh, trả về JSON rỗng làm sập parser.
- **Data Bug (Supabase)**: Lỗi phân quyền RLS làm người dùng không thấy nhật ký của mình.

## 2. Vòng Lặp Sửa Lỗi (Bugfix Loop)

### Bước 1: Tái hiện (Reproduce)
Tuyệt đối không bắt tay vào sửa mã khi chưa hiểu lỗi.
- Yêu cầu môi trường xảy ra lỗi (Android hay iOS? Mấy giờ? Logs như thế nào?)
- Tự mình tái hiện lại lỗi đó trên máy Local.

### Bước 2: Tạo Nhánh (Branching)
```bash
git checkout develop
git checkout -b bugfix/ten-loi
```

### Bước 3: Sửa & Kiểm Chứng (Fix & Validate)
- Fix lỗi trong phạm vi hẹp nhất có thể (chỉ sửa file liên quan, không refactor rườm rà).
- Nếu là Lỗi Backend, viết thêm 1 Unit Test cho trường hợp đó để đảm bảo lần sau không bị lại.

### Bước 4: Thêm Feedback Tích Cực (User Care)
Nếu lỗi làm sập toàn bộ app của một số người dùng, hãy xem xét gửi một thông báo (Notification) xin lỗi nhẹ nhàng hoặc tặng họ một Badge "Thợ săn lỗi" (Gamification).

## 3. Xử Lý Giới Hạn Quota (AI API Limit)
Lỗi thường gặp nhất trong dự án AI là hết Quota Gemini.
- **Quy trình ngay lúc đó**: Ứng dụng phải tự động fallback sang "Chế độ offline/Local" - tức là lưu Mood cục bộ không cần AI trả lời thấu cảm, hẹn trả lời sau khi hệ thống hoạt động lại. Đây là quy tắc bất di bất dịch của một ứng dụng chăm sóc sức khỏe tâm thần.
