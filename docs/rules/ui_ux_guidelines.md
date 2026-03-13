# UI/UX & Empathy Guidelines

Mục tiêu lớn nhất của Auramind là mang lại cảm giác an toàn, thấu hiểu, và không phán xét. UX của ứng dụng phải phản ánh điều này trong mọi tương tác.

## 1. Cốt lõi của Empathy UX
- **Tone & Voice (Giọng văn)**: Luôn xưng "mình" và gọi "bạn". Không bao giờ sử dụng giọng điệu ra lệnh, chỉ trích hay quá tiêu cực. Dùng những câu chữ nhẹ nhàng.
  - TỐT: "Có vẻ hôm nay bạn hơi mệt mỏi. Hãy nghỉ ngơi một chút nhé."
  - SAI: "Bạn bị stress vì làm việc quá sức. Dừng ngay lại!"
- **Tốc độ phản hồi (Pacing)**: 
  - Đôi khi việc phản hồi quá nhanh (như máy móc) sẽ làm mất đi cảm giác con người. Khi AI Agent đang "suy nghĩ" (loading), nên sử dụng animation nhẹ nhàng (ví dụ: Logo Auramind phát sáng mờ ảo) thay vì vòng quay loading cứng nhắc.
  
## 2. Micro-Interactions (Tương tác siêu nhỏ)
- **Haptic Feedback**: Sử dụng rung nhẹ (Haptic) khi người dùng thao tác ở những điểm chạm cảm xúc quan trọng:
  - Khi vuốt Slider chọn mức Mood.
  - Khi mở khóa một Badge mới (Success Dialog).
- **Smooth Transitions**: Các màn hình không bao giờ "giật cục" mở ra. Hãy dùng hiệu ứng Fade (mờ dần) hoặc Slide (trượt nhẹ) trang nhã.

## 3. Error Handling - Lỗi cũng phải tinh tế
Khi có sự cố (mất mạng, lỗi API), đừng hiển thị bảng thông báo lỗi màu đỏ đáng sợ.
- **Cách tiếp cận**: Dùng illustration (hình minh họa) nhẹ nhàng (ví dụ: một chú robot đang ngủ gật).
- **Thông báo**: "Mạng đang chập chờn một chút, nhưng không sao, bạn cứ nghỉ ngơi, chốc nữa hệ thống sẽ thử lại nhé!" thay vì `Error 500: Internal Server Error`.

## 4. Nhận thức sức khỏe tâm thần (Mental Health Awareness)
- **Không chẩn đoán**: Auramind KHÔNG phải là bác sĩ. Không bao giờ đưa ra chẩn đoán bệnh lý (như "Bạn bị trầm cảm").
- **Safety Net**: Nếu phát hiện người dùng liên tục có Mood Score rất thấp (<=3) kéo dài, UI tự động (một cách tinh tế) gợi ý đường dây nóng: **1900555618**.
