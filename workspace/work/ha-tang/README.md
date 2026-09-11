# Hạ tầng — script vận hành Claude Code + Orca

**Thư mục này cố tình không chứa script.** Bản chuẩn của cả ba script nằm ở
[`C:\work\chat-archive\scripts\`](../chat-archive/scripts/) vì chúng đã được git-track ở đó,
có lịch sử commit và có README riêng ghi rõ hạn chế của từng cái.

Nhân bản script sang đây sẽ tạo ra đúng vấn đề mà lần dọn dẹp 10/09/2026 vừa xử lý:
nhiều bản, không biết bản nào mới. Trước khi dọn, `build-archive.ps1` tồn tại 2 bản khác
nội dung (một ở home, một trong repo) — bản ở home là bản cũ còn lỗi xoá mất `.git`.

## Script hiện có

| Script | Việc | Cảnh báo |
|---|---|---|
| `build-archive.ps1` | Xuất transcript Claude Code ra `chat-archive/` dạng jsonl + markdown, có redact secret | Ghi đè `transcripts/`, `config/`, `README.md`, `.gitignore` mỗi lần chạy. Redact bằng regex — **không phải bảo đảm** |
| `thu-thap-log-claude-orca.ps1` | Gom log chẩn đoán Claude + Orca thành `.zip` để gửi hỗ trợ | 🔴 **Không redact.** Bundle chứa nguyên văn transcript. Bản tạo 09/09/2026 có token `sk-ant-oat01-…` plaintext. Đọc kỹ trước khi gửi cho bất kỳ ai |
| `sua-orca.ps1` | Sửa cấu hình Orca | Tắt hẳn Orca trước khi chạy — Orca ghi đè config lúc thoát |

## Chạy

```powershell
powershell -ExecutionPolicy Bypass -File "C:\work\chat-archive\scripts\build-archive.ps1"
```

Đọc [`chat-archive/scripts/README.md`](../chat-archive/scripts/README.md) trước khi chạy
bất cứ script nào — mỗi cái có phần "Hạn chế cần biết" riêng.

## Đã sửa 10/09/2026

Khi dời repo về `C:\work`, các đường dẫn hard-code đã hỏng được thay bằng đường dẫn tự định vị:

- `build-archive.ps1` — bỏ `$Home2 = "C:\Users\Cung Đức Lương"`; dùng `$env:USERPROFILE`
  cho `.claude\projects` và `Split-Path -Parent $PSScriptRoot` cho thư mục đích.
- `ca-phe-xuat-khau/tai-lieu/…/convert.ps1` và `verify.ps1` — trỏ `$PSScriptRoot` thay cho
  `$env:USERPROFILE\Downloads\CaPhe-DienBien-Word` (thư mục đó đã không còn tồn tại).
