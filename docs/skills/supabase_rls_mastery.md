# Supabase RLS (Row Level Security) Mastery

Do bản chất của Auramind là nhật ký tâm lý học, tính riêng tư là TỐI THƯỢNG. RLS trong Supabase là "bức tường lửa" cuối cùng bảo vệ dữ liệu, kể cả khi Backend API bị lộ.

## 1. Quy tắc Vàng
- **MỌI** bảng chứa dữ liệu nhạy cảm (như `mood_logs`, `chat_messages`) BẮT BUỘC phải bật RLS.
  ```sql
  ALTER TABLE mood_logs ENABLE ROW LEVEL SECURITY;
  ```

## 2. Viết Policy Chuẩn
Dữ liệu của ai, người đó đọc. Người dùng chỉ thao tác khi và chỉ khi `auth.uid()` khớp với cột `user_id`.

### Policy CREATE (Thêm mới)
```sql
CREATE POLICY "Users can create their own logs"
ON mood_logs FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);
```

### Policy SELECT (Đọc dữ liệu)
```sql
CREATE POLICY "Users can view their own logs"
ON mood_logs FOR SELECT TO authenticated
USING (auth.uid() = user_id);
```

*(Tương tự cho UPDATE và DELETE).*

## 3. Bypass RLS (Với tư cách là Backend Admin)
FastAPI Backend đôi khi cần quét toàn bộ bảng (ví dụ: Chạy Job tính Streak mỗi ngày cho hàng ngàn Users).
- **Tuyệt đối không** dùng JWT token của User để làm việc này.
- **Cách làm**: Dùng `SUPABASE_SERVICE_ROLE_KEY`. Chỉ Backend mới giữ khóa này. Khóa này có sức mạnh bỏ qua (Bypass) toàn bộ RLS Policies. 
- **Cảnh báo**: NEVER expose `service_role_key` cho Flutter Client! Client chỉ được dùng `anon_key` (Anonymous Key).
