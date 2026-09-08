# Hướng dẫn chung cho máy này

## Ngôn ngữ
Trả lời bằng **tiếng Việt**. Giữ nguyên thuật ngữ kỹ thuật tiếng Anh (commit, worktree, hook, branch…) — đừng dịch máy móc.

## Môi trường
- Windows 11 Home, shell là **Windows PowerShell 5.1** (`powershell.exe`), không phải PowerShell 7.
  - Không có `&&`, `||`, `?:`, `??`, `?.`. Nối lệnh: `A; if ($?) { B }`.
  - Không có `head`, `tail`, `which`, `touch`, `wc`, `mkdir -p`, `rm -rf`.
- **Không có Python** trên máy. `python3.exe` / `python.exe` trong `WindowsApps` chỉ là stub 0 byte của Microsoft Store, chạy sẽ ra lỗi 9009. Đừng viết hook, script hay lệnh nào phụ thuộc Python — dùng PowerShell.
- **Không có Node.js / npm / yarn**. Claude Code ở đây là bản native `.exe`, không cài qua npm.
- Git: `C:\Program Files\Git\cmd\git.exe` (2.55.0). Cài 07/09/2026.
- Claude Code: `C:\Users\Cung Đức Lương\.local\bin\claude.exe`.
- Tên người dùng trong đường dẫn có dấu tiếng Việt (`Cung Đức Lương`) → **luôn bọc đường dẫn trong dấu nháy kép**. Khi ghi file mà công cụ khác sẽ đọc, dùng `-Encoding utf8` tường minh.

## Orca
Máy dùng **Orca** (stablyai) làm vỏ điều phối agent — nó mở Claude Code trong các pane terminal.
- Cấu hình Orca nằm ở `%APPDATA%\orca\profiles\local-default\orca-data.json`.
- **Orca ghi đè file này khi thoát.** Muốn sửa bằng tay thì phải tắt hẳn Orca trước.
- Agent mặc định của Orca là `claude`.
