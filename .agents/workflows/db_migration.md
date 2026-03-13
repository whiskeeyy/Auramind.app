---
description: Database Migration Pattern
---
# Database Migration Pattern

Quy trình chuẩn cho Agent (Antigravity) khi cần thay đổi Database Schema trên Supabase.

## 1. Cấu trúc File Migration
Mọi file migration phải nằm trong thư mục `database/` và đánh số thứ tự tăng dần.
Ví dụ: `database/migration_007_new_feature.sql`

## 2. Thành phần bắt buộc của một file Migration
1. **Mô tả (Comment)**: Ghi chú rõ mục đích.
2. **Schema Definition**: Câu lệnh `CREATE TABLE`, `ALTER TABLE`.
3. **Constraints**: Bao gồm Primary Key, Foreign Key.
4. **Triggers (Nếu có)**.
5. **CRITICAL: Row Level Security (RLS)**: Mọi bảng chứa dữ liệu user bắt buộc phải có RLS.

## 3. Mẫu (Template)

```sql
-- Migration 00X: Mô tả mục đích
-- Kích hoạt extension nếu cần
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Tạo bảng
CREATE TABLE IF NOT EXISTS bang_moi (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES users(id) ON DELETE CASCADE,
    du_lieu jsonb,
    created_at timestamptz DEFAULT now()
);

-- 2. Kích hoạt RLS (Bắt buộc)
ALTER TABLE bang_moi ENABLE ROW LEVEL SECURITY;

-- 3. Tạo Policy Cho Phép (Permissive)
-- Policy CREATE
CREATE POLICY "Users can create their own data"
ON bang_moi FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy SELECT
CREATE POLICY "Users can view their own data"
ON bang_moi FOR SELECT TO authenticated
USING (auth.uid() = user_id);

-- Policy UPDATE
CREATE POLICY "Users can update their own data"
ON bang_moi FOR UPDATE TO authenticated
USING (auth.uid() = user_id);

-- Policy DELETE
CREATE POLICY "Users can delete their own data"
ON bang_moi FOR DELETE TO authenticated
USING (auth.uid() = user_id);
```

## 4. Áp dụng Migration
Yêu cầu Agent chạy công cụ CLI của Supabase hoặc hướng dẫn người dùng chạy thủ công qua Dashboard.
