---
name: github-da-ket-noi
description: "Máy đã kết nối GitHub qua gh CLI, account luongcung223, gh làm credential helper cho HTTPS."
metadata: 
  node_type: memory
  type: project
  originSessionId: 9cb85dc9-df93-406a-840f-29270fa46672
  modified: 2026-09-07T09:38:52.529Z
---

Ngày 07/09/2026 đã kết nối máy này với GitHub:

- `gh` CLI 2.100.0 cài bằng winget, nằm ở `C:\Program Files\GitHub CLI\gh.exe` (shell đang mở trước lúc cài chưa có trong PATH → dùng full path có nháy kép).
- Đăng nhập bằng device flow (`gh auth login --web`), account **luongcung223** (`luongcung67@gmail.com`), token lưu ở Windows keyring, scopes: `repo`, `read:org`, `gist`.
- `gh auth setup-git` đã đặt `credential.https://github.com.helper` trỏ về `gh auth git-credential`, nên git push/pull HTTPS dùng token của gh. `credential.helper=manager` (GCM 2.9.0) vẫn còn nhưng bị helper riêng cho github.com ghi đè.
- Chưa có SSH key trong `~/.ssh` — mọi thao tác đi qua HTTPS.
- Tại thời điểm kết nối, account chưa có repo nào (`gh repo list` trống).

**Why:** để khỏi kiểm tra lại từ đầu mỗi session và biết đường đi của credential khi push lỗi.
**How to apply:** cần thao tác GitHub thì gọi thẳng `gh`; nếu push báo 403/401 thì kiểm tra `gh auth status` trước khi nghi ngờ GCM. Xem thêm [[may-khong-co-python]].
