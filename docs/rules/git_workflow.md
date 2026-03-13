# Git & GitHub Workflow

Để duy trì một lịch sử commit sạch sẽ và dễ dàng rollback/review, Auramind áp dụng quy tắc **Atomic Commits** và quy trình rẽ nhánh chuẩn.

## 1. Branching Strategy
- `main`: Nhánh sản phẩm (Production-ready). Không bao giờ commit trực tiếp lên đây.
- `develop`: Nhánh tích hợp (Integration). Mọi tính năng mới đều merge về đây trước tiên.
- `feature/<tên-tính-năng>`: Nhánh tạo ra từ `develop` để làm một tính năng cụ thể.
  - Ví dụ: `feature/face-to-toon`, `feature/streak-system`.
- `bugfix/<tên-lỗi>`: Sửa lỗi không nghiêm trọng.
- `hotfix/<tên-lỗi-nghiêm-trọng>`: Tách từ `main` để sửa lỗi khẩn cấp, merge ngược về cả `main` và `develop`.

## 2. Commit Convention (Conventional Commits)
Mỗi commit message phải rõ ràng, giải thích được TẠI SAO (Why) và CÁI GÌ (What).

### Format
`<type>(<scope>): <subject>`

### Types
- `feat`: Tính năng mới (Ví dụ: Thêm Heatmap).
- `fix`: Sửa lỗi (Ví dụ: Fix lỗi JWT token expired).
- `docs`: Thêm/sửa tài liệu.
- `style`: Format code, không ảnh hưởng logic (Ví dụ: Xóa khoảng trắng, thêm dấu phẩy).
- `refactor`: Viết lại code nhưng không thêm tính năng hay sửa lỗi.
- `perf`: Tối ưu hiệu năng.
- `test`: Thêm/sửa unit tests.
- `chore`: Cập nhật build tasks, package manager (Ví dụ: pub get, đổi dependency).

### Ví dụ
- `feat(auth): Thêm chức năng đăng nhập bằng Google`
- `fix(ai_agent): Bổ sung fallback khi API Gemini quá tải`
- `docs(readme): Cập nhật PRD v1.1`

## 3. Atomic Commits
- Hãy chia nhỏ commit nhất có thể.
- Một commit chỉ nên giải quyết một vấn đề duy nhất. 
- Không commit gộp tính năng (Ví dụ: `feat: Thêm Chat Screen VÀ sửa lỗi Calendar` -> SAI. Hãy tách làm 2 commits).

## 4. Pull Request (PR)
- Mọi PR từ `feature` vào `develop` cần có:
  1. Mô tả ngắn gọn tính năng (What).
  2. Ảnh chụp màn hình hoặc Video (nếu có UI update).
  3. Ít nhất 1 người review (Chấp nhận self-review trong giai đoạn MVP).
