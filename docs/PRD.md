# PRODUCT REQUIREMENT DOCUMENT (PRD): AURAMIND

**Version**: 1.0 (2026 Edition)  
**Status**: MVP Development Phase  
**Last Updated**: 2026-01-26

---

## 1. Overview (Tổng quan)

### Mục tiêu
Xây dựng một "Digital Companion" giúp người dùng chuyển hóa những cảm xúc vô hình thành dữ liệu hữu hình, từ đó cải thiện sức khỏe tinh thần.

### Giá trị cốt lõi
- **Empathy-first**: AI không chỉ trả lời, AI thấu cảm.
- **Visual Identity**: Avatar cá nhân hóa phản chiếu tâm hồn.

### MVP Scope
Tập trung vào vòng lặp: Check-in → Phân tích (AI) → Phản hồi (Avatar) → Trực quan hóa.

---

## 2. User Stories (Câu chuyện người dùng)

| Vai trò | Mong muốn | Lý do |
|---------|-----------|-------|
| Người mới | Tạo Avatar nhanh từ khuôn mặt thật | Để cảm thấy sự kết nối cá nhân ngay lập tức. |
| Người bận rộn | Log mood trong < 10 giây | Để duy trì thói quen ghi nhật ký hàng ngày. |
| Người stress | Trò chuyện với AI không phán xét | Để giải tỏa căng thẳng và tìm giải pháp tự chăm sóc. |
| Người lý trí | Xem biểu đồ xu hướng hàng tuần | Để tìm ra quy luật và tác nhân gây stress (Pattern recognition). |

---

## 3. Features Roadmap (Lộ trình tính năng)

### P1: MVP (Phải có để Launch) ✅

#### Quick Mood Log
- Slider 1-10 + Emoji thông minh + Tag hoạt động
- **Status**: ✅ Implemented

#### AI Companion (Antigravity)
- **Analyzer Agent**: Phân tích sentiment và trích xuất chỉ số stress
- **Empathy Agent**: Phản hồi theo phương pháp "Reflective Listening"
- **Status**: ⚠️ Stub ready, needs Gemini integration

#### Visual Dashboard
- Biểu đồ xu hướng (Line)
- Phân bổ cảm xúc (Pie)
- Mức năng lượng
- **Status**: ✅ Implemented

#### Basic Mood Avatar
- Nhân vật 2D thay đổi biểu cảm (vui, buồn, mệt mỏi) theo mood score
- **Status**: 🔜 Planned

### P2: Post-MVP (Nâng cao)

#### Face-to-Toon
- Sử dụng MediaPipe để map 478 điểm trên mặt thật vào Avatar 3D
- **Status**: 🔜 Planned

#### Habit Integration
- Đối chiếu Mood với dữ liệu giấc ngủ, bước chân từ Google Fit/Apple Health
- **Status**: 🔜 Planned

#### Voice Chat
- Giao tiếp bằng giọng nói thời gian thực (Whisper + TTS)
- **Status**: 🔜 Planned

---

## 4. Tech Stack (2026 Edition)

| Thành phần | Công nghệ | Lý do chọn |
|------------|-----------|------------|
| Mobile App | Flutter | Hiệu năng cao, xử lý Camera/MediaPipe mượt mà trên cả iOS/Android. |
| AI Orchestration | Antigravity Manager | Quản lý đa Agent (Gemini-powered) một cách hệ thống và bảo mật. |
| Backend | FastAPI | Tối ưu cho các Python-based AI services và tốc độ phản hồi cực nhanh. |
| Data & Auth | Supabase | Thay thế Firebase với PostgreSQL mạnh mẽ, hỗ trợ Realtime để cập nhật Chart. |
| Face Tracking | MediaPipe | Thư viện mã nguồn mở tốt nhất để detect landmarks và tạo Avatar. |

---

## 5. Database Schema (Supabase/PostgreSQL)

### Users Table
```sql
CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  display_name text,
  avatar_config jsonb,
  daily_reminder time,
  created_at timestamptz DEFAULT now()
);
```

### Mood Logs Table
```sql
CREATE TABLE mood_logs (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES users(id),
  mood_score int2,
  stress_level int2,
  energy_level int2,
  note text,
  activities text[],
  ai_feedback text,
  voice_transcript text,
  created_at timestamptz DEFAULT now()
);
```

---

## 6. Deployment Plan (Kế hoạch 7 tuần)

| Tuần | Nhiệm vụ | Status |
|------|----------|--------|
| 0 | Setup hạ tầng (Supabase + Antigravity Agents setup) | ✅ |
| 1 | Xây dựng luồng Check-in và giao diện Flutter cơ bản | ✅ |
| 2-3 | Tích hợp AI Agent phân tích và phản hồi text | 🔄 |
| 4 | Phát triển hệ thống Avatar (Basic và Mood-based) | 🔜 |
| 5 | Hoàn thiện Dashboard trực quan hóa dữ liệu | ✅ |
| 6 | Testing, tinh chỉnh Prompt an toàn | 🔜 |
| 7 | Submit Store | 🔜 |

---

## 7. Lưu ý đặc biệt (Safety & Privacy)

### AI Safety
Hệ thống Agent phải được cấu hình để từ chối đưa ra lời khuyên y khoa chuyên sâu.

**Emergency Protocol**: Nếu `mood_score < 3` trong 3 ngày liên tiếp, app tự động hiển thị hotline hỗ trợ tâm lý: **1900555618**

### Data Encryption
Toàn bộ nội dung nhật ký được mã hóa để đảm bảo quyền riêng tư tuyệt đối.

### GDPR Compliance
- User có quyền xóa toàn bộ dữ liệu
- Export dữ liệu theo yêu cầu
- Transparent về việc sử dụng AI

---

## 8. Success Metrics

### MVP Launch Criteria
- [ ] 100% core features working
- [ ] < 2s average response time
- [ ] 95%+ test coverage
- [ ] Zero critical security issues

### Post-Launch KPIs
- Daily Active Users (DAU)
- Average session duration
- Mood log completion rate
- User retention (D7, D30)
- NPS Score

---

**Document Owner**: Auramind Team  
**Next Review**: End of Week 2
