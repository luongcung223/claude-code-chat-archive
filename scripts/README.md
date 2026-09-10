# Script PowerShell

Ba script tiện ích cho môi trường Claude Code + Orca trên máy này. Bản gốc nằm ở `~`
(thư mục home); đây là bản được đưa vào repo để lưu vết.

Môi trường mục tiêu: **Windows PowerShell 5.1**, không có Python, không có Node.js.

| Script | Việc nó làm |
|---|---|
| `build-archive.ps1` | Dựng chính repo này từ `~/.claude/projects` |
| `thu-thap-log-claude-orca.ps1` | Gom log chẩn đoán Claude Code + Orca thành một bundle |
| `sua-orca.ps1` | Áp cấu hình Orca thân thiện hơn |

---

## `build-archive.ps1`

Đọc toàn bộ file `.jsonl` trong `~/.claude/projects`, sinh ra:

- `transcripts/jsonl/` — bản gốc đã redact
- `transcripts/markdown/` — bản dễ đọc, tool call và thinking gập trong `<details>`
- `config/` — `CLAUDE.md` và `memory/<tên-project>/` (tách theo project: mỗi project của
  Claude Code có `MEMORY.md` riêng, gộp phẳng sẽ ghi đè lẫn nhau)
- `README.md` và `.gitignore`

**Redaction:** quét và thay thế 6 mẫu — Anthropic key (`sk-ant-…`), GitHub token
(`ghp_/gho_/…`), JWT, `as_ey…`, AWS key (`AKIA…`), Slack token (`xox…`). Cuối lần chạy
in ra số chuỗi đã thay.

```powershell
powershell -ExecutionPolicy Bypass -File "C:\work\chat-archive\scripts\build-archive.ps1"
```

> ⚠️ **Script ghi đè.** `transcripts/`, `config/`, `README.md`, `.gitignore` bị xoá và
> sinh lại mỗi lần chạy — đừng sửa tay ở đó. `scripts/` và `.git/` **không** bị đụng tới.
>
> Bản trước của script xoá cả thư mục `chat-archive` (`Remove-Item $Out -Recurse -Force`),
> tức là sẽ xoá luôn `.git` và chính thư mục `scripts/` này. Đã sửa ngày 10/09/2026 để chỉ
> xoá đúng phần được sinh ra.

### Hạn chế cần biết

- Redaction dựa trên **regex khớp mẫu**. Secret không khớp mẫu nào (mật khẩu dạng chữ
  thường, connection string, khoá riêng dán vào chat) sẽ **lọt qua**. Đây là lưới lọc,
  không phải bảo đảm.
- Đường dẫn máy, tên file cá nhân và chi tiết cấu hình **không** bị redact.
- ~~Đường dẫn home bị hard-code ở dòng 4 (`$Home2`)~~ — đã sửa 10/09/2026 khi dời repo về
  `C:\work\`: script dùng `$env:USERPROFILE` cho `.claude\projects` và `$PSScriptRoot` để tự
  định vị repo, nên di chuyển repo không còn làm hỏng script.

---

## `thu-thap-log-claude-orca.ps1`

Gom log chẩn đoán vào `~/claude-orca-diagnostics/<timestamp>/` kèm file `.zip`, để gửi
cho người hỗ trợ. Có `MANIFEST.txt`, `README.txt` và `system-info.txt`.

Chủ động **loại trừ**: `*.key` (peerToken), keypair E2EE, `ai-vault/`, cookies, cache,
và mask biến môi trường có tên khớp `key|token|secret|password|credential|auth`.

```powershell
powershell -ExecutionPolicy Bypass -File "C:\work\chat-archive\scripts\thu-thap-log-claude-orca.ps1"
```

> 🔴 **Bundle sinh ra KHÔNG an toàn để công khai.** Khác với `build-archive.ps1`, script
> này **không redact nội dung transcript**. Nó chép nguyên `~/.claude/projects/` — tức là
> toàn bộ hội thoại, mọi file đã đọc, mọi output lệnh — và `orca/terminal-history/`.
> Nếu từng có API key hay mật khẩu hiện trên màn hình trong một phiên nào đó, nó nằm
> nguyên văn trong bundle.
>
> Bundle được tạo ngày 09/09/2026 trên máy này chứa một token `sk-ant-oat01-…` dạng
> plaintext. Đọc kỹ trước khi gửi bundle cho bất kỳ ai, và **đừng commit bundle lên đây**.

---

## `sua-orca.ps1`

Ghi cấu hình vào `%APPDATA%\orca\profiles\local-default\orca-data.json`.

```powershell
powershell -ExecutionPolicy Bypass -File "C:\work\chat-archive\scripts\sua-orca.ps1"
```

> ⚠️ **Phải tắt hẳn Orca trước khi chạy**, kể cả icon ở khay hệ thống. Orca giữ cấu hình
> trong bộ nhớ và ghi đè file khi thoát — sửa lúc nó đang chạy là mất trắng. Script tự
> kiểm tra tiến trình `Orca` và `orca-terminal-daemon`, thoát với mã 1 nếu còn chạy.
>
> Chạy từ **Windows PowerShell**, không phải terminal bên trong Orca.
