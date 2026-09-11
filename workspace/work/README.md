# C:\work — không gian làm việc của Claude Code + Orca

Một chỗ duy nhất cho mọi việc Claude và Orca làm trên máy này. Dựng ngày **10/09/2026**,
thay cho tình trạng cũ: dữ liệu rải rác giữa `~/Downloads`, thư mục home và OneDrive.

## Vì sao là `C:\work`

| Lý do | Chi tiết |
|---|---|
| Không dấu, không khoảng trắng | Cắt bỏ cả lớp lỗi quoting/encoding của PowerShell 5.1 mà đường dẫn `C:\Users\Cung Đức Lương\…` hay gây ra |
| Ngoài OneDrive | OneDrive sync làm hỏng `.git` (conflict `index.lock`), và Files On-Demand có thể biến file thành placeholder rỗng khiến Claude đọc lỗi |
| Ngoài `~/Downloads` | Downloads là chỗ trình duyệt đổ file xuống, không phải chỗ chứa dữ liệu dự án |

## Cây thư mục

```
C:\work\
├─ ca-phe-xuat-khau\   repo git — dự án xuất khẩu cà phê (BẢN CHUẨN của mọi tài liệu)
├─ chat-archive\       repo git — lưu trữ hội thoại Claude Code + script hạ tầng
├─ ha-tang\            trỏ tới script vận hành (xem README bên trong)
└─ _kho\               log, file tạm, bản trùng — KHÔNG phải nguồn dữ liệu
```

## Quy tắc

1. **Dự án mới → thư mục con của `C:\work`, kèm `git init` ngay.** Đừng tạo ở home hay Downloads.
2. **`_kho/` không phải nơi lưu trữ.** Chỉ chứa thứ chờ xoá. Không tham chiếu file trong đó từ tài liệu dự án.
3. **Tài liệu gốc thuộc về repo dự án**, không để rời ngoài workspace.
4. **Script phải tự định vị** bằng `$PSScriptRoot` hoặc `$env:USERPROFILE` — không hard-code
   `C:\Users\Cung Đức Lương\…`. PowerShell 5.1 đọc file `.ps1` không BOM theo ANSI, ký tự
   tiếng Việt trong đường dẫn sẽ hỏng.

## Cấu hình cần làm một lần

- **Claude Code:** chạy `/add-dir C:\work` để Claude được đọc/ghi ở đây, hoặc mở phiên
  trực tiếp với `cd C:\work` trước khi gọi `claude`.
- **Orca:** workspace hiện vẫn trỏ `C:\Users\Cung Đức Lương\Downloads`. Đổi trong giao diện
  Orca sang `C:\work`. Đừng sửa tay `%APPDATA%\orca\profiles\local-default\orca-data.json`
  khi Orca đang chạy — Orca ghi đè file đó lúc thoát.

## Những gì vẫn nằm ngoài `C:\work`

Cố ý, không phải bỏ sót:

- `~/.claude/` — cấu hình và transcript của Claude Code, phải ở đúng chỗ mặc định.
- `~/.orca/`, `~/orca/` — dữ liệu runtime của Orca.
- `~/OneDrive/Documents/caffe/` — bản tài liệu Word chuyển tay, **giữ làm dự phòng**.
  Đã đối chiếu md5: trùng hoàn toàn với `ca-phe-xuat-khau/tai-lieu/`. Khi hai bên khác nhau,
  **lấy theo repo**.
- `~/Downloads/` — chỉ còn installer, ảnh, file mockup. Không còn dữ liệu dự án.
- `~/animesoft/` — repo dữ liệu game, không liên quan dự án nào ở đây.
