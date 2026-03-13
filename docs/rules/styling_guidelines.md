# Styling Guidelines (Digital Soul Mirror)

🌌 **1. Ngôn ngữ thiết kế: Digital Soul Mirror**
Ngôn ngữ này tập trung vào việc tạo ra một môi trường chữa lành, nhẹ nhàng và phản chiếu trạng thái nội tâm của người dùng thông qua các yếu tố thị giác chuyển động và mềm mại.

### Trụ cột thiết kế (Design Pillars)
- **Empathy-first (Thấu cảm là trên hết)**: Mọi yếu tố đồ họa phải mang lại cảm giác an toàn, không phán xét.
- **Visual Reflection (Phản chiếu thị giác)**: Màu sắc và trạng thái của ứng dụng thay đổi theo dữ liệu `mood_score` và `avatar_state` của người dùng.
- **Organic Movement (Chuyển động hữu cơ)**: Sử dụng các hiệu ứng chuyển động chậm, mượt mà như nhịp thở.

🎨 **2. Thành phần Styling (Styling Elements)**

### 🌊 Aurora UI (Dynamic Gradients)
Đây là thành phần chủ đạo của phông nền ứng dụng.
- **Kỹ thuật**: Sử dụng các lớp Container với `BoxDecoration` và `LinearGradient` lồng nhau, kết hợp với hiệu ứng làm mờ (Blur) mạnh.
- **Logic màu sắc**:
    - **Tích cực (8-10)**: Gradient vàng nắng, xanh lá nhạt và hồng san hô.
    - **Bình yên (5-7)**: Gradient xanh dương teal, trắng ngọc trai và tím lavender.
    - **Cần xoa dịu (1-4)**: Gradient xám xanh sâu thẳm hoặc xanh than trầm ấm.

### ☁️ Claymorphism (Soft 3D Components)
Được áp dụng cho các thành phần nổi như Avatar, Badges và các nút bấm chính (Primary Action Buttons).
- **Thông số kỹ thuật**:
    - `Border Radius`: 24.0 - 32.0 (tạo sự bo tròn lớn, mềm mại).
    - `Inner Shadow`: Sử dụng hiệu ứng bóng đổ bên trong màu trắng để tạo độ phồng.
    - `Outer Shadow`: Bóng đổ ngoài mờ rộng với độ đậm đặc thấp (10-15% opacity).

### ❄️ Glassmorphism (Functional Overlays)
Chỉ sử dụng cho các bảng thông tin, Bottom Sheet và Modal để duy trì độ trong suốt và chiều sâu.
- `Backdrop Filter`: Blur từ 15.0 đến 25.0.
- `Border`: Màu trắng mờ (opacity 20%) với độ dày 1.0 để định hình khung hình.

🔘 **3. Hệ thống tương tác (Interaction)**
- **Avatar State Mapping**: Mỗi `avatar_state` được gán cho một bộ biểu cảm 3D (dạng đất sét) tương ứng.
- **Loading States**: Sử dụng các vòng tròn Aura xoay nhẹ thay vì thanh tải tiến trình (Progress Bar) truyền thống.
- **Micro-interactions**: Khi người dùng nhấn vào thẻ tâm trạng, các khối Claymorphic sẽ có hiệu ứng "lún" xuống nhẹ như chạm vào vật liệu mềm.

🛠️ **4. Nguyên tắc áp dụng (Implementation Rules)**
- **Không dùng màu đen thuần túy**: Sử dụng các biến thể của xanh than hoặc tím đậm để tạo chiều sâu mà không gây cảm giác nặng nề.
- **Khoảng trắng (White-space)**: Tăng diện tích khoảng trắng để tạo cảm giác "thở" cho giao diện.
- **Typography**: Ưu tiên các font chữ không chân (Sans-serif) có độ bo tròn cao, dễ đọc.

