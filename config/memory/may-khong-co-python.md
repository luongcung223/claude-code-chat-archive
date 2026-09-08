---
name: may-khong-co-python
description: Máy không có Python thật — python3.exe chỉ là stub Store 0 byte; mọi hook/script phải viết bằng PowerShell.
metadata: 
  node_type: memory
  type: project
  originSessionId: c165893f-4315-437e-9b48-d5d14aa7cad9
  modified: 2026-09-07T02:37:17.037Z
---

Trên máy này `python3.exe` và `python.exe` trong `%LOCALAPPDATA%\Microsoft\WindowsApps` là **App Execution Alias 0 byte** của Microsoft Store, không phải Python. Chạy chúng trả về exit code 9009 kèm "Python was not found". `py` cũng không có.

**Why:** Hook `chia-viec.py` từng được đăng ký trong `settings.json` với lệnh `python3 ...`, gắn vào `UserPromptSubmit` và `PreToolUse(Read|Grep|Glob|Bash)`. Nó chưa từng chạy được lần nào — chỉ âm thầm spawn một tiến trình lỗi ở mỗi lượt prompt và mỗi lần đọc file. Đã gỡ khỏi settings ngày 07/09/2026 (file `.py` vẫn còn trong `~/.claude/hooks/` để tham khảo).

**How to apply:** Đừng đề xuất hook, automation hay script phụ thuộc Python trừ khi người dùng đồng ý cài Python trước. Mặc định viết bằng PowerShell. Nếu cần thêm hook, kiểm tra `Get-Command` cho interpreter TRƯỚC khi ghi vào `settings.json`.

Liên quan: [[lam-viec-bang-tieng-viet]]
