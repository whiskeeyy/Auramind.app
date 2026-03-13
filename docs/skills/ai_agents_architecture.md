# Kiến trúc AI Agents (Antigravity Pipeline)

Dự án Auramind sử dụng sức mạnh của **Gemini 1.5 Flash** để điều phối (orchestrate) các agents. Mọi tương tác AI đều nằm gọn trong thư mục `backend/app/services/ai_manager.py`.

## 1. Thành phần Cốt lõi (The Agents)

Hệ thống hoạt động như một chuỗi dây chuyền (pipeline) hoặc song song (song trùng), bao gồm 3 Agent chủ lực:

### 1.1. Analyzer Agent (Nhà Phân Tích)
- **Nhiệm vụ**: Đọc nhật ký thô (hoặc transcript giọng nói) và trích xuất ra các định lượng toán học.
- **Output (JSON)**: `mood_score` (1-10), `stress_level` (1-10), `energy_level` (1-10), `primary_emotion` (Chuỗi chữ), và một mảng `activities`.
- **Kỹ năng (Skill)**: Phân tích khách quan, không đưa cảm xúc vào kết quả trả về. Nếu người dùng nhập linh tinh, biết cách trả về giá trị mặc định (Fallback = "neutral", score = 5).

### 1.2. Empathy Agent (Người Bạn Đồng Cảm)
- **Nhiệm vụ**: Phản hồi giọng văn thật "con người" (Human-like) dựa trên phân tích từ Analyzer.
- **Kỹ năng (Skill)**: 
  - Giao tiếp xưng "mình", gọi "bạn".
  - Áp dụng kỹ thuật **Reflective Listening** (Nghe Phản Chiếu): Lặp lại cảm xúc người dùng để họ thấy mình được lắng nghe.
  - Sử dụng Context Awareness. Lấy lịch sử log 7 ngày gần nhất để biết người dùng đang có **Streak** hay không (để khen ngợi) hoặc biết họ đang buồn dài hạn (để an ủi).
- **Nguyên tắc an toàn**: Không bao giờ đưa ra chẩn đoán y tế.

### 1.3. Insight Agent (Chuyên Gia Phân Tích Thông Số - Data Psychologist)
- **Nhiệm vụ**: Xử lý dữ liệu tổng hợp (Aggregated Data) thay vì từng log đơn lẻ.
- **Kỹ năng (Skill)**:
  - Phân tích dữ liệu theo Tháng (Monthly Insight).
  - Phân tích tương quan Nhân - Quả (Holistic Insight): Tìm ra mối liên hệ giữa Hoạt động (Ví dụ: Chạy bộ) sức khỏe (Ví dụ: Giờ ngủ) và Cảm xúc (Mood Score).
- **Prompt Philosophy**: "Sức khỏe và Tâm trạng là Nhân - Quả của nhau". Trả về đúng 1 câu duy nhất cho người dùng dễ đọc.

## 2. Avatar Orchestrator (Người Điều Phối)
Không phải LLM Agent, nó là một Logic Rule Engine thuần túy:
- Quét qua `mood_score` và `stress_level` do Analyzer nhả ra.
- Trả về Enum Avatar State: `STATE_JOYFUL`, `STATE_NEUTRAL`, `STATE_SAD`, `STATE_ANXIOUS`, `STATE_OVERWHELMED`.
- State này sau đó được đẩy xuống Mobile App để vẽ UI nhân vật.

## 3. Quản lý Lỗi (Error Handling & Fallback)
Khi gọi LLM có thể xảy ra độ trễ, lỗi mạng hoặc lỗi API Key. Luôn luôn phải:
- Bọc trong `try-except`.
- Thiết lập response mặc định (VD: `"Mình đang gặp chút sự cố mạng. Hãy thử lại chút nữa nhé!"`).
- Bắt buộc xử lý JSON Parsing (nếu model nhả ra text chứa JSON không hợp lệ, phải gọt rũa nó hoặc catch exception).
